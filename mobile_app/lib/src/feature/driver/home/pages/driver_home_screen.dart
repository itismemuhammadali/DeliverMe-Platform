import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../common/constant/app_colors.dart';
import '../../../../common/utils/custom_button.dart';
import '../../driver_home/controller/controller.dart';

class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = DriverHomeController.to;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.error.value.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.w,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Error',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    controller.error.value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.greyColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  CustomButton(
                    text: 'Retry',
                    ontap: () => controller.refreshDriverData(),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.refreshDriverData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25.r,
                        backgroundColor: AppColors.primaryColor,
                        child: Text(
                          controller.driverName.isNotEmpty
                              ? controller.driverName[0].toUpperCase()
                              : 'D',
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.greyColor,
                              ),
                            ),
                            Text(
                              controller.driverName.isNotEmpty
                                  ? controller.driverName
                                  : 'Driver',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blackColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Notification icon
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () =>
                                Get.toNamed('/driver/notifications'),
                            icon: Icon(
                              Icons.notifications_outlined,
                              size: 24.w,
                              color: AppColors.blackColor,
                            ),
                          ),
                          if (controller.unreadNotificationCount > 0)
                            Positioned(
                              right: 8.w,
                              top: 8.h,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 16.w,
                                  minHeight: 16.h,
                                ),
                                child: Text(
                                  '${controller.unreadNotificationCount}',
                                  style: TextStyle(
                                    color: AppColors.whiteColor,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 30.h),

                  // Status Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              controller.isOnline
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: controller.isOnline
                                  ? Colors.green
                                  : Colors.red,
                              size: 24.w,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.isOnline ? 'Online' : 'Offline',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.blackColor,
                                    ),
                                  ),
                                  Text(
                                    controller.isOnline
                                        ? 'You are available for rides'
                                        : 'You are not available for rides',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.greyColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        CustomButton(
                          text: controller.isAvailable.value
                              ? 'Go Offline'
                              : 'Go Online',
                          ontap: () => controller.toggleAvailability(),
                          buttonColor: controller.isAvailable.value
                              ? Colors.red
                              : Colors.green,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Driver Stats
                  Text(
                    'Your Stats',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.star,
                          title: 'Rating',
                          value: controller.rating != null
                              ? '${controller.rating!.toStringAsFixed(1)} ⭐'
                              : 'N/A',
                          color: Colors.amber,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.local_taxi,
                          title: 'Total Rides',
                          value: '${controller.totalRides ?? 0}',
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Vehicle Info
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: AppColors.greyColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.directions_car,
                              color: AppColors.primaryColor,
                              size: 24.w,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              'Vehicle Information',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blackColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          controller.vehicleInfo.isNotEmpty
                              ? controller.vehicleInfo
                              : 'No vehicle information',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.greyColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Plate: ${controller.currentDriver.value?.vehiclePlate ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.greyColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.person,
                          title: 'Profile',
                          onTap: () => Get.toNamed('/driver/profile'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.notifications,
                          title: 'Notifications',
                          onTap: () => Get.toNamed('/driver/notifications'),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.schedule,
                          title: 'Schedule',
                          onTap: () => Get.toNamed('/driver/schedule'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.help,
                          title: 'Support',
                          onTap: () => Get.toNamed('/driver/support'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32.w,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.greyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.greyColor.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primaryColor,
              size: 32.w,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
