import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'driver_api_service.dart';
import 'driver_auth_service.dart';

class DriverLocationService extends GetxService {
  static DriverLocationService get to => Get.find<DriverLocationService>();

  // Location state
  final Rx<Map<String, double>?> currentPosition =
      Rx<Map<String, double>?>(null);
  final RxBool isLocationEnabled = false.obs;
  final RxBool isLocationPermissionGranted = false.obs;
  final RxBool isTrackingLocation = false.obs;
  final RxString locationError = ''.obs;

  // Location tracking
  Timer? _locationUpdateTimer;

  // Location update settings
  static const Duration _locationUpdateInterval = Duration(seconds: 30);

  @override
  void onInit() {
    super.onInit();
    print('🔧 DriverLocationService initialized');
    _initializeLocation();
  }

  @override
  void onClose() {
    stopLocationTracking();
    super.onClose();
  }

  /// Initialize location services
  Future<void> _initializeLocation() async {
    try {
      print('🚀 Initializing location services');

      // Mock location services as enabled
      isLocationEnabled.value = true;

      // Check location permissions
      await _checkLocationPermissions();

      if (isLocationPermissionGranted.value) {
        // Get current position
        await getCurrentLocation();
      }
    } catch (e) {
      print('❌ Error initializing location: $e');
      locationError.value = 'Error initializing location: $e';
    }
  }

  /// Check and request location permissions
  Future<bool> _checkLocationPermissions() async {
    try {
      print('🚀 Checking location permissions');

      // Mock permission as granted
      isLocationPermissionGranted.value = true;
      locationError.value = '';
      print('✅ Location permissions granted');
      return true;
    } catch (e) {
      print('❌ Error checking location permissions: $e');
      locationError.value = 'Error checking permissions: $e';
      return false;
    }
  }

  /// Get current location
  Future<Map<String, double>?> getCurrentLocation() async {
    try {
      print('🚀 Getting current location');

      if (!isLocationEnabled.value) {
        locationError.value = 'Location services are disabled';
        return null;
      }

      if (!isLocationPermissionGranted.value) {
        final hasPermission = await _checkLocationPermissions();
        if (!hasPermission) {
          return null;
        }
      }

      // Mock location for testing (you can replace this with actual location service)
      final mockPosition = {
        'latitude': 37.7749, // San Francisco coordinates
        'longitude': -122.4194,
      };

      currentPosition.value = mockPosition;
      locationError.value = '';

      print(
          '✅ Current location: ${mockPosition['latitude']}, ${mockPosition['longitude']}');

      // Update location on server if driver is logged in
      if (DriverAuthService.to.isLoggedIn.value) {
        await updateLocationOnServer(
            mockPosition['latitude']!, mockPosition['longitude']!);
      }

      return mockPosition;
    } catch (e) {
      print('❌ Error getting current location: $e');
      locationError.value = 'Error getting location: $e';
      return null;
    }
  }

  /// Start location tracking
  Future<void> startLocationTracking() async {
    try {
      if (isTrackingLocation.value) {
        print('ℹ️ Location tracking already started');
        return;
      }

      print('🚀 Starting location tracking');

      if (!isLocationEnabled.value) {
        locationError.value = 'Location services are disabled';
        return;
      }

      if (!isLocationPermissionGranted.value) {
        final hasPermission = await _checkLocationPermissions();
        if (!hasPermission) {
          return;
        }
      }

      // Start periodic location updates to server
      _locationUpdateTimer = Timer.periodic(_locationUpdateInterval, (timer) {
        if (currentPosition.value != null &&
            DriverAuthService.to.isLoggedIn.value) {
          updateLocationOnServer(
            currentPosition.value!['latitude']!,
            currentPosition.value!['longitude']!,
          );
        }
      });

      isTrackingLocation.value = true;
      locationError.value = '';
      print('✅ Location tracking started');
    } catch (e) {
      print('❌ Error starting location tracking: $e');
      locationError.value = 'Error starting location tracking: $e';
    }
  }

  /// Stop location tracking
  void stopLocationTracking() {
    try {
      print('🚀 Stopping location tracking');

      _locationUpdateTimer?.cancel();
      _locationUpdateTimer = null;

      isTrackingLocation.value = false;
      print('✅ Location tracking stopped');
    } catch (e) {
      print('❌ Error stopping location tracking: $e');
    }
  }

  /// Update location on server
  Future<void> updateLocationOnServer(double latitude, double longitude) async {
    try {
      if (!DriverAuthService.to.isLoggedIn.value || DriverAuthService.to.currentDriver.value == null) {
        // Silently return if not logged in as a driver
        return;
      }

      print('🚀 Updating location on server: $latitude, $longitude');

      await DriverApiService.updateLocation(
        latitude: latitude,
        longitude: longitude,
      );

      print('✅ Location updated on server');
    } catch (e) {
      print('❌ Error updating location on server: $e');
      // Don't set error here as it's not critical for location tracking
    }
  }

  /// Calculate distance between two points (Haversine formula)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth's radius in meters

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Calculate bearing between two points
  double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double y = sin(dLon) * cos(lat2);
    final double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    double bearing = (atan2(y, x) * 180 / pi + 360) % 360;
    return bearing;
  }

  /// Get distance to a specific location
  double? getDistanceTo(double latitude, double longitude) {
    final current = currentPosition.value;
    if (current == null) return null;

    return calculateDistance(
      current['latitude']!,
      current['longitude']!,
      latitude,
      longitude,
    );
  }

  /// Get bearing to a specific location
  double? getBearingTo(double latitude, double longitude) {
    final current = currentPosition.value;
    if (current == null) return null;

    return calculateBearing(
      current['latitude']!,
      current['longitude']!,
      latitude,
      longitude,
    );
  }

  /// Check if location services are enabled
  Future<bool> checkLocationServices() async {
    try {
      // Mock as enabled
      isLocationEnabled.value = true;
      return true;
    } catch (e) {
      print('❌ Error checking location services: $e');
      return false;
    }
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    try {
      // Mock implementation - in real app, you would open device settings
      print('🚀 Opening location settings');
    } catch (e) {
      print('❌ Error opening location settings: $e');
    }
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    try {
      // Mock implementation - in real app, you would open app settings
      print('🚀 Opening app settings');
    } catch (e) {
      print('❌ Error opening app settings: $e');
    }
  }

  /// Get current position as map
  Map<String, double>? get currentLocationMap {
    return currentPosition.value;
  }

  /// Get current position with accuracy
  Map<String, dynamic>? get currentLocationWithAccuracy {
    final position = currentPosition.value;
    if (position == null) return null;

    return {
      'latitude': position['latitude'],
      'longitude': position['longitude'],
      'accuracy': 10.0, // Mock accuracy
      'altitude': 0.0, // Mock altitude
      'heading': 0.0, // Mock heading
      'speed': 0.0, // Mock speed
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Check if location is available
  bool get hasLocation => currentPosition.value != null;

  /// Get location status
  String get locationStatus {
    if (!isLocationEnabled.value) return 'disabled';
    if (!isLocationPermissionGranted.value) return 'permission_denied';
    if (!hasLocation) return 'no_location';
    if (isTrackingLocation.value) return 'tracking';
    return 'available';
  }
}
