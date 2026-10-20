import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class LocationSuggestion {
  final String address;
  final double latitude;
  final double longitude;
  final String? placeId;
  final String? description;

  LocationSuggestion({
    required this.address,
    required this.latitude,
    required this.longitude,
    this.placeId,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'placeId': placeId,
        'description': description,
      };
}

class LocationSuggestionService extends GetxController {
  static LocationSuggestionService get to =>
      Get.find<LocationSuggestionService>();

  // Debounce timer for search
  Timer? _debounceTimer;
  final Duration _debounceDelay = Duration(milliseconds: 300);

  // Search suggestions
  final RxList<LocationSuggestion> _suggestions = <LocationSuggestion>[].obs;
  final RxBool _isSearching = false.obs;
  final RxString _currentQuery = ''.obs;

  // Getters
  List<LocationSuggestion> get suggestions => _suggestions;
  bool get isSearching => _isSearching.value;
  String get currentQuery => _currentQuery.value;

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// Search for location suggestions with debouncing
  void searchSuggestions(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      _suggestions.clear();
      _isSearching.value = false;
      _currentQuery.value = '';
      return;
    }

    _currentQuery.value = query;
    _isSearching.value = true;

    _debounceTimer = Timer(_debounceDelay, () {
      _performSearch(query);
    });
  }

  /// Perform the actual search
  Future<void> _performSearch(String query) async {
    try {
      print('🔍 Searching for: $query');

      // Use geocoding to get location suggestions
      final locations = await locationFromAddress(query);

      if (locations.isNotEmpty) {
        final suggestions = <LocationSuggestion>[];

        // Limit to first 5 results for better UX
        final limitedLocations = locations.take(5).toList();

        for (int i = 0; i < limitedLocations.length; i++) {
          final location = limitedLocations[i];

          // Get detailed address for each location
          try {
            final placemarks = await placemarkFromCoordinates(
              location.latitude,
              location.longitude,
            );

            String address = query; // Fallback to original query
            if (placemarks.isNotEmpty) {
              final placemark = placemarks.first;
              final addressParts = <String>[];

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
                address = addressParts.join(', ');
              }
            }

            suggestions.add(LocationSuggestion(
              address: address,
              latitude: location.latitude,
              longitude: location.longitude,
              placeId: 'place_${i}_${location.latitude}_${location.longitude}',
              description: _getLocationDescription(
                  placemarks.isNotEmpty ? placemarks.first : null),
            ));
          } catch (e) {
            print('⚠️ Error getting address for location $i: $e');
            // Still add the location with basic info
            suggestions.add(LocationSuggestion(
              address: query,
              latitude: location.latitude,
              longitude: location.longitude,
              placeId: 'place_${i}_${location.latitude}_${location.longitude}',
            ));
          }
        }

        _suggestions.value = suggestions;
        print('✅ Found ${suggestions.length} suggestions');
      } else {
        _suggestions.clear();
        print('⚠️ No suggestions found for: $query');
      }
    } catch (e) {
      print('❌ Error searching suggestions: $e');
      _suggestions.clear();
    } finally {
      _isSearching.value = false;
    }
  }

  /// Get a user-friendly description for the location
  String _getLocationDescription(Placemark? placemark) {
    if (placemark == null) return '';

    final parts = <String>[];

    if (placemark.locality?.isNotEmpty == true) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      parts.add(placemark.administrativeArea!);
    }
    if (placemark.country?.isNotEmpty == true) {
      parts.add(placemark.country!);
    }

    return parts.join(', ');
  }

  /// Clear suggestions
  void clearSuggestions() {
    _suggestions.clear();
    _isSearching.value = false;
    _currentQuery.value = '';
    _debounceTimer?.cancel();
  }

  /// Get suggestion by index
  LocationSuggestion? getSuggestion(int index) {
    if (index >= 0 && index < _suggestions.length) {
      return _suggestions[index];
    }
    return null;
  }

  /// Search for nearby locations (for current location suggestions)
  Future<List<LocationSuggestion>> getNearbySuggestions({
    required double latitude,
    required double longitude,
    int limit = 5,
  }) async {
    try {
      print('📍 Getting nearby suggestions for: $latitude, $longitude');

      // Get current location address first
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final suggestions = <LocationSuggestion>[];

        // Add current location as first suggestion
        final currentAddress = _buildAddress(placemark);
        suggestions.add(LocationSuggestion(
          address: currentAddress,
          latitude: latitude,
          longitude: longitude,
          placeId: 'current_location',
          description: 'Current Location',
        ));

        // Add nearby landmarks (this is a simplified version)
        // In a real app, you might use Google Places API or similar
        final nearbySuggestions =
            await _getNearbyLandmarks(latitude, longitude);
        suggestions.addAll(nearbySuggestions.take(limit - 1));

        return suggestions;
      }

      return [];
    } catch (e) {
      print('❌ Error getting nearby suggestions: $e');
      return [];
    }
  }

  /// Build address from placemark
  String _buildAddress(Placemark placemark) {
    final parts = <String>[];

    if (placemark.street?.isNotEmpty == true) {
      parts.add(placemark.street!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      parts.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      parts.add(placemark.administrativeArea!);
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Current Location';
  }

  /// Get nearby landmarks (simplified implementation)
  Future<List<LocationSuggestion>> _getNearbyLandmarks(
    double latitude,
    double longitude,
  ) async {
    // This is a simplified implementation
    // In a real app, you would use Google Places API or similar service
    return [
      LocationSuggestion(
        address: 'Nearby Location 1',
        latitude: latitude + 0.001,
        longitude: longitude + 0.001,
        placeId: 'nearby_1',
        description: 'Landmark nearby',
      ),
      LocationSuggestion(
        address: 'Nearby Location 2',
        latitude: latitude - 0.001,
        longitude: longitude - 0.001,
        placeId: 'nearby_2',
        description: 'Another landmark',
      ),
    ];
  }
}

