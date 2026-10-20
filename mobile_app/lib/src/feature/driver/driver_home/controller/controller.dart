import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/services/driver_auth_service.dart';
import '../../../../common/services/driver_location_service.dart';
import '../../../../common/services/driver_notification_service.dart';
import '../../../../common/services/driver_api_service.dart';
import '../../../../models/driver_model.dart';
import '../../../../models/delivery_model.dart';
import '../../driver_bottom_bar/controller/driver_bottom_bar_controller.dart';
import '../../driver_bottom_bar/pages/driver_bottom_bar_screen.dart';
import '../../driver_schedule/controller/driver_schedule_controller.dart';
import '../widget/image_viewer_dialog.dart';

class DriverHomeController extends GetxController {
  static DriverHomeController get to => Get.find<DriverHomeController>();

  // Services
  final DriverAuthService _authService = DriverAuthService.to;
  final DriverLocationService _locationService = DriverLocationService.to;
  final DriverNotificationService _notificationService =
      DriverNotificationService.to;

  // Driver state
  final Rx<DriverModel?> currentDriver = Rx<DriverModel?>(null);
  final RxBool isAvailable = false.obs;
  final RxString driverStatus = 'offline'.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Delivery requests state
  final RxList<DeliveryModel> deliveryRequests = <DeliveryModel>[].obs;
  final RxBool isLoadingDeliveries = false.obs;
  final RxString deliveryError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDriver();
  }

  /// Initialize driver data
  Future<void> _initializeDriver() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Check if driver is logged in
      final isLoggedIn = await _authService.checkLoginStatus();
      if (!isLoggedIn) {
        error.value = 'Driver not logged in';
        return;
      }

      // Get current driver
      currentDriver.value = _authService.driver;
      if (currentDriver.value != null) {
        isAvailable.value = currentDriver.value!.isAvailable;
        driverStatus.value = currentDriver.value!.status;
      }

      // Start location tracking
      await _locationService.startLocationTracking();

      // Load notifications
      await _notificationService.loadNotifications();

      // Load delivery requests
      await loadDeliveryRequests();

      print('✅ Driver home initialized');
    } catch (e) {
      print('❌ Error initializing driver home: $e');
      error.value = 'Error initializing: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle driver availability
  Future<void> toggleAvailability() async {
    try {
      isLoading.value = true;
      error.value = '';

      final newAvailability = !isAvailable.value;

      // Update availability on server (not just locally)
      await DriverApiService.updateAvailability(isAvailable: newAvailability);

      // Refresh profile from server so local state matches backend
      final updatedDriver = await DriverApiService.getProfile();
      currentDriver.value = updatedDriver;

      // Update local state
      isAvailable.value = currentDriver.value?.isAvailable ?? newAvailability;
      driverStatus.value = currentDriver.value?.status ??
          (newAvailability ? 'available' : 'offline');

      print('✅ Driver availability updated to: $newAvailability');
    } catch (e) {
      print('❌ Error toggling availability: $e');
      error.value = 'Error updating availability: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Update driver status
  Future<void> updateStatus(String status) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Update status on server (not just locally)
      await DriverApiService.updateStatus(status: status);

      // Refresh profile from server so local state matches backend
      final updatedDriver = await DriverApiService.getProfile();
      currentDriver.value = updatedDriver;

      // Update local state
      driverStatus.value = currentDriver.value?.status ?? status;

      print('✅ Driver status updated to: $status');
    } catch (e) {
      print('❌ Error updating status: $e');
      error.value = 'Error updating status: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh driver data
  Future<void> refreshDriverData() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Refresh profile from server
      await _authService.refreshProfile();

      // Update local state
      currentDriver.value = _authService.driver;
      if (currentDriver.value != null) {
        isAvailable.value = currentDriver.value!.isAvailable;
        driverStatus.value = currentDriver.value!.status;
      }

      print('✅ Driver data refreshed');
    } catch (e) {
      print('❌ Error refreshing driver data: $e');
      error.value = 'Error refreshing data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Get driver name
  String get driverName => _authService.driverName;

  /// Get driver email
  String get driverEmail => _authService.driverEmail;

  /// Get driver phone
  String get driverPhone => _authService.driverPhone;

  /// Get vehicle info
  String get vehicleInfo => _authService.vehicleInfo;

  /// Get driver rating
  double? get rating => _authService.rating;

  /// Get total rides
  int? get totalRides => _authService.totalRides;

  /// Get current location
  Map<String, double?> get currentLocation {
    final pos = _locationService.currentPosition.value;
    if (pos == null) return {'latitude': null, 'longitude': null};
    return {'latitude': pos['latitude'], 'longitude': pos['longitude']};
  }

  /// Get unread notification count
  int get unreadNotificationCount => _notificationService.unreadCount.value;

  /// Check if driver is online
  bool get isOnline =>
      driverStatus.value == 'available' || driverStatus.value == 'busy';

  /// Check if driver is busy
  bool get isBusy => driverStatus.value == 'busy';

  /// Check if driver is offline
  bool get isOffline => driverStatus.value == 'offline';

  /// Load delivery requests from API
  Future<void> loadDeliveryRequests() async {
    try {
      isLoadingDeliveries.value = true;
      deliveryError.value = '';

      print('🔄 Loading delivery requests...');

      final response = await DriverApiService.getAssignedDeliveries(
        limit: 20,
        offset: 0,
      );

      // Filter to only show available deliveries (status: 'requested')
      // These are deliveries waiting for a driver to accept them
      final availableDeliveries = response.deliveries
          .where((d) => d.status.toLowerCase() == 'requested')
          .toList();

      deliveryRequests.value = availableDeliveries;

      print('✅ Loaded ${availableDeliveries.length} delivery requests (filtered from ${response.deliveries.length} total)');
    } catch (e) {
      print('❌ Error loading delivery requests: $e');
      if (e is DriverApiError) {
        deliveryError.value = e.error;
      } else {
        deliveryError.value = 'Error loading deliveries: ${e.toString()}';
      }
    } finally {
      isLoadingDeliveries.value = false;
    }
  }

  /// Refresh delivery requests
  Future<void> refreshDeliveryRequests() async {
    await loadDeliveryRequests();

    // Show success message
    Get.snackbar(
      'Refreshed',
      'Delivery requests updated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  /// Refresh all data (deliveries, notifications, driver status)
  Future<void> refreshAllData() async {
    try {
      print('🔄 Refreshing all driver data...');

      // Refresh delivery requests
      await loadDeliveryRequests();

      // Refresh notifications
      await _notificationService.loadNotifications();

      // Refresh driver profile
      try {
        final updatedDriver = await DriverApiService.getProfile();
        currentDriver.value = updatedDriver;
        if (currentDriver.value != null) {
          isAvailable.value = currentDriver.value!.isAvailable;
          driverStatus.value = currentDriver.value!.status;
        }
        print('✅ Driver profile refreshed');
      } catch (e) {
        print('⚠️ Error refreshing driver profile: $e');
      }

      print('✅ All data refreshed successfully');

      // Show success message
      Get.snackbar(
        'All Data Refreshed',
        'Deliveries, notifications, and profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } catch (e) {
      print('❌ Error refreshing all data: $e');
      // Still show error for delivery requests if that's the main issue
      deliveryError.value = 'Error refreshing data: $e';

      // Show error message
      Get.snackbar(
        'Refresh Error',
        'Failed to refresh some data: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  /// Accept delivery request
  Future<void> acceptDelivery(DeliveryModel delivery) async {
    try {
      isLoading.value = true;
      error.value = '';

      print('🚀 Accepting delivery: ${delivery.id}');

      // Ensure driver is available/online on the backend before accepting.
      // Some backend rules reject acceptance if driver is offline/unavailable.
      if (!isAvailable.value || isOffline) {
        try {
          await DriverApiService.updateAvailability(isAvailable: true);
          await DriverApiService.updateStatus(status: 'available');

          // Refresh profile to sync local state
          final updatedDriver = await DriverApiService.getProfile();
          currentDriver.value = updatedDriver;
          isAvailable.value = updatedDriver.isAvailable;
          driverStatus.value = updatedDriver.status;
          print('✅ Driver marked available before accept');
        } catch (e) {
          // Don’t block acceptance attempt; backend may still allow it.
          print('⚠️ Could not update availability/status before accept: $e');
        }
      }

      // Call the accept delivery API
      final response = await DriverApiService.acceptDelivery(delivery.id);

      if (response['success'] == true) {
        print('✅ Delivery accepted successfully');
        print('📦 Full API Response: $response');
        print(
            '📍 Pickup Location: ${response['next_steps']?['pickup_location']}');
        print(
            '📍 Dropoff Location: ${response['next_steps']?['dropoff_location']}');

        // Remove from requests list
        deliveryRequests.removeWhere((d) => d.id == delivery.id);

        // Add to Scheduled deliveries locally with status ACCEPTED
        try {
          if (!Get.isRegistered<DriverScheduleController>()) {
            Get.put(DriverScheduleController());
          }
          final scheduleCtrl = Get.find<DriverScheduleController>();

          final acceptedJson = Map<String, dynamic>.from(delivery.toJson());
          acceptedJson['status'] = 'accepted';
          acceptedJson['driver_id'] =
              (currentDriver.value?.id ?? acceptedJson['driver_id']);
          final acceptedDelivery = DeliveryModel.fromJson(acceptedJson);

          scheduleCtrl.addAcceptedDelivery(acceptedDelivery);
          
          // Also load from backend to ensure we have the latest data
          print('🔄 Loading accepted deliveries from backend...');
          await scheduleCtrl.loadDeliveries(refresh: true);
        } catch (e) {
          print('⚠️ Could not add delivery to scheduled list: $e');
        }

        // Show success message
        Get.snackbar(
          'Success',
          'Delivery accepted successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        // After accept: take driver to Scheduled tab (not start delivery).
        if (!Get.isRegistered<DriverBottomBarController>()) {
          Get.put(DriverBottomBarController(), permanent: true);
        }
        DriverBottomBarController.to.setSelectedIndex(2);
        Get.offAll(() => DriverBottomBarScreen(),
            transition: Transition.cupertino);
      } else {
        throw Exception(response['error'] ?? 'Failed to accept delivery');
      }
    } catch (e) {
      print('❌ Error accepting delivery: $e');
      error.value = 'Error accepting delivery: $e';

      // If acceptance fails, refresh requests so UI doesn’t keep stale items
      try {
        await loadDeliveryRequests();
      } catch (_) {}

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to accept delivery: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Reject delivery request
  Future<void> rejectDelivery(DeliveryModel delivery) async {
    try {
      isLoading.value = true;
      error.value = '';

      print('🚀 Rejecting delivery: ${delivery.id}');

      // Prevent rejecting deliveries that have already been accepted
      final status = delivery.status.toLowerCase();
      if (status == 'accepted' || status == 'picked_up' || status == 'in_transit' || status == 'completed') {
        throw Exception('Cannot reject a delivery with status: $status. Only confirmed deliveries can be rejected.');
      }

      // Call the reject delivery API
      final response = await DriverApiService.rejectDelivery(delivery.id);

      if (response['success'] == true) {
        print('✅ Delivery rejected successfully');

        // Remove from requests list
        deliveryRequests.removeWhere((d) => d.id == delivery.id);

        // Show success message
        Get.snackbar(
          'Success',
          'Delivery rejected successfully!',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else {
        throw Exception(response['error'] ?? 'Failed to reject delivery');
      }
    } catch (e) {
      print('❌ Error rejecting delivery: $e');
      error.value = 'Error rejecting delivery: $e';

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to reject delivery: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// View item photo for a delivery
  Future<void> viewItemPhoto(DeliveryModel delivery, BuildContext context) async {
    try {
      print('📸 Viewing item photo for delivery: ${delivery.id}');
      print('📸 Item photo URL from delivery: ${delivery.itemPhotoUrl}');

      // Check if delivery has a photo
      if (delivery.itemPhotoUrl == null || delivery.itemPhotoUrl!.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This delivery does not have an item photo'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Construct the full photo URL
      String photoUrl = delivery.itemPhotoUrl!;
      
      // If it's a relative path (object key), construct full URL
      if (!photoUrl.startsWith('http')) {
        // Use Firebase Storage public URL format
        final bucketName = 'delivermee-12c26.firebasestorage.app';
        photoUrl = 'https://firebasestorage.googleapis.com/v0/b/$bucketName/o/${Uri.encodeComponent(photoUrl)}?alt=media';
      }

      print('📸 Full photo URL: $photoUrl');

      // Show image in dialog using the provided context
      if (context.mounted) {
        ImageViewerDialog.show(
          context,
          photoUrl,
          title: 'Item Photo - Delivery #${delivery.id}',
        );
        print('✅ Photo dialog opened successfully');
      } else {
        throw Exception('Context not available');
      }
    } catch (e) {
      print('❌ Error viewing item photo: $e');

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to view item photo: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
