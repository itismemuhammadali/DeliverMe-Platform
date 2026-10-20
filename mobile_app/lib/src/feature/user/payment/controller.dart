import 'package:get/get.dart';
import 'package:deliver_mee/src/common/services/payment_service.dart';
import 'package:deliver_mee/src/feature/user/home/controller/controller.dart';
import 'package:deliver_mee/src/common/services/pricing_service.dart';

enum PaymentMethod {
  applePay,
  creditCard,
}

class PaymentMethodController extends GetxController {
  var selectedMethod = PaymentMethod.applePay.obs;
  var selectedPaymentMethodId = ''.obs;
  var availablePaymentMethods = <Map<String, dynamic>>[].obs;
  var isLoadingPaymentMethods = false.obs;

  PaymentService get paymentService {
    if (!Get.isRegistered<PaymentService>()) {
      throw Exception('PaymentService not registered. Please restart the app.');
    }
    return Get.find<PaymentService>();
  }

  final HomeController homeController = Get.find<HomeController>();
  final PricingService pricingService = Get.find<PricingService>();

  @override
  void onInit() {
    super.onInit();
    print('🔧 PaymentMethodController initialized');
    print(
        '🔍 PaymentService registered: ${Get.isRegistered<PaymentService>()}');
    loadPaymentMethods();
  }

  void selectMethod(PaymentMethod method) {
    selectedMethod.value = method;
  }

  void selectPaymentMethodId(String paymentMethodId) {
    selectedPaymentMethodId.value = paymentMethodId;
  }

  /// Load available payment methods
  Future<void> loadPaymentMethods() async {
    try {
      isLoadingPaymentMethods.value = true;

      // Check if PaymentService is available
      if (!Get.isRegistered<PaymentService>()) {
        print(
            '⚠️ PaymentService not registered yet, skipping payment methods load');
        return;
      }

      final result = await paymentService.getPaymentMethods();

      if (result['success']) {
        final methods =
            result['data']['payment_methods'] as List<dynamic>? ?? [];
        availablePaymentMethods.value = methods.cast<Map<String, dynamic>>();

        print('💳 Loaded ${methods.length} payment methods');
        for (int i = 0; i < methods.length; i++) {
          final method = methods[i];
          print(
              '💳 Method $i: ${method['id']} - ${method['card']?['brand']} ending in ${method['card']?['last4']}');
        }

        // Select the first payment method if available
        if (methods.isNotEmpty) {
          selectedPaymentMethodId.value = methods.first['id'] ?? '';
          print('✅ Payment method selected: ${selectedPaymentMethodId.value}');
        } else {
          print('⚠️ No payment methods found');
        }
      } else {
        print('❌ Failed to load payment methods: ${result['error']}');
        print('❌ Full error response: ${result}');
      }
    } catch (e) {
      print('❌ Error loading payment methods: $e');
    } finally {
      isLoadingPaymentMethods.value = false;
    }
  }

  /// Process payment for the current delivery
  Future<Map<String, dynamic>> processPayment() async {
    try {
      // Check if PaymentService is available
      if (!Get.isRegistered<PaymentService>()) {
        return {
          'success': false,
          'error': 'Payment service not available. Please restart the app.',
        };
      }

      // Prefer the delivery price returned by backend (delivery.estimated_cost)
      // which is stored on HomeController, otherwise fall back to PricingService.
      double amount = homeController.deliveryPrice.value > 0
          ? homeController.deliveryPrice.value
          : pricingService.totalFare.value;

      if (amount <= 0) {
        return {
          'success': false,
          'error': 'No valid amount found for payment',
        };
      }

      print('🔍 Amount: \$${amount.toStringAsFixed(2)}');
      print('🔍 Delivery ID: ${homeController.deliveryId.value}');

      // Check if we have a delivery ID
      if (homeController.deliveryId.value.isEmpty) {
        print('❌ No delivery ID found');
        return {
          'success': false,
          'error': 'No delivery found. Please create a delivery first.',
        };
      }

      // Process payment with Stripe
      final result = await paymentService.processPayment(
        amount: amount,
        currency: 'cad',
        deliveryId: homeController.deliveryId.value.isNotEmpty
            ? homeController.deliveryId.value
            : 'test-delivery-${DateTime.now().millisecondsSinceEpoch}',
        tipAmount: 0.0,
        savePaymentMethod: true,
      );

      return result;
    } catch (e) {
      print('❌ Error processing payment: $e');
      return {
        'success': false,
        'error': 'Payment processing failed: ${e.toString()}',
      };
    }
  }

  /// Add a new payment method using a Stripe token (pm_xxx).
  /// The token is created on-device by the Stripe SDK — raw card data never touches our backend.
  Future<Map<String, dynamic>> addPaymentMethod({
    required String paymentMethodId,
  }) async {
    try {
      if (!Get.isRegistered<PaymentService>()) {
        return {
          'success': false,
          'error': 'Payment service not available. Please restart the app.',
        };
      }

      final result = await paymentService.attachPaymentMethod(
        paymentMethodId: paymentMethodId,
      );

      if (result['success']) {
        // Reload payment methods to include the new one
        await loadPaymentMethods();
      }

      return result;
    } catch (e) {
      print('❌ Error adding payment method: $e');
      return {
        'success': false,
        'error': 'Failed to add payment method: ${e.toString()}',
      };
    }
  }

}
