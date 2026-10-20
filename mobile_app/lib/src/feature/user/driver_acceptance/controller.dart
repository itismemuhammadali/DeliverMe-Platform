import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:deliver_mee/src/feature/user/driver_tracking/driver_tracking_screen.dart';
import 'package:deliver_mee/src/common/services/customer_delivery_tracking_service.dart';
import 'package:deliver_mee/src/feature/user/delivery_tracking/pages/customer_delivery_tracking_page.dart';

import 'package:deliver_mee/src/common/constant/api_config.dart';

class DriverAcceptanceController extends GetxController {
  static DriverAcceptanceController get to =>
      Get.find<DriverAcceptanceController>();

  // Observable variables
  final RxString statusMessage = 'Searching for drivers...'.obs;
  final RxString subStatusMessage =
      'Please wait while we find the best driver for your delivery'.obs;
  final RxDouble progressValue = 0.0.obs;
  final RxBool canCancel = true.obs;
  final RxBool isDriverAccepted = false.obs;
  final RxString driverName = ''.obs;
  final RxString driverPhone = ''.obs;
  final RxString driverRating = ''.obs;
  final RxString estimatedArrival = ''.obs;

  // Delivery information
  final RxString deliveryId = ''.obs;
  final RxString pickupAddress = ''.obs;
  final RxString dropoffAddress = ''.obs;
  final RxString itemName = ''.obs;
  final RxString trackingNumber = ''.obs;

  // Timer for polling
  Timer? _pollingTimer;
  String? _currentDeliveryId;
  String? _currentDriverId; // Store the current driver ID
  int _pollingAttempts = 0;
  static const int _maxPollingAttempts =
      2160; // 180 minutes with 5-second intervals
  static const Duration _pollingInterval = Duration(seconds: 5);

  // Base URL for API - using centralized config
  String get baseUrl => ApiConfig.baseUrl;

  @override
  void onClose() {
    _stopPolling();
    super.onClose();
  }

  /// Start checking for driver acceptance
  void startCheckingDriverAcceptance(String deliveryId) {
    _currentDeliveryId = deliveryId;
    _pollingAttempts = 0;
    _resetStatus();
    _startPolling();
  }

  /// Reset status to initial state
  void _resetStatus() {
    statusMessage.value = 'Searching for drivers...';
    subStatusMessage.value =
        'Please wait while we find the best driver for your delivery';
    progressValue.value = 0.0;
    canCancel.value = true;
    isDriverAccepted.value = false;
    driverName.value = '';
    driverPhone.value = '';
    driverRating.value = '';
    estimatedArrival.value = '';
  }

  /// Start polling for driver acceptance
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) {
      _checkDriverAcceptance();
    });
  }

  /// Stop polling
  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Check for driver acceptance
  Future<void> _checkDriverAcceptance() async {
    if (_currentDeliveryId == null) return;

    _pollingAttempts++;

    // Update progress
    progressValue.value =
        (_pollingAttempts / _maxPollingAttempts).clamp(0.0, 1.0);

    try {
      print(
          '🔍 Checking driver acceptance (attempt $_pollingAttempts/$_maxPollingAttempts)');

      final response = await http.get(
        Uri.parse('$baseUrl/deliveries/$_currentDeliveryId/status'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _handleDriverStatusResponse(data);
      } else {
        print('❌ Failed to check driver status: ${response.statusCode}');
        _handlePollingError();
      }
    } catch (e) {
      print('❌ Error checking driver acceptance: $e');
      _handlePollingError();
    }

    // Stop polling if max attempts reached
    if (_pollingAttempts >= _maxPollingAttempts) {
      _handleTimeout();
    }
  }

  /// Handle driver status response
  Future<void> _handleDriverStatusResponse(Map<String, dynamic> data) async {
    final status = data['status']?.toString().toLowerCase() ?? '';
    final delivery =
        (data['delivery'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final driver =
        (delivery['driver'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    print('📊 Driver status response: $status');
    print('📦 Delivery data: $delivery');
    print('👤 Driver data: $driver');

    // Update delivery information from status response
    if (delivery.isNotEmpty) {
      deliveryId.value = delivery['id']?.toString() ?? deliveryId.value;
      pickupAddress.value = delivery['pickup_address'] ?? pickupAddress.value;
      dropoffAddress.value =
          delivery['dropoff_address'] ?? dropoffAddress.value;
      itemName.value = delivery['item_name'] ?? itemName.value;
      trackingNumber.value =
          delivery['tracking_number'] ?? trackingNumber.value;

      // Store driver ID if available
      final driverId = delivery['driver_id']?.toString();
      if (driverId != null && driverId.isNotEmpty) {
        _currentDriverId = driverId;
        print('🔍 Driver ID found in delivery data: $_currentDriverId');
      }
    }

    switch (status) {
      case 'confirmed':
        // Check if driver has been assigned even if status is still confirmed
        if (delivery['driver_id'] != null) {
          print(
              '🔍 Driver assigned but status still confirmed, treating as accepted');
          await _handleDriverAccepted(delivery);
        } else {
          // Still waiting for driver
          statusMessage.value = 'Searching for drivers...';
          subStatusMessage.value = 'Looking for available drivers in your area';
        }
        break;

      case 'assigned':
      case 'accepted':
        // Driver accepted! Pass delivery data to get driver_id
        await _handleDriverAccepted(delivery);
        break;

      case 'picked_up':
        // Driver picked up the item
        await _handleItemPickedUp(delivery);
        break;

      case 'in_transit':
        // Item is in transit
        await _handleInTransit(delivery);
        break;

      case 'delivered':
        // Item delivered
        await _handleDelivered(delivery);
        break;

      case 'cancelled':
        // Delivery cancelled
        await _handleCancelled();
        break;

      default:
        // Unknown status, continue waiting
        statusMessage.value = 'Processing your request...';
        subStatusMessage.value = 'Please wait while we process your delivery';
    }
  }

  /// Handle when driver accepts the delivery
  Future<void> _handleDriverAccepted(Map<String, dynamic> delivery) async {
    _stopPolling();
    isDriverAccepted.value = true;
    canCancel.value = false;

    // Extract driver ID from delivery data
    final driverId = delivery['driver_id']?.toString();
    if (driverId != null && driverId.isNotEmpty) {
      _currentDriverId = driverId;
      print('🔍 Driver ID from delivery: $_currentDriverId');

      // Fetch driver details using the driver ID
      await _fetchDriverDetails(driverId);
    } else {
      print('⚠️ No driver ID found in delivery data');
      // Set default values
      driverName.value = 'Driver';
      driverPhone.value = '';
      driverRating.value = '4.5';
      estimatedArrival.value = '5-10 minutes';
    }

    statusMessage.value = 'Driver Found!';
    subStatusMessage.value =
        '${driverName.value} is on their way to pick up your item';
    progressValue.value = 1.0;

    print('✅ Driver accepted: ${driverName.value} (ID: $_currentDriverId)');

    // Fetch complete driver details and delivery information
    await _fetchCompleteDriverDetails();

    // Navigate to customer tracking page after a short delay
    Timer(Duration(seconds: 3), () {
      _navigateToCustomerTracking();
    });
  }

  /// Handle when item is picked up
  Future<void> _handleItemPickedUp(Map<String, dynamic> delivery) async {
    statusMessage.value = 'Item Picked Up!';
    subStatusMessage.value =
        '${driverName.value.isNotEmpty ? driverName.value : 'Your driver'} has picked up your item and is on the way';
    progressValue.value = 1.0;

    // Navigate to customer tracking page
    Timer(Duration(seconds: 2), () {
      _navigateToCustomerTracking();
    });
  }

  /// Handle when item is in transit
  Future<void> _handleInTransit(Map<String, dynamic> delivery) async {
    statusMessage.value = 'Item In Transit';
    subStatusMessage.value = 'Your item is on its way to the destination';
    progressValue.value = 1.0;

    // Navigate to customer tracking page
    _navigateToCustomerTracking();
  }

  /// Handle when item is delivered
  Future<void> _handleDelivered(Map<String, dynamic> delivery) async {
    statusMessage.value = 'Item Delivered!';
    subStatusMessage.value = 'Your item has been successfully delivered';
    progressValue.value = 1.0;

    // Navigate to delivery confirmation
    Timer(Duration(seconds: 2), () {
      _navigateToDeliveryConfirmation();
    });
  }

  /// Handle when delivery is cancelled
  Future<void> _handleCancelled() async {
    _stopPolling();
    statusMessage.value = 'Delivery Cancelled';
    subStatusMessage.value = 'This delivery has been cancelled';
    canCancel.value = false;

    // Navigate back to home
    Timer(Duration(seconds: 2), () {
      Get.offAllNamed('/home');
    });
  }

  /// Handle polling timeout
  void _handleTimeout() {
    _stopPolling();
    statusMessage.value = 'No Drivers Available';
    subStatusMessage.value =
        'We couldn\'t find any available drivers. Please try again later.';
    canCancel.value = true;
    progressValue.value = 1.0;

    // Show retry option
    Timer(Duration(seconds: 3), () {
      _showRetryDialog();
    });
  }

  /// Handle polling error
  void _handlePollingError() {
    if (_pollingAttempts >= 3) {
      statusMessage.value = 'Connection Error';
      subStatusMessage.value =
          'Having trouble connecting. Please check your internet connection.';
    }
  }

  /// Show retry dialog
  void _showRetryDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('No Drivers Available'),
        content: Text(
            'We couldn\'t find any available drivers at the moment. Would you like to try again?'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Get.back(); // Go back to home
            },
            child: Text('Go Back'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _retrySearch();
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Retry searching for drivers
  void _retrySearch() {
    if (_currentDeliveryId != null) {
      _pollingAttempts = 0;
      _resetStatus();
      _startPolling();
    }
  }

  /// Cancel delivery
  Future<void> cancelDelivery(String deliveryId) async {
    try {
      print('🔄 Cancelling delivery: $deliveryId');

      final response = await http.put(
        Uri.parse('$baseUrl/deliveries/$deliveryId/status'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'status': 'cancelled',
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Delivery cancelled successfully');
        _stopPolling();
        Get.back(); // Go back to previous screen
        Get.snackbar(
          'Delivery Cancelled',
          'Your delivery has been cancelled and you will be refunded.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        print('❌ Failed to cancel delivery: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Failed to cancel delivery. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Error cancelling delivery: $e');
      Get.snackbar(
        'Error',
        'Failed to cancel delivery. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Fetch driver details using driver ID
  Future<void> _fetchDriverDetails(String driverId) async {
    try {
      print('🔍 Fetching driver details for ID: $driverId');

      final driverResponse = await http.get(
        Uri.parse('$baseUrl/drivers/$driverId'),
        headers: await _getHeaders(),
      );

      if (driverResponse.statusCode == 200) {
        final driverData =
            jsonDecode(driverResponse.body) as Map<String, dynamic>;
        final driver =
            (driverData['driver'] as Map<String, dynamic>?) ?? driverData;

        // Update driver information
        driverName.value = driver['name'] ??
            '${driver['first_name'] ?? ''} ${driver['last_name'] ?? ''}'
                .trim() ??
            'Driver';
        driverPhone.value = driver['phone'] ?? driver['phone_number'] ?? '';
        driverRating.value = driver['rating']?.toString() ?? '4.5';
        estimatedArrival.value = driver['estimated_arrival'] ?? '5-10 minutes';

        print('✅ Driver details fetched successfully');
        print('👤 Driver: ${driverName.value}');
        print('📞 Phone: ${driverPhone.value}');
        print('⭐ Rating: ${driverRating.value}');
      } else {
        print(
            '⚠️ Failed to fetch driver details: ${driverResponse.statusCode}');
        // Set default values
        driverName.value = 'Driver';
        driverPhone.value = '';
        driverRating.value = '4.5';
        estimatedArrival.value = '5-10 minutes';
      }
    } catch (e) {
      print('❌ Error fetching driver details: $e');
      // Set default values
      driverName.value = 'Driver';
      driverPhone.value = '';
      driverRating.value = '4.5';
      estimatedArrival.value = '5-10 minutes';
    }
  }

  /// Fetch complete driver details and delivery information
  Future<void> _fetchCompleteDriverDetails() async {
    try {
      print('🔍 Fetching complete driver and delivery details...');

      // Fetch delivery details
      final deliveryResponse = await http.get(
        Uri.parse('$baseUrl/deliveries/$_currentDeliveryId'),
        headers: await _getHeaders(),
      );

      if (deliveryResponse.statusCode == 200) {
        final deliveryData =
            jsonDecode(deliveryResponse.body) as Map<String, dynamic>;
        final delivery =
            (deliveryData['delivery'] as Map<String, dynamic>?) ?? deliveryData;

        // Update delivery information
        deliveryId.value =
            delivery['id']?.toString() ?? _currentDeliveryId ?? '';
        pickupAddress.value = delivery['pickup_address'] ?? '';
        dropoffAddress.value = delivery['dropoff_address'] ?? '';
        itemName.value = delivery['item_name'] ?? '';
        trackingNumber.value = delivery['tracking_number'] ?? '';

        print('✅ Delivery details fetched successfully');
        print('📍 Pickup: ${pickupAddress.value}');
        print('📍 Dropoff: ${dropoffAddress.value}');
        print('📦 Item: ${itemName.value}');
        print('🔢 Tracking: ${trackingNumber.value}');

        // Extract driver ID from delivery data and fetch driver details
        final driverId = delivery['driver_id']?.toString();
        if (driverId != null && driverId.isNotEmpty) {
          // Store the driver ID
          _currentDriverId = driverId;

          final driverResponse = await http.get(
            Uri.parse('$baseUrl/drivers/$driverId'),
            headers: await _getHeaders(),
          );

          if (driverResponse.statusCode == 200) {
            final driverData =
                jsonDecode(driverResponse.body) as Map<String, dynamic>;
            final driver =
                (driverData['driver'] as Map<String, dynamic>?) ?? driverData;

            // Update driver information with complete details
            driverName.value = driver['name'] ?? driverName.value;
            driverPhone.value = driver['phone'] ?? driverPhone.value;
            driverRating.value =
                driver['rating']?.toString() ?? driverRating.value;
            estimatedArrival.value =
                driver['estimated_arrival'] ?? estimatedArrival.value;

            print('✅ Driver details fetched successfully');
            print('👤 Driver: ${driverName.value} (ID: $_currentDriverId)');
            print('📞 Phone: ${driverPhone.value}');
            print('⭐ Rating: ${driverRating.value}');
          } else {
            print(
                '⚠️ Failed to fetch driver details: ${driverResponse.statusCode}');
          }
        } else {
          print('⚠️ No driver ID found in delivery data');
        }
      } else {
        print(
            '⚠️ Failed to fetch delivery details: ${deliveryResponse.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching complete details: $e');
      // Continue with available data
    }
  }

  /// Navigate to customer tracking page
  void _navigateToCustomerTracking() {
    final currentDeliveryId = deliveryId.value.isNotEmpty
        ? deliveryId.value
        : _currentDeliveryId ?? '';

    if (currentDeliveryId.isNotEmpty) {
      // Initialize the tracking service
      Get.put(CustomerDeliveryTrackingService());

      // Navigate to the customer tracking page with complete data
      Get.offAll(() => CustomerDeliveryTrackingPage(
            deliveryId: int.parse(currentDeliveryId),
            initialData: {
              'delivery': {
                'id': int.parse(currentDeliveryId),
                'pickup_address': pickupAddress.value,
                'dropoff_address': dropoffAddress.value,
                'item_name': itemName.value,
                'tracking_number': trackingNumber.value,
                'created_at': DateTime.now().toIso8601String(),
                'status': 'accepted',
                'driver_id': _currentDriverId, // Add driver ID to delivery data
              },
              'driver': {
                'id': _currentDriverId, // Add driver ID to driver data
                'name': driverName.value,
                'phone': driverPhone.value,
                'rating': driverRating.value,
                'estimated_arrival': estimatedArrival.value,
              },
            },
          ));

      print(
          '✅ Navigated to customer tracking page with driver ID: $_currentDriverId');
    } else {
      print('❌ No delivery ID available, falling back to old tracking screen');
      // Fallback to old tracking screen
      Get.offAll(() => DriverTrackingScreen());
    }
  }

  /// Navigate to delivery confirmation
  void _navigateToDeliveryConfirmation() {
    Get.offAllNamed('/confirm-delivery');
  }

  /// Get headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
