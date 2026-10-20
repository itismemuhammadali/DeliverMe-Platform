import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/feature/user/notification/notification.dart';
import 'package:get/get.dart';

class UserNotificationController extends GetxController {
  static UserNotificationController get to =>
      Get.find<UserNotificationController>();

  List<NotificationModel> notificationsList = [
    NotificationModel(
      userImage: AppImages.driverimg,
      title: 'Your delivery starts in 10 minutes.',
      timeRange: 'Booking of 3:30PM to 4:00PM',
      date: 'Today',
    ),
    NotificationModel(
      userImage: AppImages.profileimage,
      title: 'New delivery has been assigned.',
      timeRange: 'Booking of 2:00PM to 2:30PM',
      date: 'Tomorrow',
    ),
    NotificationModel(
      userImage: AppImages.driverimg,
      title: 'Reminder: Your shift starts soon.',
      timeRange: 'Shift from 9:00AM to 5:00PM',
      date: 'Monday',
    ),
    NotificationModel(
      userImage: AppImages.profileimage,
      title: 'Your delivery starts in 10 minutes.',
      timeRange: 'Booking of 3:30PM to 4:00PM',
      date: 'Today',
    ),
    NotificationModel(
      userImage: AppImages.driverimg,
      title: 'New delivery has been assigned.',
      timeRange: 'Booking of 2:00PM to 2:30PM',
      date: 'Tomorrow',
    ),
    NotificationModel(
      userImage: AppImages.profileimage,
      title: 'Reminder: Your shift starts soon.',
      timeRange: 'Shift from 9:00AM to 5:00PM',
      date: 'Monday',
    ),
    NotificationModel(
      userImage: AppImages.driverimg,
      title: 'Your delivery starts in 10 minutes.',
      timeRange: 'Booking of 3:30PM to 4:00PM',
      date: 'Today',
    ),
    NotificationModel(
      userImage: AppImages.profileimage,
      title: 'New delivery has been assigned.',
      timeRange: 'Booking of 2:00PM to 2:30PM',
      date: 'Tomorrow',
    ),
    NotificationModel(
      userImage: AppImages.driverimg,
      title: 'Reminder: Your shift starts soon.',
      timeRange: 'Shift from 9:00AM to 5:00PM',
      date: 'Monday',
    ),
  ];
}
