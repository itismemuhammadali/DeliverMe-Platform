import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as fb_storage;
import '../constant/api_config.dart';

class DeliveryService extends GetxService {
  static DeliveryService get to => Get.find<DeliveryService>();

  // Using centralized API configuration
  String get baseUrl => ApiConfig.baseUrl;
  String get apiBaseUrl => baseUrl;

  // Headers for API requests with authentication
  Future<Map<String, String>> _getHeaders() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get customer ID from stored user data
  Future<int> _getCustomerId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getInt('customer_id');

      if (customerId != null) {
        print('👤 Customer ID found: $customerId');
        return customerId;
      } else {
        print('⚠️ No customer ID found, using default: 1');
        return 1; // Default customer ID for testing
      }
    } catch (e) {
      print('❌ Error getting customer ID: $e, using default: 1');
      return 1; // Default customer ID for testing
    }
  }

  /// Map vehicle type to backend format
  String _mapVehicleType(String vehicleType) {
    print('🚛 Mapping vehicle type: "$vehicleType"');
    final mapping = {
      'car': 'car',
      'suv': 'suv',
      'pickup_truck': 'pickup_truck',
      'cargo_van': 'cargo_van',
      'box_truck': 'box_truck',
      'sedan': 'car'
    };
    final mappedType = mapping[vehicleType.toLowerCase()] ?? 'cargo_van';
    print('🚛 Mapped vehicle type: "$mappedType"');

    // Special debugging for all vehicle types
    if (vehicleType.toLowerCase() == 'cargo_van') {
      print('🚐 Cargo Van detected - mapped to: $mappedType');
      print('🚐 Input: "$vehicleType" -> Output: "$mappedType"');
    } else if (vehicleType.toLowerCase() == 'pickup_truck') {
      print('🚛 Pickup Truck detected - mapped to: $mappedType');
      print('🚛 Input: "$vehicleType" -> Output: "$mappedType"');
    } else if (vehicleType.toLowerCase() == 'box_truck') {
      print('📦 Box Truck detected - mapped to: $mappedType');
      print('📦 Input: "$vehicleType" -> Output: "$mappedType"');
    }

    return mappedType;
  }

  /// Map delivery type to backend format
  String _mapDeliveryType(String deliveryType) {
    final mapping = {
      'pickup': 'standard', // Map pickup to standard
      'box': 'standard', // Map box to standard
      'cargo': 'standard', // Map cargo to standard
      'standard': 'standard',
      'express': 'express',
      'same_day': 'same_day'
    };
    return mapping[deliveryType.toLowerCase()] ?? 'standard';
  }

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

    print('📏 Distance calculated: ${distance.toStringAsFixed(2)} km');
    return distance;
  }

  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Get distance from Google Maps Distance Matrix API
  Future<Map<String, dynamic>?> _getDistanceFromGoogleMaps(
      String pickupAddress, String dropoffAddress) async {
    try {
      print('🗺️ Getting distance from Google Maps API...');
      print('📍 From: $pickupAddress');
      print('📍 To: $dropoffAddress');

      // Use the Google Maps API key for distance calculation
      // This key supports Distance Matrix API
      const String apiKey = 'AIzaSyBaibQR5H_xFkers-GWAqrNA0xr1SScaKA';
      
      if (apiKey.isEmpty) {
        print('⚠️ Google Maps API key not configured');
        return null;
      }
      
      print('🔑 Using Google Maps API Key for distance calculation');

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=${Uri.encodeComponent(pickupAddress)}'
        '&destinations=${Uri.encodeComponent(dropoffAddress)}'
        '&mode=driving'
        '&key=$apiKey',
      );

      print('🔗 Google Maps URL: $url');

      final response = await http.get(url).timeout(Duration(seconds: 10));

      print('📡 Google Maps Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📊 Google Maps Response Data: $data');

        if (data['status'] == 'OK' &&
            data['rows'] != null &&
            data['rows'].isNotEmpty) {
          final element = data['rows'][0]['elements'][0];

          if (element['status'] == 'OK') {
            final distanceMeters = element['distance']['value'];
            final distanceKm = distanceMeters / 1000;
            final durationSeconds = element['duration']['value'];
            final durationMinutes = durationSeconds ~/ 60;

            print('✅ Distance from Google Maps: ${distanceKm.toStringAsFixed(2)} km');
            print('⏱️ Duration from Google Maps: $durationMinutes minutes');

            return {
              'distance_km': distanceKm,
              'duration_minutes': durationMinutes,
              'distance_meters': distanceMeters,
              'duration_seconds': durationSeconds,
            };
          } else {
            print('❌ Google Maps element status: ${element['status']}');
            return null;
          }
        } else {
          print('❌ Google Maps status: ${data['status']}');
          return null;
        }
      } else {
        print('❌ Google Maps API error: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting distance from Google Maps: $e');
      return null;
    }
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

  /// Create a new delivery
  Future<Map<String, dynamic>> createDelivery({
    required String pickupAddress,
    required String dropoffAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
    required String itemName,
    String? itemDescription,
    String? itemPhotoUrl,
    File? itemPhotoFile, // New parameter for photo file upload
    required String vehicleType,
    String? itemType,
    double? width,
    double? height,
    double? length,
    required double weight,
    String? specialInstructions,
    String deliveryType = 'standard',
    required String scheduleType,
    DateTime? scheduledDate,
    String? timeSlot,
    String deliveryPreference = 'attended',
  }) async {
    try {
      final url = Uri.parse('$apiBaseUrl/deliveries/create');

      final mappedVehicleType = _mapVehicleType(vehicleType);
      print('🔍 DEBUG: Original vehicle type: "$vehicleType"');
      print('🔍 DEBUG: Mapped vehicle type: "$mappedVehicleType"');

      // Build request body with only non-null values to avoid Firestore serialization issues
      final requestBody = <String, dynamic>{
        'customer_id': await _getCustomerId(),
        'pickup_address': pickupAddress,
        'dropoff_address': dropoffAddress,
        'item_name': itemName,
        'vehicle_type': mappedVehicleType,
        'weight': weight,
        'schedule_type': scheduleType,
        'delivery_preference': deliveryPreference,
        'delivery_type': _mapDeliveryType(deliveryType),
        // Status is set by backend, don't send from frontend
        'payment_status': 'pending', // Payment status can be sent from frontend
      };

      // Get distance from Google Maps API
      double? estimatedDistance;
      int? estimatedDuration;

      print('🗺️ Attempting to get distance from Google Maps...');
      final googleMapsResult = await _getDistanceFromGoogleMaps(
        pickupAddress,
        dropoffAddress,
      );

      if (googleMapsResult != null) {
        estimatedDistance = googleMapsResult['distance_km'];
        estimatedDuration = googleMapsResult['duration_minutes'];
        print(
            '✅ Got distance from Google Maps: ${estimatedDistance?.toStringAsFixed(2) ?? "0.0"} km, ${estimatedDuration} minutes');
      } else {
        print('⚠️ Could not get distance from Google Maps, using fallback...');
        
        // Fallback: Try to get coordinates and calculate distance
        if (pickupLatitude != null &&
            pickupLongitude != null &&
            dropoffLatitude != null &&
            dropoffLongitude != null) {
          // Use provided coordinates
          estimatedDistance = _calculateDistance(
            pickupLatitude,
            pickupLongitude,
            dropoffLatitude,
            dropoffLongitude,
          );
          print(
              '📏 Distance calculated from provided coordinates: ${estimatedDistance.toStringAsFixed(2)} km');
        } else {
          // Try to get coordinates from addresses as fallback
          print('⚠️ No coordinates provided, attempting to geocode addresses...');

          try {
            final pickupCoords = await _getCoordinatesFromAddress(pickupAddress);
            final dropoffCoords =
                await _getCoordinatesFromAddress(dropoffAddress);

            if (pickupCoords != null && dropoffCoords != null) {
              estimatedDistance = _calculateDistance(
                pickupCoords['latitude']!,
                pickupCoords['longitude']!,
                dropoffCoords['latitude']!,
                dropoffCoords['longitude']!,
              );
              print(
                  '📏 Distance calculated from geocoded addresses: ${estimatedDistance.toStringAsFixed(2)} km');
            } else {
              print(
                  '❌ Could not get coordinates from addresses, skipping distance calculation');
            }
          } catch (e) {
            print('❌ Error geocoding addresses for distance calculation: $e');
          }
        }
        
        // Calculate duration if we have distance
        if (estimatedDistance != null && estimatedDistance > 0) {
          estimatedDuration = (estimatedDistance / 40 * 60).toInt();
        }
      }

      // Add distance to request body (always include, default to 0 if not calculated)
      requestBody['estimated_distance_km'] = estimatedDistance ?? 0.0;
      if (estimatedDistance != null) {
        print(
            '📏 Added estimated distance to request: ${estimatedDistance.toStringAsFixed(2)} km');
      } else {
        print('📏 No distance calculated, using default: 0.0 km');
      }
      
      // Add estimated duration
      requestBody['estimated_duration'] = estimatedDuration ?? 30;
      if (estimatedDuration != null) {
        print('⏱️ Estimated duration: $estimatedDuration minutes');
      } else {
        print('⏱️ Using default estimated duration: 30 minutes');
      }

      print('📦 Delivery request body: ${jsonEncode(requestBody)}');
      print('🚛 Vehicle type in request: "${requestBody['vehicle_type']}"');

      // Add optional fields ONLY if they have valid values (to avoid Firestore serialization issues)
      // For coordinates, only add if BOTH latitude AND longitude are provided and > 0
      if (pickupLatitude != null && pickupLatitude > 0 && pickupLongitude != null && pickupLongitude > 0) {
        requestBody['pickup_latitude'] = pickupLatitude;
        requestBody['pickup_longitude'] = pickupLongitude;
        print('📍 Added pickup coordinates: $pickupLatitude, $pickupLongitude');
      }

      if (dropoffLatitude != null && dropoffLatitude > 0 && dropoffLongitude != null && dropoffLongitude > 0) {
        requestBody['dropoff_latitude'] = dropoffLatitude;
        requestBody['dropoff_longitude'] = dropoffLongitude;
        print('📍 Added dropoff coordinates: $dropoffLatitude, $dropoffLongitude');
      }

      if (itemDescription != null && itemDescription.isNotEmpty) {
        requestBody['item_description'] = itemDescription;
      }

      if (itemPhotoUrl != null && itemPhotoUrl.isNotEmpty) {
        requestBody['item_photo_url'] = itemPhotoUrl;
      }

      if (itemType != null && itemType.isNotEmpty) {
        requestBody['package_type'] = itemType;
      }

      // Always include dimensions (even if 0 or null)
      if (width != null && width > 0) {
        requestBody['width'] = width;
      } else if (width == null) {
        requestBody['width'] = 0.0;
      }

      if (height != null && height > 0) {
        requestBody['height'] = height;
      } else if (height == null) {
        requestBody['height'] = 0.0;
      }

      if (length != null && length > 0) {
        requestBody['length'] = length;
      } else if (length == null) {
        requestBody['length'] = 0.0;
      }

      // Always include special instructions (even if empty)
      requestBody['special_instructions'] = specialInstructions ?? '';

      if (scheduledDate != null) {
        requestBody['scheduled_date'] =
            scheduledDate.toIso8601String().split('T')[0];
      }

      if (timeSlot != null && timeSlot.isNotEmpty) {
        requestBody['time_slot'] = timeSlot;
        print('🔍 Setting time_slot in request body: $timeSlot');
      }

      // Validate required fields before sending
      if (pickupAddress.length < 5) {
        return {
          'success': false,
          'error': 'Pickup address must be at least 5 characters',
        };
      }

      if (dropoffAddress.length < 5) {
        return {
          'success': false,
          'error': 'Dropoff address must be at least 5 characters',
        };
      }

      // Check if we have coordinates for both locations
      bool hasPickupCoords = pickupLatitude != null && pickupLongitude != null;
      bool hasDropoffCoords =
          dropoffLatitude != null && dropoffLongitude != null;

      if (!hasPickupCoords) {
        print(
            '⚠️ No pickup coordinates provided, backend will geocode pickup address');
      }

      if (!hasDropoffCoords) {
        print(
            '⚠️ No dropoff coordinates provided, backend will geocode dropoff address');
      }

      if (weight <= 0) {
        return {
          'success': false,
          'error': 'Weight must be greater than 0 lbs',
        };
      }

      print('🚀 Creating delivery with data: ${jsonEncode(requestBody)}');
      print('🔗 API URL: $url');
      print('🚛 Original Vehicle Type: $vehicleType');
      print('🚛 Mapped Vehicle Type: ${_mapVehicleType(vehicleType)}');
      print('🚚 Delivery Type: ${_mapDeliveryType(deliveryType)}');
      print('🔍 Vehicle Type in Request Body: ${requestBody['vehicle_type']}');

      // Final cleanup: Remove any fields with empty strings or null values
      requestBody.removeWhere((key, value) => value == null || value == '');
      
      print('📋 Final Request Body (after cleanup):');
      requestBody.forEach((key, value) {
        print('  - $key: $value (${value.runtimeType})');
      });

      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(requestBody),
      );

      print(
          '📡 Delivery API Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          final trackingNumber = responseData['tracking_number'] ??
              responseData['delivery']?['tracking_number'] ??
              'N/A';
          final deliveryId = responseData['delivery_id'] ??
              responseData['delivery']?['id'] ??
              responseData['id'];

          print('✅ Delivery created successfully!');
          print('📦 Tracking Number: $trackingNumber');
          print('📦 Delivery ID: $deliveryId (type: ${deliveryId.runtimeType})');
          print('📦 Full Response: $responseData');

          // Handle item photo upload if photo file is provided
          // IMPORTANT: Photo upload is now NON-BLOCKING to prevent delivery creation from failing
          if (itemPhotoFile != null && deliveryId != null) {
            // Convert deliveryId to int if it's a string
            final int deliveryIdInt;
            if (deliveryId is String) {
              deliveryIdInt = int.tryParse(deliveryId) ?? 0;
              print('📦 Converted delivery ID from string to int: $deliveryIdInt');
            } else if (deliveryId is int) {
              deliveryIdInt = deliveryId;
            } else {
              print('❌ Invalid delivery ID type: ${deliveryId.runtimeType}');
              deliveryIdInt = 0;
            }

            if (deliveryIdInt > 0) {
              final String bomb = '💣💣💣';
              print('$bomb 🚨 STARTING BACKGROUND PHOTO UPLOAD (NON-BLOCKING) 🚨 $bomb');
              
              // Upload photo in background without blocking delivery creation
              // Photo upload will complete async, errors are logged but don't block the user experience
              _uploadPhotoInBackground(deliveryIdInt, itemPhotoFile, bomb);
            }
          }

          return {
            'success': true,
            'data': responseData,
            'tracking_number': trackingNumber,
            'delivery_id': deliveryId,
          };
        } catch (e) {
          print('❌ Error parsing success response: $e');
          return {
            'success': false,
            'error': 'Failed to parse server response: $e',
          };
        }
      } else {
        print('❌ Delivery creation failed with status: ${response.statusCode}');
        print('❌ Response body: ${response.body}');

        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['error'] ??
              errorData['message'] ??
              'Failed to create delivery';
          print('❌ Server error: $errorMessage');

          // Handle specific geocoding errors
          if (errorMessage.toLowerCase().contains('geocode')) {
            return {
              'success': false,
              'error':
                  'Address not found. Please select a valid pickup and dropoff location.',
            };
          }

          return {
            'success': false,
            'error': errorMessage,
          };
        } catch (e) {
          print('❌ Error parsing error response: $e');
          return {
            'success': false,
            'error': 'Server error: ${response.statusCode} - ${response.body}',
          };
        }
      }
    } catch (e) {
      print('❌ Delivery creation error: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Get available time slots for a specific date
  Future<Map<String, dynamic>> getAvailableTimeSlots(DateTime date) async {
    try {
      final dateString = date.toIso8601String().split('T')[0];
      final url =
          Uri.parse('$apiBaseUrl/deliveries/available-slots/$dateString');

      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to get time slots',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Get user's deliveries
  Future<Map<String, dynamic>> getUserDeliveries({
    String? status,
    String? deliveryType,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (deliveryType != null) queryParams['delivery_type'] = deliveryType;

      final uri = Uri.parse('$apiBaseUrl/deliveries/').replace(
        queryParameters: queryParams,
      );

      print('📡 Fetching deliveries from: $uri');
      print('📡 Backend will filter by authenticated customer');
      print('📡 Headers: ${await _getHeaders()}');

      final response = await http.get(uri, headers: await _getHeaders());

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        try {
          final errorData = jsonDecode(response.body);
          print('❌ Error response: $errorData');
          return {
            'success': false,
            'error': errorData['error'] ?? 'Failed to get deliveries',
          };
        } catch (e) {
          print('❌ Failed to parse error response: $e');
          return {
            'success': false,
            'error': 'Server error: ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      print('❌ Network error in getUserDeliveries: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Track delivery by tracking number
  Future<Map<String, dynamic>> trackDelivery(String trackingNumber) async {
    try {
      final url = Uri.parse('$apiBaseUrl/deliveries/track/$trackingNumber');

      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Delivery not found',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Cancel delivery
  Future<Map<String, dynamic>> cancelDelivery(int deliveryId) async {
    try {
      final url = Uri.parse('$apiBaseUrl/deliveries/$deliveryId/cancel');

      final response = await http.post(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to cancel delivery',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Get signed upload URL for delivery item photo
  Future<Map<String, dynamic>> getItemPhotoUploadUrl({
    required int deliveryId,
    required String filename,
    required String contentType,
  }) async {
    try {
      final url =
          Uri.parse('$apiBaseUrl/deliveries/item-photo/upload-url');

      final requestBody = {
        'delivery_id': deliveryId,
        'filename': filename,
        'content_type': contentType,
      };

      print('📸 Getting item photo upload URL for delivery: $deliveryId');
      print('📸 Request body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(requestBody),
      );

      print(
          '📸 Upload URL response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'upload_url': responseData['upload_url'],
          'object_key': responseData['object_key'],
          'expires_in': responseData['expires_in'],
          'item_photo_url': responseData['item_photo_url'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error'] ?? 'Failed to get upload URL',
        };
      }
    } catch (e) {
      print('❌ Error getting upload URL: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Upload item photo file to GCP using signed URL
  Future<Map<String, dynamic>> uploadItemPhoto({
    required String uploadUrl,
    required File photoFile,
    required String contentType,
  }) async {
    try {
      stdout.writeln('📸 🚨 EMERGENCY: Uploading item photo to GCP...');
      stdout.writeln('📸 🚨 EMERGENCY: File path: ${photoFile.path}');
      stdout.writeln('📸 🚨 EMERGENCY: Content type: $contentType');

      final bytes = await photoFile.readAsBytes();
      stdout.writeln('📸 🚨 EMERGENCY: File size: ${bytes.length} bytes');

      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type': contentType,
        },
        body: bytes,
      );

      stdout.writeln('📸 🚨 EMERGENCY: Upload response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        stdout.writeln('✅ 🚨 EMERGENCY: Item photo uploaded successfully to storage');
        return {
          'success': true,
          'message': 'Photo uploaded successfully',
        };
      } else {
        stdout.writeln('❌ 🚨 EMERGENCY: Upload failed with status: ${response.statusCode}');
        stdout.writeln('❌ 🚨 EMERGENCY: Response body: ${response.body}');
        return {
          'success': false,
          'error': 'Failed to upload photo to storage: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error uploading photo: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Complete item photo upload workflow for a delivery
  ///
  /// This method handles the complete workflow for uploading an item photo:
  /// 1. Uploads the photo file directly to Firebase Storage using the SDK
  /// 2. Updates delivery with photo URL in Firestore
  Future<Map<String, dynamic>> uploadDeliveryItemPhoto({
    required int deliveryId,
    required File photoFile,
    String? filename,
  }) async {
    try {
      stdout.writeln('📸 🚨 EMERGENCY: Starting Firebase SDK photo upload for delivery $deliveryId');
      
      // Determine file extension
      final extension = photoFile.path.split('.').last.toLowerCase();
      final photoFilename = filename ?? 'item_photo_${deliveryId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      
      final String objectKey = 'deliveries/$deliveryId/item_photos/$photoFilename';
      stdout.writeln('📸 🚨 EMERGENCY: Object Key: $objectKey');

      // Step 1: Upload to Firebase Storage using the SDK
      
      final storageRef = fb_storage.FirebaseStorage.instance.ref().child(objectKey);
      
      // Create metadata
      final metadata = fb_storage.SettableMetadata(
        contentType: 'image/${extension == 'jpg' ? 'jpeg' : extension}',
        customMetadata: {'delivery_id': deliveryId.toString()},
      );

      stdout.writeln('📸 🚨 EMERGENCY: Commencing SDK upload...');
      final uploadTask = await storageRef.putFile(photoFile, metadata);
      
      if (uploadTask.state == fb_storage.TaskState.success) {
        final downloadUrl = await storageRef.getDownloadURL();
        stdout.writeln('✅ 🚨 EMERGENCY: SDK Upload SUCCESS. URL: $downloadUrl');

        // Step 2: Explicitly update delivery with photo URL via backend for extra reliability
        try {
          final updateUrl = Uri.parse('$apiBaseUrl/deliveries/$deliveryId/item-photo');
          final updateResponse = await http.put(
            updateUrl,
            headers: await _getHeaders(),
            body: jsonEncode({
              'item_photo_url': downloadUrl,
              'object_key': objectKey,
            }),
          );
          stdout.writeln('📸 🚨 EMERGENCY: Backend update response: ${updateResponse.statusCode}');
        } catch (e) {
          stdout.writeln('⚠️ 🚨 EMERGENCY: Backend update exception (non-fatal): $e');
        }

        return {
          'success': true,
          'item_photo_url': downloadUrl,
          'delivery_id': deliveryId,
        };
      } else {
        return {
          'success': false,
          'error': 'Upload task failed with state: ${uploadTask.state}',
        };
      }
    } catch (e) {
      stdout.writeln('❌ 🚨 EMERGENCY: CRITICAL EXCEPTION in SDK photo upload: $e');
      return {
        'success': false,
        'error': 'Failed to upload item photo via SDK: ${e.toString()}',
      };
    }
  }

  /// Upload delivery item photo in background (non-blocking)
  /// This runs async without blocking the delivery creation or navigation
  void _uploadPhotoInBackground(int deliveryId, File photoFile, String bomb) {
    // Fire and forget - upload in background
    uploadDeliveryItemPhoto(
      deliveryId: deliveryId,
      photoFile: photoFile,
    ).then((result) {
      if (result['success']) {
        print('$bomb ✅ BACKGROUND PHOTO UPLOAD SUCCESSFUL $bomb');
      } else {
        print('$bomb ⚠️ BACKGROUND PHOTO UPLOAD FAILED: ${result['error']} $bomb');
        print('$bomb Note: Delivery was still created successfully, only photo upload failed $bomb');
      }
    }).catchError((e) {
      print('$bomb ❌ BACKGROUND PHOTO UPLOAD ERROR: $e $bomb');
    });
  }
}

