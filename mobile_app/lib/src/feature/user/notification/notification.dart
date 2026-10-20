import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/custom_app_bar.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/user/confirm_delivery/confirm_delivery.dart';
import 'package:deliver_mee/src/feature/user/notification/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    final UserNotificationController ctrl =
        Get.find<UserNotificationController>();
    return Scaffold(
      appBar: CustomAppBar(text: "Notifications", leading: true),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Container(
            height: ScreenUtil().screenHeight,
            width: ScreenUtil().screenWidth,
            child: GetBuilder<UserNotificationController>(builder: (obj) {
              return ListView.builder(
                itemCount: ctrl.notificationsList.length,
                itemBuilder: (context, index) => Dismissible(
                    background: stackBehindDismiss(),
                    secondaryBackground: secondarystackBehindDismiss(),
                    key: ObjectKey(index),
                    child: notificationCard(
                      userImage: ctrl.notificationsList[index].userImage,
                      title: ctrl.notificationsList[index].title,
                      timeRange: ctrl.notificationsList[index].timeRange,
                      date: ctrl.notificationsList[index].date,
                      onTrackPressed: () {
                        Get.to(() => ConfirmDeliveryScreen(),
                            transition: Transition.cupertino);
                      },
                    ),
                    onDismissed: (direction) {},
                    confirmDismiss: (DismissDirection direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        ctrl.notificationsList.removeAt(index);
                        ctrl.update();
                      } else {
                        ctrl.notificationsList.removeAt(index);
                        ctrl.update();
                      }
                      return null;
                    }),
              );
            })),
      ),
    );
  }

  Widget secondarystackBehindDismiss() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13.r),
        color: Colors.transparent,
      ),
    );
  }

  Widget stackBehindDismiss() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13.r),
        color: Colors.transparent,
      ),
    );
  }

  Widget notificationCard({
    required String userImage,
    required String title,
    required String timeRange,
    required String date,
    VoidCallback? onTrackPressed,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(30.r),
            child: Image.asset(
              userImage,
              width: 40.w,
              height: 40.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 10.w),

          // Texts and Button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: title,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 4.h),
                TextWidget(
                  text: timeRange,
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  height: 30.h,
                  child: ElevatedButton(
                    onPressed: onTrackPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade900,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      elevation: 0,
                    ),
                    child: TextWidget(
                      text: "Track Delivery",
                      fontSize: 11.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              ],
            ),
          ),

          // Dot & Time
          Column(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 36.h),
              TextWidget(
                text: date,
                fontSize: 11.sp,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NotificationModel {
  final String userImage;
  final String title;
  final String timeRange;
  final String date;

  NotificationModel({
    required this.userImage,
    required this.title,
    required this.timeRange,
    required this.date,
  });
}
