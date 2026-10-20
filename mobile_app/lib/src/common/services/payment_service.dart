import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import '../constant/stripe_config.dart';
import '../constant/api_config.dart';
import 'stripe_config_service.dart';

class PaymentService extends GetxService {
  static PaymentService get to => Get.find<PaymentService>();

  // Using centralized API configuration
  String get baseUrl => ApiConfig.baseUrl;

  // Get Stripe public key from StripeConfigService
  String get stripePublicKey {
    final stripeService = Get.find<StripeConfigService>();
    return stripeService.getPublicKey();
  }

  // Payment state
  final RxBool isProcessingPayment = false.obs;
  final RxString paymentError = ''.obs;
  final RxString paymentSuccess = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('🔧 PaymentService initialized');
    print('🔍 Base URL: $baseUrl');
    print('🔍 Stripe Public Key: ${stripePublicKey.substring(0, 20)}...');
    
    // Get environment from Stripe config service if available
    try {
      final stripeService = Get.find<StripeConfigService>();
      print('🔍 Stripe Environment: ${stripeService.getEnvironment()}');
      print('🔍 Stripe Key Valid: ${stripeService.isValidPublicKey()}');
    } catch (e) {
      print('⚠️ StripeConfigService not available yet: $e');
    }

    // Initialize Stripe
    _initializeStripe();
  }

  /// Initialize Stripe with the public key from Remote Config
  Future<void> _initializeStripe() async {
    try {
      // Wait for StripeConfigService to be initialized if needed
      await Future.delayed(Duration(milliseconds: 500));
      
      Stripe.publishableKey = stripePublicKey;
      await Stripe.instance.applySettings();
      print('✅ Stripe initialized successfully with key: ${stripePublicKey.substring(0, 20)}...');
    } catch (e) {
      print('❌ Failed to initialize Stripe: $e');
      // Retry initialization after a delay
      await Future.delayed(Duration(seconds: 2));
      try {
        Stripe.publishableKey = stripePublicKey;
        await Stripe.instance.applySettings();
        print('✅ Stripe initialized successfully on retry');
      } catch (retryError) {
        print('❌ Failed to initialize Stripe on retry: $retryError');
      }
    }
  }

  // Headers for API requests with authentication
  Future<Map<String, String>> _getHeaders() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Process payment using Stripe SDK with payment intent
  Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String currency,
    required String deliveryId,
    double tipAmount = 0.0,
    bool savePaymentMethod = true,
  }) async {
    try {
      isProcessingPayment.value = true;
      paymentError.value = '';
      paymentSuccess.value = '';

      print('💳 Starting Stripe payment process...');
      print('💰 Amount: \$${amount.toStringAsFixed(2)}');
      print('🆔 Delivery ID: $deliveryId');

      // Step 1: Create payment intent via backend
      final paymentIntentResult = await createPaymentIntent(
        amount: amount,
        currency: currency,
        deliveryId: deliveryId,
        tipAmount: tipAmount,
      );

      String? clientSecret;

      if (paymentIntentResult['success']) {
        final paymentIntentData = paymentIntentResult['data'];
        clientSecret = paymentIntentData['client_secret'];

        if (clientSecret == null) {
          return {
            'success': false,
            'error': 'No client secret received from payment intent',
          };
        }
      } else {
        // Return backend error directly - don't try fallback
        final errorMessage = paymentIntentResult['error'] ??
            'Failed to create payment intent. Please try again or contact support.';
        print('❌ Backend payment intent failed: $errorMessage');
        return {
          'success': false,
          'error': errorMessage,
        };
      }

      print('✅ Payment intent created successfully');
      print('🔑 Client Secret: ${clientSecret.substring(0, 20)}...');

      // Step 2: Present Stripe payment sheet
      try {
        // Initialize payment sheet for card payment
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: clientSecret,
            merchantDisplayName: 'DeliverMee',
            style: ThemeMode.system,
            appearance: PaymentSheetAppearance(
              colors: PaymentSheetAppearanceColors(
                primary: Color(0xFF6750A4), // Your app's primary color
              ),
            ),
          ),
        );

        // Present payment sheet
        await Stripe.instance.presentPaymentSheet();

        // Get payment intent details after successful payment
        final paymentIntent =
            await Stripe.instance.retrievePaymentIntent(clientSecret);

        print('✅ Payment confirmed successfully');
        print('💳 Payment Intent ID: ${paymentIntent.id}');
        print('💳 Payment Method ID: ${paymentIntent.paymentMethodId}');

        // Update backend with payment confirmation
        await _updatePaymentStatus(
          paymentIntentId: paymentIntent.id,
          paymentMethodId: paymentIntent.paymentMethodId ?? '',
          paymentId: paymentIntentResult['data']['payment_id'] ?? '',
        );

        // Update delivery status to 'requested' so drivers can see and accept it
        try {
          await _updateDeliveryStatus(
            deliveryId: deliveryId,
            status: 'requested',
            paymentIntentId: paymentIntent.id,
            amount: amount,
            currency: currency,
          );
          print('✅ Delivery status updated to requested after payment');
        } catch (e) {
          print('⚠️ Failed to update delivery status to confirmed: $e');
        }

        // Payment is confirmed - return success
        paymentSuccess.value = 'Payment processed successfully';
        return {
          'success': true,
          'data': {
            'payment_intent_id': paymentIntent.id,
            'client_secret': clientSecret,
            'amount': amount,
            'currency': currency,
            'delivery_id': deliveryId,
            'delivery_status': 'payment_confirmed',
          },
          'message': 'Payment processed successfully',
        };
      } catch (stripeError) {
        print('❌ Stripe payment failed: $stripeError');

        // Step 4: Handle error states
        await _handlePaymentError(
          error: stripeError,
          deliveryId: deliveryId,
        );

        // Handle specific Stripe errors
        String errorMessage = 'Payment failed';
        if (stripeError.toString().contains('canceled')) {
          errorMessage = 'Payment was canceled';
        } else if (stripeError.toString().contains('failed')) {
          errorMessage = 'Payment failed. Please try again.';
        } else {
          errorMessage = 'Payment error: ${stripeError.toString()}';
        }

        paymentError.value = errorMessage;
        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      final errorMessage = 'Payment error: ${e.toString()}';
      paymentError.value = errorMessage;
      print('❌ Payment error: $e');
      return {
        'success': false,
        'error': errorMessage,
      };
    } finally {
      isProcessingPayment.value = false;
    }
  }

  /// Get payment methods for the current user
  Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final url = Uri.parse('$baseUrl/mobile-payments/payment-methods');

      print('💳 Fetching payment methods from: $url');
      print('🔐 Payment Methods Headers: ${await _getHeaders()}');

      final response = await http
          .get(
        url,
        headers: await _getHeaders(),
      )
          .timeout(
        Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Payment methods request timed out');
        },
      );

      print(
          '📡 Payment Methods Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('💳 Payment methods data received: ${data}');
        return {
          'success': true,
          'data': data,
        };
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ??
            errorData['error'] ??
            'Failed to fetch payment methods';
        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Payment methods error: $e');
      return {
        'success': false,
        'error': 'Failed to fetch payment methods: ${e.toString()}',
      };
    }
  }

  /// Attach a Stripe payment method token to the customer on the backend.
  /// The token (pm_xxx) was created on-device by the Stripe SDK.
  /// Raw card data is never sent to our server — PCI compliant.
  Future<Map<String, dynamic>> attachPaymentMethod({
    required String paymentMethodId,
  }) async {
    try {
      print('💳 Attaching payment method token to customer: $paymentMethodId');
      final url = Uri.parse('$baseUrl/mobile-payments/payment-methods');

      final requestBody = {
        'payment_method_id': paymentMethodId,
      };

      final response = await http
          .post(
            url,
            headers: await _getHeaders(),
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () =>
                throw Exception('Attach payment method request timed out'),
          );

      print(
          '📡 Attach Payment Method Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Payment method attached successfully');
        return {
          'success': true,
          'data': data,
          'message': 'Payment method added successfully',
        };
      } else {
        String errorMessage = 'Failed to add payment method';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ??
              errorData['message'] ??
              errorMessage;
        } catch (_) {}
        print('❌ Attach payment method failed: $errorMessage');
        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Attach payment method error: $e');
      return {
        'success': false,
        'error': 'Failed to add payment method: ${e.toString()}',
      };
    }
  }

  /// Create a payment intent using Stripe SDK
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String deliveryId,
    double tipAmount = 0.0,
  }) async {
    try {
      print('💳 Creating payment intent with Stripe SDK...');

      // For now, we'll use the backend API to create payment intents
      // The Stripe SDK will be used for payment confirmation
      final url = Uri.parse('$baseUrl/mobile-payments/create-payment-intent');

      final requestBody = {
        'delivery_id': deliveryId,
        'amount': (amount * 100).round(),
        'tip_amount': (tipAmount * 100).round(),
        'currency': currency.toLowerCase(),
        'stripe_public_key': stripePublicKey,
      };

      final headers = await _getHeaders();
      print('🔗 Create PaymentIntent URL: $url');
      print('📦 Create PaymentIntent body: ${jsonEncode(requestBody)}');

      final response = await http
          .post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Create payment intent request timed out');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final clientSecret = (data is Map) ? data['client_secret'] : null;
        print(
            '✅ Payment intent created (client_secret present: ${clientSecret != null})');
        return {
          'success': true,
          'data': data,
          'message': 'Payment intent created successfully',
        };
      } else {
        print(
            '📡 Create PaymentIntent error: ${response.statusCode} - ${response.body}');

        String errorMessage = 'Failed to create payment intent';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map) {
            errorMessage = (errorData['message'] ??
                    errorData['error'] ??
                    errorData['detail'] ??
                    errorData['details'] ??
                    errorMessage)
                .toString();
          }
        } catch (_) {
          // If backend returns non-JSON, surface the raw body (trimmed)
          final raw = response.body.trim();
          if (raw.isNotEmpty) errorMessage = raw;
        }
        print('❌ Payment intent creation failed: $errorMessage');
        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Error creating payment intent: $e');
      return {
        'success': false,
        'error': 'Failed to create payment intent: ${e.toString()}',
      };
    }
  }

  /// Confirm payment using Stripe SDK
  Future<Map<String, dynamic>> confirmPayment({
    required String paymentIntentClientSecret,
  }) async {
    try {
      print('💳 Confirming payment with Stripe SDK...');

      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntentClientSecret,
      );

      return {
        'success': true,
        'data': paymentIntent,
        'message': 'Payment confirmed successfully',
      };
    } catch (e) {
      print('❌ Error confirming payment: $e');
      return {
        'success': false,
        'error': 'Failed to confirm payment: ${e.toString()}',
      };
    }
  }

  /// Get authentication token
  // ignore: unused_element
  Future<String> _getAuthToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
  }

  /// Reset payment state
  void resetPaymentState() {
    isProcessingPayment.value = false;
    paymentError.value = '';
    paymentSuccess.value = '';
  }

  /// Clear payment error
  void clearPaymentError() {
    paymentError.value = '';
  }

  /// Clear payment success message
  void clearPaymentSuccess() {
    paymentSuccess.value = '';
  }

  /// Handle payment cancellation
  void handlePaymentCancellation() {
    isProcessingPayment.value = false;
    paymentError.value = 'Payment was canceled by user';
    print('🚫 Payment canceled by user');
  }

  /// Check if payment is currently being processed
  bool get isPaymentInProgress => isProcessingPayment.value;

  /// Step 3: Handle payment confirmation and update delivery status
  Future<void> _updatePaymentStatus({
    required String paymentIntentId,
    required String paymentMethodId,
    required String paymentId,
  }) async {
    try {
      print('🔄 Updating payment status in backend...');
      print('💳 Payment Intent ID: $paymentIntentId');
      print('💳 Payment Method ID: $paymentMethodId');
      print('🆔 Payment ID: $paymentId');

      final url = Uri.parse('$baseUrl/mobile-payments/confirm-payment');
      
      final requestBody = {
        'payment_intent_id': paymentIntentId,
        'payment_method_id': paymentMethodId,
        'payment_id': paymentId,
      };

      print('📡 Confirming payment with backend: $url');
      print('📦 Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Payment confirmation request timed out');
        },
      );

      print('📡 Confirmation response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Payment status updated successfully in backend');
      } else {
        print('⚠️ Payment succeeded but backend update failed: ${response.body}');
      }
    } catch (e) {
      print('❌ Error updating payment status: $e');
      // Don't throw - payment already succeeded
    }
  }

  /// Step 4: Handle payment error states
  Future<void> _handlePaymentError({
    required dynamic error,
    required String deliveryId,
  }) async {
    try {
      print('🔄 Handling payment error...');
      print('❌ Error: $error');
      print('🆔 Delivery ID: $deliveryId');

      // Update delivery status to "cancelled" (valid enum value)
      await _updateDeliveryStatus(
        deliveryId: deliveryId,
        status: 'cancelled',
        error: error.toString(),
      );

      print('✅ Delivery status updated to cancelled');
    } catch (e) {
      print('❌ Error updating delivery status after payment failure: $e');
    }
  }

  /// Map payment status to valid delivery status enum values
  String _mapToValidDeliveryStatus(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'payment_confirmed':
      case 'confirmed':
        return 'confirmed';
      case 'requested':
        return 'requested';
      case 'payment_failed':
      case 'failed':
      case 'cancelled':
        return 'cancelled';
      case 'pending':
        return 'pending_payment';
      case 'completed':
        return 'completed';
      default:
        return 'confirmed'; // Default fallback
    }
  }

  /// Update delivery status based on payment result
  Future<Map<String, dynamic>> _updateDeliveryStatus({
    required String deliveryId,
    required String status,
    String? paymentIntentId,
    double? amount,
    String? currency,
    String? error,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/deliveries/$deliveryId/status');

      // Map status to valid enum value
      final validStatus = _mapToValidDeliveryStatus(status);

      // Determine payment_status based on delivery status
      String? paymentStatus;
      if (validStatus == 'confirmed' || validStatus == 'requested') {
        paymentStatus = 'paid';
      } else if (validStatus == 'cancelled') {
        paymentStatus = 'failed';
      }

      final requestBody = {
        'status': validStatus,
        'updated_at': DateTime.now().toIso8601String(),
        if (paymentIntentId != null) 'payment_intent_id': paymentIntentId,
        if (amount != null) 'amount': amount,
        if (currency != null) 'currency': currency,
        if (error != null) 'error': error,
        if (paymentStatus != null) 'payment_status': paymentStatus,
      };

      print('🔄 Updating delivery status: $status -> $validStatus');
      print('📡 URL: $url');
      print('📦 Request body: $requestBody');

      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          print('✅ Delivery status updated successfully');
          return {
            'success': true,
            'data': data,
          };
        } catch (e) {
          print(
              '⚠️ Delivery status updated but response is not JSON: ${response.body}');
          return {
            'success': true,
            'data': {
              'status': status,
              'updated_at': DateTime.now().toIso8601String()
            },
          };
        }
      } else {
        print(
            '❌ Delivery status update failed: ${response.statusCode} - ${response.body}');

        // Try with a fallback status if the first attempt failed
        if (validStatus != 'confirmed') {
          print('🔄 Retrying with fallback status: confirmed');
          return await _updateDeliveryStatusWithFallback(
            deliveryId: deliveryId,
            originalStatus: status,
            fallbackStatus: 'confirmed',
            paymentIntentId: paymentIntentId,
            amount: amount,
            currency: currency,
            error: error,
          );
        }

        return {
          'success': false,
          'error': 'Failed to update delivery status: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error updating delivery status: $e');
      return {
        'success': false,
        'error': 'Failed to update delivery status: ${e.toString()}',
      };
    }
  }

  /// Fallback method to update delivery status with a different status value
  Future<Map<String, dynamic>> _updateDeliveryStatusWithFallback({
    required String deliveryId,
    required String originalStatus,
    required String fallbackStatus,
    String? paymentIntentId,
    double? amount,
    String? currency,
    String? error,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/deliveries/$deliveryId/status');

      final requestBody = {
        'status': fallbackStatus,
        'updated_at': DateTime.now().toIso8601String(),
        if (paymentIntentId != null) 'payment_intent_id': paymentIntentId,
        if (amount != null) 'amount': amount,
        if (currency != null) 'currency': currency,
        if (error != null) 'error': error,
      };

      print(
          '🔄 Fallback: Updating delivery status: $originalStatus -> $fallbackStatus');
      print('📡 URL: $url');
      print('📦 Request body: $requestBody');

      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);
          print('✅ Fallback delivery status updated successfully');
          return {
            'success': true,
            'data': data,
            'fallback_used': true,
          };
        } catch (e) {
          print(
              '⚠️ Fallback delivery status updated but response is not JSON: ${response.body}');
          return {
            'success': true,
            'data': {
              'status': fallbackStatus,
              'updated_at': DateTime.now().toIso8601String()
            },
            'fallback_used': true,
          };
        }
      } else {
        print(
            '❌ Fallback delivery status update also failed: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'error':
              'Both primary and fallback status updates failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error in fallback delivery status update: $e');
      return {
        'success': false,
        'error': 'Fallback delivery status update failed: ${e.toString()}',
      };
    }
  }
}
