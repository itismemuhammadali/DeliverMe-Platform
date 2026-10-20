import 'dart:io';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/models/car_model.dart';
import 'package:deliver_mee/src/common/services/delivery_service.dart';
import 'package:deliver_mee/src/common/services/location_service.dart';
import 'package:deliver_mee/src/common/services/pricing_service.dart';
import 'package:deliver_mee/src/feature/user/schedule/controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HomeController extends GetxController {
  static HomeController get to => Get.find<HomeController>();
  RxString tolocation = 'Please select dropoff location'.obs;
  RxString fromlocation = 'Please select pickup location'.obs;

  // Location coordinates
  RxDouble pickupLatitude = 0.0.obs;
  RxDouble pickupLongitude = 0.0.obs;
  RxDouble dropoffLatitude = 0.0.obs;
  RxDouble dropoffLongitude = 0.0.obs;

  // Delivery creation state
  RxBool isCreatingDelivery = false.obs;

  // Store delivery data from backend response
  final RxMap<String, dynamic> deliveryData = <String, dynamic>{}.obs;
  final RxString deliveryId = ''.obs;
  final RxString trackingNumber = ''.obs;
  RxString scheduledTime = ''.obs;
  final RxDouble deliveryPrice = 0.0.obs;
  RxString selectedVehicleType = 'cargo_van'.obs;
  RxDouble itemWeight = 5.0.obs;
  RxString itemName = ''.obs;
  RxString itemDescription = ''.obs;
  RxString specialInstructions = ''.obs;
  RxString deliveryType = 'standard'.obs;

  RxString scheduleType = 'scheduled'.obs;
  RxString deliveryPreference = 'attended'.obs;

  // Item dimensions
  RxDouble height = 0.0.obs;
  RxDouble length = 0.0.obs;
  RxDouble width = 0.0.obs;

  // Item photo handling
  Rx<File?> itemPhotoFile = Rx<File?>(null);

  // Scheduled delivery fields
  Rx<DateTime?> scheduledDate = Rx<DateTime?>(null);
  RxString timeSlot = ''.obs;

  // Location state
  RxBool isInitializingLocation = false.obs;
  RxBool hasLocationPermission = false.obs;

  // Delivery service
  late DeliveryService _deliveryService;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    // Initialize delivery service when needed (delayed until UI is ready)
    _initializeCurrentLocationSeamlessly();
  }

  /// Initialize current location as default "from" location (seamless)
  void _initializeCurrentLocationSeamlessly() {
    // Set default fallback immediately for seamless UX
    fromlocation.value = 'Current Location';

    // Initialize location in background without blocking UI
    _initializeCurrentLocation();
  }

  /// Initialize current location as default "from" location
  Future<void> _initializeCurrentLocation() async {
    if (isInitializingLocation.value)
      return; // Prevent multiple simultaneous calls

    try {
      isInitializingLocation.value = true;
      print('📍 Initializing current location...');

      final locationService = Get.find<LocationService>();

      // Check if we already have location permission
      hasLocationPermission.value = locationService.isLocationPermissionGranted;

      // Get current location
      final currentLocation = await locationService.getCurrentLocation();

      if (currentLocation != null &&
          currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        // Set current location as default "from" location
        final address = locationService.currentAddress.isNotEmpty
            ? locationService.currentAddress
            : 'Current Location';

        // Only use the geocoded address if it's valid, otherwise use coordinates
        if (locationService.currentAddress.isNotEmpty &&
            locationService.currentAddress != 'Current Location') {
          fromlocation.value = address;
        } else {
          // Use a more descriptive fallback that includes coordinates
          fromlocation.value =
              'Current Location (${currentLocation.latitude!.toStringAsFixed(4)}, ${currentLocation.longitude!.toStringAsFixed(4)})';
        }

        // Set coordinates for "from" location
        pickupLatitude.value = currentLocation.latitude!;
        pickupLongitude.value = currentLocation.longitude!;

        // Ensure "to" location is properly initialized
        if (tolocation.value == 'Please select dropoff location') {
          tolocation.value = 'Please select dropoff location';
        }

        // Ensure "from" location is different from "to" location
        if (fromlocation.value == tolocation.value) {
          fromlocation.value = address;
        }

        hasLocationPermission.value = true;

        print('✅ Default "from" location set to: ${fromlocation.value}');
        print('✅ "To" location initialized to: ${tolocation.value}');
        print(
            '📍 FROM Coordinates: ${pickupLatitude.value}, ${pickupLongitude.value}');
        print(
            '📍 TO Coordinates: ${dropoffLatitude.value}, ${dropoffLongitude.value}');
      } else {
        print('⚠️ Could not get current location, using fallback');
        // Use a more descriptive fallback
        fromlocation.value = 'Please select pickup location';
        tolocation.value = 'Please select dropoff location';
      }
    } catch (e) {
      print('❌ Error initializing current location: $e');
      // Keep the fallback "Current Location" that was set immediately
    } finally {
      isInitializingLocation.value = false;
    }
  }

  List<CarModel> carslist = [
    // CarModel(
    //   id: '1',
    //   image: AppImages.carimg,
    //   imagesecond: AppImages.carimgr,
    //   largebagcount: "1 Large Bag",
    //   name: "Car",
    //   pickuptime: "Pickup in 6 min",
    //   smallbagcount: "3-20 small Bag",
    // ),
    // CarModel(
    //   id: '2',
    //   image: AppImages.suvsimg,
    //   imagesecond: AppImages.suvsimgr,
    //   largebagcount: "2-12 Large Bag",
    //   name: "SUV",
    //   pickuptime: "Pickup in 6 min",
    //   smallbagcount: "4-10 Small Bag",
    // ),
    CarModel(
      id: '3',
      image: AppImages.cargovanimg,
      imagesecond: AppImages.cargovanimgr,
      largebagcount: "15-50 Large Bag",
      name: "Cargo Van",
      pickuptime: "Pickup in 6 min",
      smallbagcount: "30-100 Small Bag",
    ),
    CarModel(
      id: '4',
      image: AppImages.pickuptruckimg,
      imagesecond: AppImages.pickuptruckimgr,
      largebagcount: "7-17 Large Bag",
      name: "Pickup Truck",
      pickuptime: "Pickup in 6 min",
      smallbagcount: "15-35 Small Bag",
    ),
    // Box Truck - Commented out (only Cargo Van and Pickup Truck available)
    // CarModel(
    //   id: '5',
    //   image: AppImages.boxtruckimg,
    //   imagesecond: AppImages.boxtruckimgr,
    //   largebagcount: "25-75 Large Bag",
    //   name: "Box Truck",
    //   pickuptime: "Pickup in 6 min",
    //   smallbagcount: "50-150 Small Bag",
    // ),
  ];

  /// Update pickup location
  void updateFromLocation(String address, double? latitude, double? longitude) {
    print('🔄 Updating FROM location: $address');
    fromlocation.value = address;
    if (latitude != null && longitude != null) {
      pickupLatitude.value = latitude;
      pickupLongitude.value = longitude;
      print('📍 FROM coordinates: $latitude, $longitude');
      print('✅ FROM coordinates set successfully');
    } else {
      print(
          '⚠️ FROM coordinates are null - latitude: $latitude, longitude: $longitude');
    }
  }

  /// Update dropoff location
  void updateToLocation(String address, double? latitude, double? longitude) {
    print('🔄 Updating TO location: $address');
    tolocation.value = address;
    if (latitude != null && longitude != null) {
      dropoffLatitude.value = latitude;
      dropoffLongitude.value = longitude;
      print('📍 TO coordinates: $latitude, $longitude');
      print('✅ TO coordinates set successfully');
    } else {
      print(
          '⚠️ TO coordinates are null - latitude: $latitude, longitude: $longitude');
    }
  }

  /// Validate delivery data - returns null if valid, error message if invalid
  String? validateDeliveryData() {
    if (fromlocation.value.isEmpty || fromlocation.value == 'Please select pickup location') {
      return 'Please select a pickup location';
    }

    if (tolocation.value.isEmpty || tolocation.value == 'Please select dropoff location') {
      return 'Please select a dropoff location';
    }

    if (itemName.value.isEmpty) {
      return 'Please enter an item name';
    }

    if (itemWeight.value <= 0) {
      return 'Please enter a valid item weight';
    }

    if (selectedVehicleType.value.isEmpty) {
      return 'Please select a vehicle type';
    }

    if (itemPhotoFile.value == null) {
      return 'Please upload a photo of your item';
    }

    if (height.value <= 0) {
      return 'Please enter the item height';
    }

    if (length.value <= 0) {
      return 'Please enter the item length';
    }

    if (width.value <= 0) {
      return 'Please enter the item width';
    }

    if (scheduleType.value == 'scheduled' && scheduledDate.value == null) {
      return 'Please select a delivery date';
    }

    if (scheduleType.value == 'scheduled' && timeSlot.value.isEmpty) {
      return 'Please select a time slot';
    }

    return null;
  }

  /// Create delivery - returns null on success, error message on failure
  Future<String?> createDelivery() async {
    final validationError = validateDeliveryData();
    if (validationError != null) return validationError;

    // Capture the photo file locally NOW so it doesn't get cleared by a race condition
    final File? localPhotoFile = itemPhotoFile.value;

    // DEBUG: Check if photo file exists before creating delivery
    print('🔍 DEBUG: localPhotoFile = $localPhotoFile');
    if (localPhotoFile != null) {
      print('🔍 DEBUG: localPhotoFile path = ${localPhotoFile.path}');
    }

    try {
      isCreatingDelivery.value = true;

      // Initialize delivery service when needed
      _deliveryService = Get.find<DeliveryService>();

      print('🚀 Starting delivery creation...');
      print('📍 From: ${fromlocation.value}');
      print('📍 To: ${tolocation.value}');
      print('📦 Item: ${itemName.value}');
      print('📝 Description: ${itemDescription.value}');
      print('🚛 Vehicle: ${selectedVehicleType.value}');
      print('⚖️ Weight: ${itemWeight.value} lbs');
      print('🚚 Delivery Type: ${deliveryType.value}');
      print('📅 Schedule Type: ${scheduleType.value}');

      final result = await _deliveryService.createDelivery(
        pickupAddress: fromlocation.value,
        dropoffAddress: tolocation.value,
        pickupLatitude: pickupLatitude.value > 0 ? pickupLatitude.value : null,
        pickupLongitude:
            pickupLongitude.value > 0 ? pickupLongitude.value : null,
        dropoffLatitude:
            dropoffLatitude.value > 0 ? dropoffLatitude.value : null,
        dropoffLongitude:
            dropoffLongitude.value > 0 ? dropoffLongitude.value : null,
        itemName: itemName.value,
        itemDescription:
            itemDescription.value.isNotEmpty ? itemDescription.value : null,
        itemPhotoFile: localPhotoFile, // Use the captured local file
        vehicleType: selectedVehicleType.value,
        weight: itemWeight.value,
        width: width.value > 0 ? width.value : null,
        height: height.value > 0 ? height.value : null,
        length: length.value > 0 ? length.value : null,
        specialInstructions: specialInstructions.value.isNotEmpty
            ? specialInstructions.value
            : null,
        deliveryType: deliveryType.value,
        scheduleType: scheduleType.value,
        scheduledDate: scheduledDate.value,
        timeSlot: timeSlot.value.isNotEmpty ? timeSlot.value : null,
        deliveryPreference: deliveryPreference.value,
      );

      print('📡 Delivery creation result: $result');

      if (result['success']) {
        final responseData = result['data'];
        final trackingNum = result['tracking_number'] ??
            responseData['tracking_number'] ??
            responseData['id'] ??
            'N/A';

        // Store delivery data for use in payment screen
        deliveryData.value = responseData;
        trackingNumber.value = trackingNum;

        // Extract delivery ID
        if (responseData['delivery'] != null &&
            responseData['delivery']['id'] != null) {
          deliveryId.value = responseData['delivery']['id'].toString();
        } else if (responseData['id'] != null) {
          deliveryId.value = responseData['id'].toString();
        }

        // Extract scheduled time information
        if (responseData['delivery'] != null &&
            responseData['delivery']['scheduled_time'] != null) {
          scheduledTime.value = responseData['delivery']['scheduled_time'];
        } else if (responseData['scheduled_time'] != null) {
          scheduledTime.value = responseData['scheduled_time'];
        } else if (scheduleType == 'scheduled' &&
            scheduledDate.value != null &&
            timeSlot.value.isNotEmpty) {
          // Format scheduled time from our data
          final date = scheduledDate.value!;
          scheduledTime.value =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} at $timeSlot';
        }

        // Extract estimated cost from delivery response - try multiple possible fields
        double estimatedCost = 0.0;
        print('🔍 Searching for cost in delivery response...');
        print('🔍 Response structure: $responseData');

        // Try different possible field names for cost
        if (responseData['delivery'] != null) {
          final delivery = responseData['delivery'];
          if (delivery['estimated_fare'] != null) {
            estimatedCost = delivery['estimated_fare'].toDouble();
            print('💰 Found cost in delivery.estimated_fare: $estimatedCost');
          } else if (delivery['estimated_cost'] != null) {
            estimatedCost = delivery['estimated_cost'].toDouble();
            print('💰 Found cost in delivery.estimated_cost: $estimatedCost');
          } else if (delivery['cost'] != null) {
            estimatedCost = delivery['cost'].toDouble();
            print('💰 Found cost in delivery.cost: $estimatedCost');
          } else if (delivery['total_cost'] != null) {
            estimatedCost = delivery['total_cost'].toDouble();
            print('💰 Found cost in delivery.total_cost: $estimatedCost');
          } else if (delivery['price'] != null) {
            estimatedCost = delivery['price'].toDouble();
            print('💰 Found cost in delivery.price: $estimatedCost');
          }
        }

        // Try top-level fields
        if (estimatedCost == 0.0) {
          if (responseData['estimated_fare'] != null) {
            estimatedCost = responseData['estimated_fare'].toDouble();
            print('💰 Found cost in top-level estimated_fare: $estimatedCost');
          } else if (responseData['estimated_cost'] != null) {
            estimatedCost = responseData['estimated_cost'].toDouble();
            print('💰 Found cost in estimated_cost: $estimatedCost');
          } else if (responseData['cost'] != null) {
            estimatedCost = responseData['cost'].toDouble();
            print('💰 Found cost in cost: $estimatedCost');
          } else if (responseData['total_cost'] != null) {
            estimatedCost = responseData['total_cost'].toDouble();
            print('💰 Found cost in total_cost: $estimatedCost');
          } else if (responseData['price'] != null) {
            estimatedCost = responseData['price'].toDouble();
            print('💰 Found cost in price: $estimatedCost');
          }
        }

        // If still no cost found, try to extract from any numeric field that might be the cost
        if (estimatedCost == 0.0) {
          print(
              '⚠️ No cost found in expected fields, searching for any numeric value...');
          for (String key in responseData.keys) {
            if (responseData[key] is num && responseData[key] > 0) {
              print('🔍 Found numeric value in $key: ${responseData[key]}');
              // If it's a reasonable delivery cost (between $5 and $500)
              if (responseData[key] >= 5.0 && responseData[key] <= 500.0) {
                estimatedCost = responseData[key].toDouble();
                print('💰 Using $key as cost: $estimatedCost');
                break;
              }
            }
          }
        }

        // Store delivery price for use in payment screen (similar to deliveryId)
        deliveryPrice.value = estimatedCost;

        print('✅ Delivery created successfully!');
        print('📦 Delivery data: $responseData');
        print('📦 Tracking Number: $trackingNum');
        print('📦 Delivery ID: ${deliveryId.value}');
        print('📦 Scheduled Time: ${scheduledTime.value}');
        print('💰 Delivery Price: \$${deliveryPrice.value.toStringAsFixed(2)}');

        // Update pricing service with estimated cost from delivery response
        if (estimatedCost > 0) {
          final pricingService = Get.find<PricingService>();
          pricingService.setPricingFromDeliveryData(responseData);
          print(
              '💰 Updated pricing service with estimated cost: \$${estimatedCost.toStringAsFixed(2)}');
        } else {
          // Fallback: If no cost found in response, try to use a reasonable default based on $30 base
          print('⚠️ No cost found in delivery response, using base default');
          final pricingService = Get.find<PricingService>();
          pricingService.setDefaultPricing();
          deliveryPrice.value = pricingService.totalFare.value;
          print('💰 Set default base cost: \$${deliveryPrice.value}');
        }

        // Don't show snackbar here - the UI will navigate to payment screen
        // Snackbar requires an Overlay context which may not be available
        // The success is confirmed by navigation to the payment screen
        print('✅ Delivery created successfully, returning to UI for navigation');

        // Reset form
        resetDeliveryForm();
        
        // Refresh schedule controller to show the newly created delivery
        try {
          if (Get.isRegistered<CustomerScheduleController>()) {
            final scheduleCtrl = Get.find<CustomerScheduleController>();
            print('🔄 Refreshing schedule controller after delivery creation...');
            await scheduleCtrl.refreshDeliveries();
            print('✅ Schedule controller refreshed successfully');
          }
        } catch (e) {
          print('⚠️ Could not refresh schedule controller: $e');
        }
        
        return null; // Success
      } else {
        print('❌ Delivery creation failed: ${result['error']}');
        return result['error'] ?? 'Failed to create delivery. Please try again.';
      }
    } catch (e) {
      print('❌ Delivery creation error: $e');
      return 'Something went wrong. Please check your connection and try again.';
    } finally {
      isCreatingDelivery.value = false;
    }
  }

  /// Reset delivery form
  void resetDeliveryForm() {
    itemName.value = '';
    itemDescription.value = '';
    itemPhotoFile.value = null; // Clear the photo from previous delivery
    itemWeight.value = 5.0;
    height.value = 0.0;
    length.value = 0.0;
    width.value = 0.0;
    specialInstructions.value = '';
    // Keep vehicle and delivery types as is or reset to defaults
    // Keep locations as they are to avoid confusing resets
    
    print('🧹 Delivery form fields reset (locations preserved)');
  }

  /// Clear delivery data (for starting fresh)
  void clearDeliveryData() {
    deliveryData.clear();
    deliveryId.value = '';
    trackingNumber.value = '';
    scheduledTime.value = '';
    deliveryPrice.value = 0.0;
    print('🧹 Cleared delivery data');
  }

  /// Ensure locations are properly set for payment screen
  void ensureLocationsForPayment() {
    print('📍 Ensuring locations are properly set for payment screen...');
    print('📍 Current FROM: ${fromlocation.value}');
    print('📍 Current TO: ${tolocation.value}');

    // If locations are literally empty strings, set descriptive placeholders
    if (fromlocation.value.isEmpty) {
      fromlocation.value = 'Please select pickup location';
    }

    if (tolocation.value.isEmpty) {
      tolocation.value = 'Please select dropoff location';
    }

    // Don't force "Current Location" here as it might overwrite a specific address the user selected
    
    print('✅ Locations checked for payment screen');
    print('📍 Final FROM: ${fromlocation.value}');
    print('📍 Final TO: ${tolocation.value}');
  }

  /// Set vehicle type
  void setVehicleType(String vehicleType) {
    selectedVehicleType.value = vehicleType;
    print('🚛 Vehicle type set to: $vehicleType');

    // Special debugging for Cargo Van
    if (vehicleType == 'cargo_van') {
      print('🚐 Cargo Van selected - vehicle type confirmed');
    }
  }

  /// Set delivery type
  void setDeliveryType(String type) {
    deliveryType.value = type;
    print('🚚 Delivery type set to: $type');
  }

  /// Set schedule type
  void setScheduleType(String type) {
    scheduleType.value = type;
  }

  /// Set scheduled date
  void setScheduledDate(DateTime? date) {
    scheduledDate.value = date;
  }

  /// Set time slot
  void setTimeSlot(String slot) {
    timeSlot.value = slot;
  }

  /// Set item details from car selection
  void setItemDetails({
    required double weight,
  }) {
    itemWeight.value = weight;
    print(
        '📦 Item details set - Weight: $weight');
  }

  /// Set item name and description
  void setItemInfo({
    required String itemName,
    String? itemDescription,
  }) {
    this.itemName.value = itemName;
    if (itemDescription != null) {
      this.itemDescription.value = itemDescription;
    }
    print('📝 Item info set - Name: $itemName, Description: $itemDescription');
  }

  /// Refresh current location as "to" location
  Future<void> refreshCurrentLocation() async {
    if (isInitializingLocation.value)
      return; // Prevent multiple simultaneous calls

    try {
      isInitializingLocation.value = true;
      print('🔄 Refreshing current location...');

      final locationService = Get.find<LocationService>();

      // Get fresh current location
      final currentLocation = await locationService.getCurrentLocation();

      if (currentLocation != null &&
          currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        // Update "to" location with fresh data
        final address = locationService.currentAddress.isNotEmpty
            ? locationService.currentAddress
            : 'Current Location';

        tolocation.value = address;

        // Update coordinates for "to" location
        dropoffLatitude.value = currentLocation.latitude!;
        dropoffLongitude.value = currentLocation.longitude!;

        hasLocationPermission.value = true;

        print('✅ "To" location refreshed to: ${tolocation.value}');
        print(
            '📍 New coordinates: ${dropoffLatitude.value}, ${dropoffLongitude.value}');
      } else {
        print('⚠️ Could not refresh current location, keeping current value');
      }
    } catch (e) {
      print('❌ Error refreshing current location: $e');
      // Keep current value on error
    } finally {
      isInitializingLocation.value = false;
    }
  }

  /// Set "to" location to current location (for UI button)
  Future<void> setToCurrentLocation() async {
    await refreshCurrentLocation();
  }

  /// Request location permission seamlessly
  Future<bool> requestLocationPermission() async {
    try {
      print('🔐 Requesting location permission...');
      final locationService = Get.find<LocationService>();

      final granted = await locationService.requestLocationPermission();
      hasLocationPermission.value = granted;

      if (granted) {
        print('✅ Location permission granted');
        // Try to get location after permission is granted
        await refreshCurrentLocation();
        return true;
      } else {
        print('❌ Location permission denied');
        return false;
      }
    } catch (e) {
      print('❌ Error requesting location permission: $e');
      return false;
    }
  }

  /// Check if location is available and working
  bool get isLocationAvailable =>
      hasLocationPermission.value &&
      dropoffLatitude.value != 0.0 &&
      dropoffLongitude.value != 0.0;

  /// Get location status for UI
  String get locationStatus {
    if (isInitializingLocation.value) return 'Getting location...';
    if (hasLocationPermission.value && isLocationAvailable)
      return 'Location ready';
    if (!hasLocationPermission.value) return 'Location permission needed';
    return 'Location unavailable';
  }

  /// Set item photo file
  void setItemPhotoFile(File? photoFile) {
    itemPhotoFile.value = photoFile;
    if (photoFile != null) {
      print('📸 Item photo file set: ${photoFile.path}');
    } else {
      print('⚠️ Item photo file cleared');
    }
  }
}
