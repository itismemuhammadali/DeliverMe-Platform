import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';

import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/models/car_model.dart';
import 'package:deliver_mee/src/feature/user/home/controller/controller.dart';

class CarController extends GetxController {
  static CarController get to => Get.find<CarController>();

  RxInt selectedindex = 0.obs;
  RxBool iscontinuetab = false.obs;

  // Dynamic distance and time
  RxDouble calculatedDistance = 0.0.obs;
  RxDouble calculatedTime = 0.0.obs;
  RxBool isCalculatingDistance = false.obs;

  void onchangeselectedindex(int index) {
    selectedindex.value = index;
  }

  var selectedSize = 0.obs;
  var itemCount = 1.obs;
  var itemWeight = 1.obs;

  TextEditingController weightCtrl = TextEditingController();

  List<String> sizes = [
    'Small\n10"',
    'Medium\n40"',
    'Large\n48"',
    'XL\n60"',
    'Oversized\n84"'
  ];

  void incrementItem() {
    itemCount.value++;
  }

  void decrementItem() {
    if (itemCount.value > 1) itemCount.value--;
  }

  void incrementWeight() {
    itemWeight.value++;
    weightCtrl.text = itemWeight.value.toString() + 'Lb';
    update(['weight Update']);
  }

  void decrementWeight() {
    if (itemWeight.value > 1) itemWeight.value--;
    weightCtrl.text = itemWeight.value.toString() + 'Lb';
    update(['weight Update']);
  }

  void selectSize(int index) => selectedSize.value = index;

  /// Calculate distance between two coordinates using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2));

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c; // Distance in kilometers

    return distance;
  }

  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Get coordinates from address using geocoding
  Future<Map<String, double>?> _getCoordinatesFromAddress(
      String address) async {
    try {
      print('🌍 Geocoding address: $address');
      final locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final location = locations.first;
        print(
            '✅ Coordinates found: ${location.latitude}, ${location.longitude}');
        return {
          'latitude': location.latitude,
          'longitude': location.longitude,
        };
      } else {
        print('❌ No coordinates found for address: $address');
        return null;
      }
    } catch (e) {
      print('❌ Error geocoding address: $e');
      return null;
    }
  }

  /// Calculate estimated delivery time based on distance and vehicle type
  double _calculateEstimatedTime(double distanceKm, String vehicleType) {
    // Base speeds for different vehicle types (km/h)
    final Map<String, double> vehicleSpeeds = {
      'car': 30.0, // City driving speed
      'suv': 28.0, // Slightly slower due to size
      'pickup_truck': 25.0, // Slower due to size and weight
      'van': 22.0, // Cargo van - slower due to size and weight
      'cargo_van': 22.0, // Same as van
    };

    // Get speed for vehicle type, default to 25 km/h
    final speed = vehicleSpeeds[vehicleType.toLowerCase()] ?? 25.0;

    // Calculate time in hours
    final timeHours = distanceKm / speed;

    // Convert to minutes and add buffer time
    final timeMinutes = (timeHours * 60) + 15; // Add 15 minutes buffer

    return timeMinutes;
  }

  /// Calculate distance and time based on current locations
  Future<void> calculateDistanceAndTime() async {
    try {
      isCalculatingDistance.value = true;

      final homeController = Get.find<HomeController>();

      // Debug: Print all coordinate values
      print('🔍 DEBUG: Pickup Lat: ${homeController.pickupLatitude.value}');
      print('🔍 DEBUG: Pickup Lng: ${homeController.pickupLongitude.value}');
      print('🔍 DEBUG: Dropoff Lat: ${homeController.dropoffLatitude.value}');
      print('🔍 DEBUG: Dropoff Lng: ${homeController.dropoffLongitude.value}');
      print('🔍 DEBUG: From Location: ${homeController.fromlocation.value}');
      print('🔍 DEBUG: To Location: ${homeController.tolocation.value}');

      // Check if we have valid coordinates
      if (homeController.pickupLatitude.value > 0 &&
          homeController.pickupLongitude.value > 0 &&
          homeController.dropoffLatitude.value > 0 &&
          homeController.dropoffLongitude.value > 0) {
        print('✅ Valid coordinates found, calculating distance...');

        // Calculate distance
        final distance = _calculateDistance(
          homeController.pickupLatitude.value,
          homeController.pickupLongitude.value,
          homeController.dropoffLatitude.value,
          homeController.dropoffLongitude.value,
        );

        calculatedDistance.value = distance;

        // Get current vehicle type
        final vehicleType = homeController.selectedVehicleType.value;
        print('🔍 DEBUG: Vehicle Type: $vehicleType');

        // Calculate time
        final time = _calculateEstimatedTime(distance, vehicleType);
        calculatedTime.value = time;

        print('📏 Distance calculated: ${distance.toStringAsFixed(1)} km');
        print('⏱️ Time calculated: ${time.toStringAsFixed(0)} min');
      } else {
        print('⚠️ No valid coordinates available for distance calculation');
        print('⚠️ Pickup Lat > 0: ${homeController.pickupLatitude.value > 0}');
        print('⚠️ Pickup Lng > 0: ${homeController.pickupLongitude.value > 0}');
        print(
            '⚠️ Dropoff Lat > 0: ${homeController.dropoffLatitude.value > 0}');
        print(
            '⚠️ Dropoff Lng > 0: ${homeController.dropoffLongitude.value > 0}');

        // Try to get coordinates from addresses if available
        if (homeController.fromlocation.value !=
                'Please select pickup location' &&
            homeController.tolocation.value !=
                'Please select dropoff location') {
          print(
              '🔄 Attempting to geocode addresses for distance calculation...');
          _calculateDistanceFromAddresses(homeController);
        } else {
          print('⚠️ No valid addresses available for geocoding');
          // Set default values
          calculatedDistance.value = 0.0;
          calculatedTime.value = 0.0;
        }
      }
    } catch (e) {
      print('❌ Error calculating distance and time: $e');
      calculatedDistance.value = 0.0;
      calculatedTime.value = 0.0;
    } finally {
      isCalculatingDistance.value = false;
    }
  }

  /// Get formatted distance string
  String get formattedDistance {
    if (calculatedDistance.value == 0.0) return '0 km';
    return '${calculatedDistance.value.toStringAsFixed(1)} km';
  }

  /// Get formatted time string
  String get formattedTime {
    if (calculatedTime.value == 0.0) return '0 min';
    return '${calculatedTime.value.toStringAsFixed(0)} min';
  }

  /// Calculate distance from addresses using geocoding
  Future<void> _calculateDistanceFromAddresses(
      HomeController homeController) async {
    try {
      print(
          '🌍 Geocoding pickup address: ${homeController.fromlocation.value}');
      final pickupCoords =
          await _getCoordinatesFromAddress(homeController.fromlocation.value);

      print('🌍 Geocoding dropoff address: ${homeController.tolocation.value}');
      final dropoffCoords =
          await _getCoordinatesFromAddress(homeController.tolocation.value);

      if (pickupCoords != null && dropoffCoords != null) {
        print('✅ Successfully geocoded both addresses');

        // Calculate distance
        final distance = _calculateDistance(
          pickupCoords['latitude']!,
          pickupCoords['longitude']!,
          dropoffCoords['latitude']!,
          dropoffCoords['longitude']!,
        );

        calculatedDistance.value = distance;

        // Get current vehicle type
        final vehicleType = homeController.selectedVehicleType.value;

        // Calculate time
        final time = _calculateEstimatedTime(distance, vehicleType);
        calculatedTime.value = time;

        print(
            '📏 Distance calculated from geocoded addresses: ${distance.toStringAsFixed(1)} km');
        print('⏱️ Time calculated: ${time.toStringAsFixed(0)} min');

        // Update HomeController with the geocoded coordinates
        homeController.pickupLatitude.value = pickupCoords['latitude']!;
        homeController.pickupLongitude.value = pickupCoords['longitude']!;
        homeController.dropoffLatitude.value = dropoffCoords['latitude']!;
        homeController.dropoffLongitude.value = dropoffCoords['longitude']!;

        print('✅ Updated HomeController with geocoded coordinates');
      } else {
        print('❌ Failed to geocode one or both addresses');
        calculatedDistance.value = 0.0;
        calculatedTime.value = 0.0;
      }
    } catch (e) {
      print('❌ Error geocoding addresses: $e');
      calculatedDistance.value = 0.0;
      calculatedTime.value = 0.0;
    }
  }

  // For image upload - placeholder
  void uploadImage() {
    // Implement image upload logic here
    print("Upload tapped");
  }

  void takePhoto() {
    // Implement image upload logic here
    print("Upload tapped");
  }

  List<CarModel> carslist = [
    // CarModel(
    //   imagesecond: AppImages.carimgr,
    //   id: '1',
    //   image: AppImages.carimg,
    //   largebagcount: "1 Large Bag",
    //   name: "Car",
    //   pickuptime: "Pickup in 6 min",
    //   smallbagcount: "3-20 small Bag",
    // ),
    // CarModel(
    //   imagesecond: AppImages.suvsimgr,
    //   id: '2',
    //   image: AppImages.suvsimg,
    //   largebagcount: "2-12 Large Bag",
    //   name: "SUV",
    //   pickuptime: "Pickup in 6 min",
    //   smallbagcount: "4-10 Small Bag",
    // ),
    CarModel(
      imagesecond: AppImages.cargovanimgr,
      id: '3',
      image: AppImages.cargovanimg,
      largebagcount: "15-50 Large Bag",
      name: "Cargo Van",
      pickuptime: "Pickup in 6 min",
      smallbagcount: "30-100 Small Bag",
    ),
    CarModel(
      imagesecond: AppImages.pickuptruckimgr,
      id: '4',
      image: AppImages.pickuptruckimg,
      largebagcount: "7-17 Large Bag",
      name: "Pickup Truck",
      pickuptime: "Pickup in 6 min",
      smallbagcount: "15-35 Small Bag",
    ),
  ];

  File? selectedImage;

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);
    }
    update(['selecteImage']);
  }

  File? pickedFilePath;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      pickedFilePath = File(result.files.single.path!);
      ;
    }
    update(['pickfile']);
  }
}
