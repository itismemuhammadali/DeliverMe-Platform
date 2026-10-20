import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constant/api_config.dart';

class CustomerDeliveryTrackingService extends GetxService {
  static CustomerDeliveryTrackingService get to =>
      Get.find<CustomerDeliveryTrackingService>();

  // Using centralized API configuration
  String get baseUrl => ApiConfig.baseUrl;

  // Tracking state
  final RxString currentStatus = ''.obs;
  final RxString statusMessage = ''.obs;
  final RxString subStatusMessage = ''.obs;
  final RxDouble progressValue = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Driver information
  final RxString driverName = ''.obs;
  final RxString driverPhone = ''.obs;
  final RxString driverRating = ''.obs;
  final RxString estimatedArrival = ''.obs;
  final Rx<Map<String, double>?> driverLocation = Rx<Map<String, double>?>(null);

  // Delivery information
  final RxMap<String, dynamic> deliveryData = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> driverData = <String, dynamic>{}.obs;

  // Firestore Listeners
  StreamSubscription<DocumentSnapshot>? _deliverySubscription;
  StreamSubscription<DocumentSnapshot>? _driverSubscription;
  final RxBool isListening = false.obs;

  // Polling (Fallback)
  Timer? _pollingTimer;
  final RxBool isPolling = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    _stopListening();
    super.onClose();
  }

  /// Start tracking a delivery
  Future<void> startTracking(int deliveryId) async {
    try {
      isLoading.value = true;
      error.value = '';

      print('📱 Starting delivery tracking (Firestore) for ID: $deliveryId');

      // Get initial delivery status via API for complete data (includes driver if assigned)
      await _fetchDeliveryStatus(deliveryId);

      // Start listening for real-time updates via Firestore
      _startListening(deliveryId);

      print('✅ Delivery tracking started with Firestore listeners');
    } catch (e) {
      print('❌ Error starting tracking: $e');
      error.value = 'Failed to start tracking: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Manually refresh delivery status
  Future<void> refreshStatus(int deliveryId) async {
    try {
      print('🔄 Manually refreshing delivery status for ID: $deliveryId');

      // Fetch the latest status via API
      await _fetchDeliveryStatus(deliveryId);

      print('✅ Delivery status refreshed successfully');
    } catch (e) {
      print('❌ Error refreshing status: $e');
      error.value = 'Failed to refresh status: ${e.toString()}';
      rethrow;
    }
  }

  /// Stop tracking
  void stopTracking() {
    _stopListening();
    print('🛑 Delivery tracking stopped');
  }

  /// Start Firestore listeners
  void _startListening(int deliveryId) {
    _stopListening(); // Stop any existing listeners

    isListening.value = true;
    
    // 1. Listen to delivery document
    _deliverySubscription = FirebaseFirestore.instance
        .collection('deliveries')
        .doc(deliveryId.toString())
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        print('🔥 Firestore Update: Delivery ${deliveryId} status changed to ${data['status']}');
        _handleStatusUpdate(data);
        
        // 2. If driver is assigned, listen to driver document for location updates
        final driverId = data['driver_id']?.toString();
        if (driverId != null && _driverSubscription == null) {
          _startDriverLocationListener(driverId);
        }
      }
    }, onError: (e) {
      print('❌ Firestore listener error: $e');
      error.value = 'Real-time update error: $e';
    });

    print('🔄 Started Firestore listeners for delivery updates');
  }

  /// Listen to driver document for real-time location updates
  void _startDriverLocationListener(String driverId) {
    _driverSubscription?.cancel();
    
    print('🔥 Starting Firestore listener for Driver: $driverId');
    _driverSubscription = FirebaseFirestore.instance
        .collection('drivers')
        .doc(driverId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('current_lat') && data.containsKey('current_lng')) {
          driverLocation.value = {
            'latitude': (data['current_lat'] as num).toDouble(),
            'longitude': (data['current_lng'] as num).toDouble(),
          };
          print('🔥 Driver location update: ${driverLocation.value}');
        }
        
        // Update other driver info if changed
        driverData.value = data;
        driverName.value = data['full_name'] ?? 
            '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim() ?? 'Driver';
      }
    });
  }

  /// Stop Firestore listeners
  void _stopListening() {
    _deliverySubscription?.cancel();
    _deliverySubscription = null;
    _driverSubscription?.cancel();
    _driverSubscription = null;
    isListening.value = false;
    print('🛑 Stopped Firestore listeners');
  }

  /// Fetch current delivery status via API
  Future<void> _fetchDeliveryStatus(int deliveryId) async {
    try {
      final url = Uri.parse('$baseUrl/deliveries/$deliveryId/status');

      print('🔍 Fetching delivery status from: $url');

      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );

      print(
          '📡 Delivery status response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // Use nested 'delivery' if backend returns it that way
        final deliveryData = data.containsKey('delivery') ? data['delivery'] : data;
        await _handleStatusUpdate(deliveryData);
      } else {
        throw Exception(
            'Failed to fetch delivery status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching delivery status: $e');
      throw e;
    }
  }

  /// Handle status updates
  Future<void> _handleStatusUpdate(Map<String, dynamic> data) async {
    final status = data['status']?.toString().toLowerCase() ?? '';
    final delivery = data;
    
    // Status normalization for app logic
    final normalizedStatus = _normalizeStatus(status);

    if (currentStatus.value != normalizedStatus) {
      print('✅ Status changed to $normalizedStatus');
    }

    deliveryData.value = delivery;

    // Driver data might be present in API response or we fetch it
    final driver = (data['driver'] as Map<String, dynamic>?) ?? Map<String, dynamic>.from(driverData);
    
    if (driver.isNotEmpty) {
      driverData.value = driver;
      driverName.value = driver['full_name'] ??
          '${driver['first_name'] ?? ''} ${driver['last_name'] ?? ''}'.trim() ??
          'Driver';
      driverPhone.value = driver['phone']?.toString() ?? 
                          driver['phone_number']?.toString() ?? '';
      driverRating.value = driver['rating']?.toString() ?? '5.0';
    } else if (delivery['driver_id'] != null && driverData.isEmpty) {
      await _fetchDriverDetails(delivery['driver_id'].toString());
    }

    switch (normalizedStatus) {
      case 'confirmed':
      case 'pending':
        if (delivery['driver_id'] != null) {
          _handleDriverAccepted();
        } else {
          _handleConfirmed();
        }
        break;
      case 'accepted':
      case 'assigned':
        _handleDriverAccepted();
        break;
      case 'arriving':
        _handleArriving();
        break;
      case 'arrived':
        _handleArrived();
        break;
      case 'picked_up':
        _handleItemPickedUp();
        break;
      case 'in_transit':
        _handleInTransit();
        break;
      case 'delivered':
        _handleDelivered();
        break;
      case 'cancelled':
        _handleCancelled();
        break;
      default:
        _handleUnknownStatus(normalizedStatus);
    }
  }

  String _normalizeStatus(String status) {
    switch (status.toLowerCase()) {
      case 'arriving': return 'arriving';
      case 'arrived': return 'arrived';
      case 'pickedup':
      case 'picked_up': return 'picked_up';
      case 'in-transit':
      case 'intransit':
      case 'in_transit': return 'in_transit';
      case 'completed':
      case 'delivered': return 'delivered';
      case 'canceled':
      case 'cancelled': return 'cancelled';
      case 'assigned':
      case 'accepted': return 'accepted';
      default: return status.toLowerCase();
    }
  }

  /// Handle confirmed status
  void _handleConfirmed() {
    currentStatus.value = 'confirmed';
    statusMessage.value = 'Searching for drivers...';
    subStatusMessage.value = 'Looking for available drivers in your area';
    progressValue.value = 0.3;
  }

  /// Handle driver accepted
  void _handleDriverAccepted() {
    currentStatus.value = 'accepted';
    statusMessage.value = 'Driver Found!';
    subStatusMessage.value =
        '${driverName.value} is on their way to pick up your Item';
    progressValue.value = 0.5;
  }

  /// Handle driver arriving
  void _handleArriving() {
    currentStatus.value = 'arriving';
    statusMessage.value = 'Driver Arriving';
    subStatusMessage.value =
        '${driverName.value} is arriving at the pickup location';
    progressValue.value = 0.55;
  }

  /// Handle driver arrived
  void _handleArrived() {
    currentStatus.value = 'arrived';
    statusMessage.value = 'Driver Arrived';
    subStatusMessage.value =
        '${driverName.value} has arrived at the pickup location';
    progressValue.value = 0.6;
  }

  /// Handle item picked up
  void _handleItemPickedUp() {
    currentStatus.value = 'picked_up';
    statusMessage.value = 'Item Picked Up!';
    subStatusMessage.value =
        '${driverName.value.isNotEmpty ? driverName.value : 'Your driver'} has picked up your Item and is on the way';
    progressValue.value = 0.7;
  }

  /// Handle in transit
  void _handleInTransit() {
    currentStatus.value = 'in_transit';
    statusMessage.value = 'Item In Transit';
    subStatusMessage.value = 'Your Item is on its way to the destination';
    progressValue.value = 0.8;
  }

  /// Handle delivered
  void _handleDelivered() {
    currentStatus.value = 'delivered';
    statusMessage.value = 'Item Delivered!';
    subStatusMessage.value = 'Your Item has been successfully delivered';
    progressValue.value = 1.0;
    _stopPolling(); // Stop polling when delivered
  }

  /// Handle cancelled
  void _handleCancelled() {
    currentStatus.value = 'cancelled';
    statusMessage.value = 'Delivery Cancelled';
    subStatusMessage.value = 'This delivery has been cancelled';
    progressValue.value = 0.0;
    _stopPolling();
  }

  /// Handle unknown status
  void _handleUnknownStatus(String status) {
    currentStatus.value = status;
    statusMessage.value = 'Processing your request...';
    subStatusMessage.value = 'Please wait while we process your delivery';
    progressValue.value = 0.1;
  }

  /// Stop polling
  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    isPolling.value = false;
    print('🛑 Stopped polling for delivery updates');
  }

  /// Get delivery tracking URL for sharing
  String getTrackingUrl(int deliveryId) {
    return '$baseUrl/deliveries/track/$deliveryId';
  }

  /// Check if delivery is completed
  bool get isCompleted {
    final status = currentStatus.value.toLowerCase();
    return status == 'delivered' || status == 'completed';
  }

  /// Check if delivery is cancelled
  bool get isCancelled {
    final status = currentStatus.value.toLowerCase();
    return status == 'cancelled' || status == 'canceled';
  }

  /// Check if driver is assigned
  bool get isDriverAssigned {
    final status = currentStatus.value.toLowerCase();
    return status == 'assigned' ||
        status == 'accepted' ||
        status == 'picked_up' ||
        status == 'pickedup' ||
        status == 'in_transit' ||
        status == 'in-transit' ||
        status == 'intransit' ||
        status == 'delivered' ||
        status == 'completed' ||
        driverData.isNotEmpty ||
        deliveryData['driver_id'] != null;
  }

  /// Get driver ID from driver data
  String? get driverId => driverData['id']?.toString();

  /// Get delivery ID from delivery data
  String? get deliveryId => deliveryData['id']?.toString();

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

        // Update driver information - match backend format
        driverName.value = driver['full_name'] ??
            '${driver['first_name'] ?? ''} ${driver['last_name'] ?? ''}'
                .trim() ??
            'Driver';
        // Backend returns phone in 'phone' field (mapped from phone_number)
        driverPhone.value = driver['phone']?.toString() ?? 
                            driver['phone_number']?.toString() ?? '';
        // Backend returns rating as float
        driverRating.value = driver['rating']?.toString() ?? '5.0';
        estimatedArrival.value = driver['estimated_arrival'] ?? '5-10 minutes';

        // Update driver data with complete information
        this.driverData.value = driver;

        print('✅ Driver details fetched successfully');
        print('👤 Driver: ${driverName.value}');
        print(
            '📞 Phone: ${driverPhone.value.isNotEmpty ? "Available" : "Not provided"}');
        print('⭐ Rating: ${driverRating.value}');
      } else {
        print(
            '⚠️ Failed to fetch driver details: ${driverResponse.statusCode}');
        print('⚠️ Response body: ${driverResponse.body}');
      }
    } catch (e) {
      print('❌ Error fetching driver details: $e');
    }
  }

  /// Get headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();

    print(
        '🔐 Customer Tracking - Token retrieved: ${token != null ? "Present" : "Missing"}');
    if (token != null) {
      print(
          '🔐 Customer Tracking - Token preview: ${token.substring(0, 20)}...');
    }

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
