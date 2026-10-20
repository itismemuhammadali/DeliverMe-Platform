import 'package:get/get.dart';
import '../../../../common/services/driver_notification_service.dart';
import '../../../../models/driver_model.dart';

class DriverNotificationController extends GetxController {
  static DriverNotificationController get to =>
      Get.find<DriverNotificationController>();

  // Services
  final DriverNotificationService _notificationService =
      DriverNotificationService.to;

  // Notification state
  final RxList<DriverNotification> notifications = <DriverNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString selectedFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  /// Load notifications from server
  Future<void> _loadNotifications() async {
    try {
      isLoading.value = true;
      error.value = '';

      await _notificationService.loadNotifications();

      // Update local state
      notifications.value = _notificationService.notifications;
      unreadCount.value = _notificationService.unreadCount.value;

      print('✅ Notifications loaded: ${notifications.length}');
    } catch (e) {
      print('❌ Error loading notifications: $e');
      error.value = 'Error loading notifications: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await _loadNotifications();
  }

  /// Mark notification as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      // Update local state
      notifications.value = _notificationService.notifications;
      unreadCount.value = _notificationService.unreadCount.value;

      print('✅ Notification $notificationId marked as read');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      error.value = 'Error marking notification as read: $e';
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();

      // Update local state
      notifications.value = _notificationService.notifications;
      unreadCount.value = _notificationService.unreadCount.value;

      print('✅ All notifications marked as read');
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      error.value = 'Error marking all notifications as read: $e';
    }
  }

  /// Filter notifications by status
  void filterNotifications(String filter) {
    selectedFilter.value = filter;

    if (filter == 'all') {
      notifications.value = _notificationService.notifications;
    } else {
      notifications.value = _notificationService.notifications
          .where((n) => n.status == filter)
          .toList();
    }
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

  /// Get notification count by type
  int getNotificationCountByType(String type) {
    return notifications.where((n) => n.type == type).length;
  }

  /// Get notification count by status
  int getNotificationCountByStatus(String status) {
    return notifications.where((n) => n.status == status).length;
  }

  /// Clear all notifications
  void clearAllNotifications() {
    _notificationService.clearAllNotifications();
    notifications.clear();
    unreadCount.value = 0;
  }

  /// Get filtered notifications based on current filter
  List<DriverNotification> get filteredNotifications {
    if (selectedFilter.value == 'all') {
      return notifications;
    } else {
      return notifications
          .where((n) => n.status == selectedFilter.value)
          .toList();
    }
  }

  /// Get notification types
  List<String> get notificationTypes {
    return notifications.map((n) => n.type).toSet().toList();
  }

  /// Get notification statuses
  List<String> get notificationStatuses {
    return notifications.map((n) => n.status).toSet().toList();
  }

  /// Get notifications list (for UI compatibility)
  List<DriverNotification> get notificationsList => notifications;
}
