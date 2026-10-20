import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/custom_app_bar.dart';
import 'package:deliver_mee/src/common/utils/custom_container.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/driver/driver_pick_up/page/driver_pick_up_screen.dart';
import 'package:deliver_mee/src/feature/driver/notification/controller/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DriverNotificationPage extends StatelessWidget {
  const DriverNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DriverNotificationController ctrl =
        Get.find<DriverNotificationController>();
    return Scaffold(
      appBar: CustomAppBar(text: 'Notifications', leading: true),
      body: Padding(
        padding: EdgeInsets.all(15.h),
        child: Column(
          children: [
            Expanded(
                child: GetBuilder<DriverNotificationController>(builder: (obj) {
              return ListView.builder(
                itemCount: ctrl.notificationsList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Dismissible(
                        background: stackBehindDismiss(),
                        secondaryBackground: secondarystackBehindDismiss(),
                        key: ObjectKey(index),
                        child: CustomContainer(
                          color: AppColors.containerColor,
                          borderRadius: 12.r,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          boxShadow: [
                            BoxShadow(
                                offset: Offset(0, 4),
                                blurRadius: 4,
                                color: AppColors.blackColor.withValues(alpha: .15))
                          ],
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CircleAvatar(
                                radius: 26.r,
                                backgroundImage: AssetImage(
                                    ctrl.notificationsList[index].userImage ??
                                        'assets/images/girl.png'),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 245.w,
                                    child: TextWidget(
                                      text: ctrl.notificationsList[index].title,
                                      fontSize: 13.sp,
                                      color: AppColors.naveBlue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 245.w,
                                    child: TextWidget(
                                      text: ctrl.notificationsList[index]
                                              .timeRange ??
                                          'Just now',
                                      fontSize: 13.sp,
                                      color: AppColors.naveBlue,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  SizedBox(
                                    height: 30.h,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Get.to(() => DriverPickUpScreen(),
                                            transition: Transition.cupertino);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo.shade900,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.w),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.r),
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
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 17.r,
                                    color: AppColors.primaryColor,
                                  ),
                                  SizedBox(
                                    height: 40.h,
                                  ),
                                  TextWidget(
                                    text: ctrl.notificationsList[index].date ??
                                        'Today',
                                    fontSize: 13.sp,
                                    color: AppColors.darkGreayTextColor,
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        onDismissed: (direction) {
                          if (direction == DismissDirection.startToEnd) {
                          } else {}
                        },
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
                },
              );
            }))
          ],
        ),
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
}
