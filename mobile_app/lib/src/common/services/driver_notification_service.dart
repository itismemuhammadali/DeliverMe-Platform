import 'dart:async';
import 'package:get/get.dart';
import '../../models/driver_model.dart';
import 'driver_api_service.dart';
import 'driver_auth_service.dart';

class DriverNotificationService extends GetxService {
  static DriverNotificationService get to =>
      Get.find<DriverNotificationService>();

  // Notification state
  final RxList<DriverNotification> notifications = <DriverNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Mock notification service
  StreamSubscription<String>? _tokenSubscription;

  // Notification settings
  final RxBool notificationsEnabled = true.obs;
  final RxString fcmToken = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('🔧 DriverNotificationService initialized');
    _initializeNotificationService();
  }

  @override
  void onClose() {
    _tokenSubscription?.cancel();
    super.onClose();
  }

  /// Initialize notification service
  Future<void> _initializeNotificationService() async {
    try {
      print('🚀 Initializing notification service');

      // Request notification permissions
      await _requestNotificationPermissions();

      // Get FCM token
      await _getFCMToken();

      print('✅ Notification service initialized');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
      error.value = 'Error initializing notifications: $e';
    }
  }

  /// Request notification permissions
  Future<bool> _requestNotificationPermissions() async {
    try {
      print('🚀 Requesting notification permissions');

      // Mock permission as granted
      notificationsEnabled.value = true;
      print('✅ Notification permissions granted');
      return true;
    } catch (e) {
      print('❌ Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      // Mock FCM token
      fcmToken.value =
          'mock_fcm_token_${DateTime.now().millisecondsSinceEpoch}';
      print('✅ FCM token obtained: ${fcmToken.value.substring(0, 20)}...');

      // Update token on server if driver is logged in
      if (DriverAuthService.to.isLoggedIn.value) {
        await _updatePushTokenOnServer(fcmToken.value);
      }
    } catch (e) {
      print('❌ Error getting FCM token: $e');
    }
  }

  /// Update push token on server
  Future<void> _updatePushTokenOnServer(String token) async {
    try {
      if (!DriverAuthService.to.isLoggedIn.value) return;

      print('🚀 Updating push token on server');

      await DriverApiService.updatePushToken(
        pushToken: token,
        deviceId: 'flutter_driver_app',
      );

      print('✅ Push token updated on server');
    } catch (e) {
      print('❌ Error updating push token on server: $e');
    }
  }


  /// Load notifications from server
  Future<void> loadNotifications({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (!DriverAuthService.to.isLoggedIn.value) return;

      isLoading.value = true;
      error.value = '';

      print('🚀 Loading notifications from server');

      final response = await DriverApiService.getNotifications(
        status: status,
        limit: limit,
        offset: offset,
      );

      final List<dynamic> notificationList = response['notifications'] ?? [];

      notifications.clear();
      notifications.addAll(
        notificationList.map((json) => DriverNotification.fromJson(json)),
      );

      // Update unread count
      unreadCount.value = notifications.where((n) => n.status == 'sent').length;

      print('✅ Loaded ${notifications.length} notifications');
    } catch (e) {
      print('❌ Error loading notifications: $e');
      error.value = 'Error loading notifications: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      if (!DriverAuthService.to.isLoggedIn.value) return;

      print('🚀 Marking notification $notificationId as read');

      await DriverApiService.markNotificationAsRead(
        notificationId: notificationId,
      );

      // Update local notification
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = notifications[index];
        notifications[index] = DriverNotification(
          id: notification.id,
          driverId: notification.driverId,
          rideId: notification.rideId,
          type: notification.type,
          title: notification.title,
          message: notification.message,
          status: 'read',
          createdAt: notification.createdAt,
        );
      }

      // Update unread count
      unreadCount.value = notifications.where((n) => n.status == 'sent').length;

      print('✅ Notification marked as read');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      print('🚀 Marking all notifications as read');

      for (final notification in notifications) {
        if (notification.status == 'sent') {
          await markAsRead(notification.id);
        }
      }

      print('✅ All notifications marked as read');
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
    }
  }

  /// Clear all notifications
  void clearAllNotifications() {
    notifications.clear();
    unreadCount.value = 0;
    print('✅ All notifications cleared');
  }

  /// Get notifications by type
  List<DriverNotification> getNotificationsByType(String type) {
    return notifications.where((n) => n.type == type).toList();
  }

  /// Get unread notifications
  List<DriverNotification> get unreadNotifications {
    return notifications.where((n) => n.status == 'sent').toList();
  }

  /// Get read notifications
  List<DriverNotification> get readNotifications {
    return notifications.where((n) => n.status == 'read').toList();
  }

  /// Check if there are unread notifications
  bool get hasUnreadNotifications => unreadCount.value > 0;

  /// Get notification by ID
  DriverNotification? getNotificationById(int id) {
    try {
      return notifications.firstWhere((n) => n.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic $topic: $e');
    }
  }

  /// Enable notifications
  Future<void> enableNotifications() async {
    try {
      notificationsEnabled.value = true;

      // Re-request permissions
      await _requestNotificationPermissions();

      // Update token on server
      if (fcmToken.value.isNotEmpty) {
        await _updatePushTokenOnServer(fcmToken.value);
      }

      print('✅ Notifications enabled');
    } catch (e) {
      print('❌ Error enabling notifications: $e');
    }
  }

  /// Disable notifications
  Future<void> disableNotifications() async {
    try {
      notificationsEnabled.value = false;

      // Clear token from server
      if (DriverAuthService.to.isLoggedIn.value) {
        await DriverApiService.updatePushToken(
          pushToken: '',
          deviceId: 'flutter_driver_app',
        );
      }

      print('✅ Notifications disabled');
    } catch (e) {
      print('❌ Error disabling notifications: $e');
    }
  }
}
