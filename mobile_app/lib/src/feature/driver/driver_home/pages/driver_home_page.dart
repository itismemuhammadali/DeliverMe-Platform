import 'dart:async';
import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_button.dart';
import 'package:deliver_mee/src/common/utils/custom_container.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/driver/driver_home/controller/controller.dart';
import 'package:deliver_mee/src/feature/driver/driver_home/widget/driver_request_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage>
    with WidgetsBindingObserver {
  late DriverHomeController controller;
  late Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.find<DriverHomeController>();
    // Load deliveries when page is first shown
    controller.loadDeliveryRequests();
    
    // Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (mounted) {
        controller.loadDeliveryRequests();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reload deliveries when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      controller.loadDeliveryRequests();
    }
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          children: [
            SizedBox(
              height: 15.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() {
                  final controller = DriverHomeController.to;
                  final driverName = controller.driverName.isNotEmpty
                      ? controller.driverName
                      : 'Driver';
                  return TextWidget(
                    text: 'Hello, $driverName!',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.greyTextColor,
                  );
                }),
                Row(
                  children: [
                    CustomContainer(
                      onTap: () => DriverHomeController.to.refreshDeliveryRequests(),
                      height: 35,
                      width: 35,
                      borderRadius: 100.r,
                      borderColor: AppColors.brownColor,
                      child: Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Icon(
                          Icons.refresh,
                          color: AppColors.primaryColor,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20.h,
            ),
            // Delivery Requests title
            TextWidget(
              text: 'Delivery Requests',
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
            ),
            SizedBox(
              height: 20.h,
            ),
            Expanded(
              child: Obx(() {
                final controller = DriverHomeController.to;

                if (controller.isLoadingDeliveries.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.deliveryError.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64.sp,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16.h),
                        TextWidget(
                          text: 'Error loading deliveries',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                        SizedBox(height: 8.h),
                        TextWidget(
                          text: controller.deliveryError.value,
                          fontSize: 12.sp,
                          color: Colors.grey,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        CustomButton(
                          text: 'Retry',
                          ontap: () => controller.refreshDeliveryRequests(),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.deliveryRequests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 64.sp,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16.h),
                        TextWidget(
                          text: 'No delivery requests',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8.h),
                        TextWidget(
                          text: 'Check back later for new deliveries',
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshDeliveryRequests,
                  child: ListView.builder(
                    itemCount: controller.deliveryRequests.length,
                    itemBuilder: (context, index) {
                      final delivery = controller.deliveryRequests[index];

                      // Format scheduled date for display
                      String? formattedScheduledDate;
                      if (delivery.scheduledDate != null && delivery.scheduledDate!.isNotEmpty) {
                        try {
                          final dateOnly = delivery.scheduledDate!.split('T')[0]; // Handle ISO format
                          final dateTime = DateTime.parse(dateOnly);
                          final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dateTime.weekday - 1];
                          final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][dateTime.month - 1];
                          formattedScheduledDate = '$weekday, ${dateTime.day} $month';
                        } catch (e) {
                          formattedScheduledDate = delivery.scheduledDate;
                        }
                      }

                      // Format time slot for display
                      String? formattedTimeSlot;
                      if (delivery.timeSlot != null && delivery.timeSlot!.isNotEmpty) {
                        // Convert 24-hour format to 12-hour format with AM/PM
                        try {
                          final parts = delivery.timeSlot!.split('-');
                          if (parts.length == 2) {
                            String formatTime(String time24) {
                              final hour = int.parse(time24.split(':')[0]);
                              if (hour == 0) return '12:00 AM';
                              if (hour < 12) return '$hour:00 AM';
                              if (hour == 12) return '12:00 PM';
                              return '${hour - 12}:00 PM';
                            }
                            formattedTimeSlot = '${formatTime(parts[0])} - ${formatTime(parts[1])}';
                          }
                        } catch (e) {
                          formattedTimeSlot = delivery.timeSlot;
                        }
                      }

                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: DriverRequestCardWidget(
                          userInitials: _getCustomerInitials(delivery.customer?.firstName, delivery.customer?.lastName),
                          customerName: _getCustomerFullName(delivery.customer?.firstName, delivery.customer?.lastName),
                          requestedAt:
                              delivery.requestedTime ?? delivery.createdAt,
                          scheduledDate: formattedScheduledDate,
                          timeSlot: formattedTimeSlot,
                          acceptOnTap: () {
                            controller.acceptDelivery(delivery);
                          },
                          rejectOnTap: () {
                            controller.rejectDelivery(delivery);
                          },
                          viewPhotoOnTap: (ctx) {
                            controller.viewItemPhoto(delivery, ctx);
                          },
                          addressOne: delivery.pickupAddress,
                          addressTwo: delivery.dropoffAddress,
                          price: delivery.estimatedCost != null
                              ? delivery.estimatedCost!.toStringAsFixed(2)
                              : 'N/A',
                          itemName: delivery.itemName,
                          lbCount: delivery.weight != null
                              ? delivery.weight!.toStringAsFixed(1)
                              : 'N/A',
                          boxImagae: AppImages.boxImage,
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _getCustomerInitials(String? firstName, String? lastName) {
    String initials = '';
    if (firstName != null && firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName != null && lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    return initials.isEmpty ? 'C' : initials;
  }

  String? _getCustomerFullName(String? firstName, String? lastName) {
    if (firstName == null || firstName.isEmpty) {
      return null;
    }
    if (lastName == null || lastName.isEmpty) {
      return firstName;
    }
    return '$firstName $lastName';
  }
}
