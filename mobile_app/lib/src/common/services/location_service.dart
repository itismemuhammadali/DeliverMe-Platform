import 'dart:async';
import 'dart:math';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class LocationService extends GetxController {
  static LocationService get to => Get.find<LocationService>();

  // Location tracking state
  final RxBool _isLocationPermissionGranted = false.obs;
  final Rx<loc.LocationData?> _currentPosition = Rx<loc.LocationData?>(null);
  final RxString _currentAddress = ''.obs;
  final RxBool _isLocationServiceEnabled = false.obs;

  // Location service
  final loc.Location _location = loc.Location();

  // Stream subscription
  StreamSubscription<loc.LocationData>? _positionStreamSubscription;

  // Getters
  bool get isLocationPermissionGranted => _isLocationPermissionGranted.value;
  loc.LocationData? get currentPosition => _currentPosition.value;
  String get currentAddress => _currentAddress.value;
  bool get isLocationServiceEnabled => _isLocationServiceEnabled.value;

  @override
  void onInit() {
    super.onInit();
    // Delay execution to prevent blocking the main thread during app launch
    Future.delayed(const Duration(milliseconds: 500), () {
      _checkLocationPermission();
      _checkLocationService();
    });
  }

  @override
  void onClose() {
    _positionStreamSubscription?.cancel();
    super.onClose();
  }

  /// Check if location permission is granted
  Future<bool> _checkLocationPermission() async {
    try {
      final permissionGranted = await _location.hasPermission();
      _isLocationPermissionGranted.value =
          permissionGranted == loc.PermissionStatus.granted;
      return _isLocationPermissionGranted.value;
    } catch (e) {
      print('❌ Error checking location permission: $e');
      return false;
    }
  }

  /// Check if location service is enabled
  Future<void> _checkLocationService() async {
    try {
      final serviceEnabled = await _location.serviceEnabled();
      _isLocationServiceEnabled.value = serviceEnabled;
    } catch (e) {
      print('❌ Error checking location service: $e');
    }
  }

  /// Request location permission
  Future<bool> requestLocationPermission() async {
    try {
      final result = await _location.requestPermission();
      _isLocationPermissionGranted.value =
          result == loc.PermissionStatus.granted;
      return _isLocationPermissionGranted.value;
    } catch (e) {
      print('❌ Error requesting location permission: $e');
      return false;
    }
  }

  /// Enable location service
  Future<bool> enableLocationService() async {
    try {
      final result = await _location.requestService();
      _isLocationServiceEnabled.value = result;
      return result;
    } catch (e) {
      print('❌ Error enabling location service: $e');
      return false;
    }
  }

  /// Get current location once
  Future<loc.LocationData?> getCurrentLocation() async {
    try {
      // Check permission first
      if (!_isLocationPermissionGranted.value) {
        print('🔐 Requesting location permission...');
        final granted = await requestLocationPermission();
        if (!granted) {
          print('❌ Location permission not granted');
          return null;
        }
      }

      // Check if location service is enabled
      if (!_isLocationServiceEnabled.value) {
        print('🔧 Enabling location service...');
        final enabled = await enableLocationService();
        if (!enabled) {
          print('❌ Location service not enabled');
          return null;
        }
      }

      print('📍 Getting current location...');
      final position = await _location.getLocation().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          print('⏰ Location request timed out');
          throw TimeoutException(
              'Location request timed out', Duration(seconds: 10));
        },
      );

      // Validate position data
      if (position.latitude == null || position.longitude == null) {
        print('❌ Invalid position data received');
        return null;
      }

      _currentPosition.value = position;
      await _getAddressFromPosition(position);

      print('✅ Current location: ${position.latitude}, ${position.longitude}');
      print('📍 Address: ${_currentAddress.value}');
      return position;
    } catch (e) {
      print('❌ Error getting current location: $e');
      return null;
    }
  }

  /// Get address from position
  Future<void> _getAddressFromPosition(loc.LocationData position) async {
    try {
      if (position.latitude != null && position.longitude != null) {
        print(
            '🌍 Geocoding address for: ${position.latitude}, ${position.longitude}');

        final placemarks = await placemarkFromCoordinates(
          position.latitude!,
          position.longitude!,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;

          // Build address with available components
          List<String> addressParts = [];

          if (placemark.street?.isNotEmpty == true) {
            addressParts.add(placemark.street!);
          }
          if (placemark.locality?.isNotEmpty == true) {
            addressParts.add(placemark.locality!);
          }
          if (placemark.administrativeArea?.isNotEmpty == true) {
            addressParts.add(placemark.administrativeArea!);
          }

          if (addressParts.isNotEmpty) {
            _currentAddress.value = addressParts.join(', ');
            print('✅ Address found: ${_currentAddress.value}');
          } else {
            // Use coordinates as fallback instead of "Current Location"
            _currentAddress.value =
                '${position.latitude!.toStringAsFixed(4)}, ${position.longitude!.toStringAsFixed(4)}';
            print(
                '⚠️ No address components found, using coordinates: ${_currentAddress.value}');
          }
        } else {
          // Use coordinates as fallback instead of "Current Location"
          _currentAddress.value =
              '${position.latitude!.toStringAsFixed(4)}, ${position.longitude!.toStringAsFixed(4)}';
          print(
              '⚠️ No placemarks found, using coordinates: ${_currentAddress.value}');
        }
      }
    } catch (e) {
      print('❌ Error getting address: $e');
      // Use coordinates as fallback instead of "Current Location"
      if (position.latitude != null && position.longitude != null) {
        _currentAddress.value =
            '${position.latitude!.toStringAsFixed(4)}, ${position.longitude!.toStringAsFixed(4)}';
      } else {
        _currentAddress.value = 'Current Location';
      }
    }
  }

  /// Start location tracking
  Future<void> startLocationTracking() async {
    try {
      if (!_isLocationPermissionGranted.value) {
        final granted = await requestLocationPermission();
        if (!granted) return;
      }

      if (!_isLocationServiceEnabled.value) {
        final enabled = await enableLocationService();
        if (!enabled) return;
      }

      _positionStreamSubscription = _location.onLocationChanged.listen(
        (loc.LocationData position) {
          _currentPosition.value = position;
          _getAddressFromPosition(position);
        },
        onError: (error) {
          print('❌ Location stream error: $error');
        },
      );

      print('🚀 Location tracking started');
    } catch (e) {
      print('❌ Error starting location tracking: $e');
    }
  }

  /// Stop location tracking
  void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    print('🛑 Location tracking stopped');
  }

  /// Calculate distance between two points (Haversine formula)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Get distance to destination
  double? getDistanceToDestination(double destLat, double destLon) {
    final currentPos = _currentPosition.value;
    if (currentPos == null ||
        currentPos.latitude == null ||
        currentPos.longitude == null) return null;

    return calculateDistance(
      currentPos.latitude!,
      currentPos.longitude!,
      destLat,
      destLon,
    );
  }
}
