import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_container.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/common/services/driver_api_service.dart';
import 'package:deliver_mee/src/feature/driver/driver_home/controller/controller.dart';
import 'package:deliver_mee/src/feature/driver/driver_pick_up/page/driver_pick_up_screen.dart';
import 'package:deliver_mee/src/feature/driver/driver_schedule/controller/driver_schedule_controller.dart';
import 'package:deliver_mee/src/models/delivery_model.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class DriverSchudlePage extends StatelessWidget {
  const DriverSchudlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DriverScheduleController());

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() {
                  // Get driver name from DriverHomeController if available
                  try {
                    final homeController = Get.find<DriverHomeController>();
                    final driverName = homeController.driverName.isNotEmpty
                        ? homeController.driverName
                        : 'Driver';
                    return TextWidget(
                      text: 'Hello, $driverName!',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyTextColor,
                    );
                  } catch (e) {
                    return TextWidget(
                      text: 'Hello, Driver!',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.greyTextColor,
                    );
                  }
                }),
                Row(
                  children: [
                    CustomContainer(
                      onTap: () => controller.refreshDeliveries(),
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
              height: 10.h,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextWidget(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.greyTextColor,
                text: 'Scheduled Deliveries',
              ),
            ),
            SizedBox(
              height: 10.h,
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.deliveries.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.hasError.value) {
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
                          text: controller.errorMessage.value,
                          fontSize: 12.sp,
                          color: Colors.grey,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => controller.refreshDeliveries(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.deliveries.isEmpty) {
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
                          text: 'No deliveries assigned',
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
                  onRefresh: controller.refreshDeliveries,
                  child: ListView.separated(
                    itemCount: controller.deliveries.length +
                        (controller.hasMoreData.value ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      if (index == controller.deliveries.length) {
                        // Load more indicator
                        if (controller.isLoading.value) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        } else {
                          // Trigger load more
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            controller.loadMoreDeliveries();
                          });
                          return const SizedBox.shrink();
                        }
                      }

                      final delivery = controller.deliveries[index];
                      return buildBookingCard(delivery, controller, context);
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

  Widget buildBookingCard(
      DeliveryModel delivery, DriverScheduleController controller, BuildContext context) {


    // Get vehicle image based on vehicle type
    String getVehicleImage(String vehicleType) {
      switch (vehicleType.toLowerCase()) {
        case 'sedan':
          return AppImages.carimgr;
        case 'suv':
          return AppImages.suvsimgr;
        case 'truck':
          // Box Truck logo removed from app — use pickup truck as fallback image
          return AppImages.pickuptruckimgr;
        case 'van':
          return AppImages.cargovanimgr;
        case 'pickup':
          return AppImages.pickuptruckimgr;
        default:
          return AppImages.cargovanimgr;
      }
    }

    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 18.w, top: 10.h),
                child: Image.asset(
                  getVehicleImage(delivery.vehicleType),
                  height: 20.h,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: delivery.customer?.fullName ?? "Customer",
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  TextWidget(
                    text: controller
                        .getVehicleTypeDisplayName(delivery.vehicleType),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextWidget(
                    text: delivery.estimatedCost != null
                        ? "\$${delivery.estimatedCost!.toStringAsFixed(2)}"
                        : "N/A",
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(delivery.status),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: TextWidget(
                      text: controller.getStatusDisplayName(delivery.status),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  )
                ],
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 7.h,
            ),
            child: Divider(
              color: Colors.grey.shade200,
            ),
          ),

          // Location Info
          Row(
            children: [
              SvgPicture.asset(
                AppIcons.markerIcon,
                height: 20.h,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TextWidget(
                  text: delivery.pickupAddress,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            child: DottedLine(
              dashLength: 4.w,
              dashColor: Colors.grey.shade200,
            ),
          ),
          Row(
            children: [
              SvgPicture.asset(
                AppIcons.locationIcon,
                height: 18.h,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TextWidget(
                  text: delivery.dropoffAddress,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 7.h,
            ),
            child: Divider(
              color: Colors.grey.shade200,
            ),
          ),

          // Scheduled Date & Time Slot (if booking has scheduled date/time)
          if (delivery.scheduledDate != null || delivery.timeSlot != null) ...[
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (delivery.scheduledDate != null &&
                      delivery.scheduledDate!.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14.sp,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(width: 6.w),
                        TextWidget(
                          text: controller.formatDate(delivery.scheduledDate),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ],
                  if (delivery.timeSlot != null &&
                      delivery.timeSlot!.isNotEmpty) ...[
                    if (delivery.scheduledDate != null &&
                        delivery.scheduledDate!.isNotEmpty)
                      SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14.sp,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(width: 6.w),
                        TextWidget(
                          text: 'Time Slot: ${_formatTimeSlot(delivery.timeSlot)}',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 12.h),
          ],



          // Start Delivery button and View Image button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // View Image Button
              GestureDetector(
                onTap: () => controller.viewItemPhoto(delivery, context),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                  ),
                  child: TextWidget(
                    text: 'View Image',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              // Start Delivery button
              GestureDetector(
                onTap: () async {
                  // Call API to update delivery status to "arriving"
                  try {
                    await DriverApiService.startArrivingDelivery(
                      delivery.id ?? 0,
                    );
                    
                    // Navigate to pickup screen
                    await Get.to(
                      () => DriverPickUpScreen(),
                      arguments: {
                        'success': true,
                        'delivery': delivery.toJson(),
                        'customer': delivery.customer?.toJson(),
                        'next_steps': {
                          'pickup_location': delivery.pickupAddress,
                          'dropoff_location': delivery.dropoffAddress,
                        },
                        'original_delivery': delivery.toJson(),
                      },
                      transition: Transition.cupertino,
                    );
                    
                    // Refresh deliveries after returning from pickup screen
                    print('🔄 Refreshing deliveries after returning from pickup screen');
                    await controller.refreshDeliveries();
                  } catch (e) {
                    print('❌ Error starting delivery: $e');
                    Get.snackbar(
                      'Error',
                      'Failed to start delivery: ${e.toString()}',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  }
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: (delivery.status == 'arriving' || delivery.status == 'arrived' || delivery.status == 'picked_up' || delivery.status == 'in_transit') 
                          ? AppColors.greyColor 
                          : AppColors.primaryColor,
                      width: 1,
                    ),
                    color: (delivery.status == 'arriving' || delivery.status == 'arrived' || delivery.status == 'picked_up' || delivery.status == 'in_transit') 
                        ? AppColors.greyColor.withValues(alpha: 0.3)
                        : AppColors.primaryColor,
                  ),
                  child: TextWidget(
                    text: (delivery.status == 'arriving' || delivery.status == 'arrived' || delivery.status == 'picked_up' || delivery.status == 'in_transit') 
                        ? 'In Progress' 
                        : 'Start Delivery',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: (delivery.status == 'arriving' || delivery.status == 'arrived' || delivery.status == 'picked_up' || delivery.status == 'in_transit') 
                        ? AppColors.greyColor 
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // Additional info row
          if (delivery.itemName.isNotEmpty ||
              delivery.specialInstructions != null)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (delivery.itemName.isNotEmpty)
                    TextWidget(
                      text: "Item: ${delivery.itemName}",
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  if (delivery.specialInstructions != null &&
                      delivery.specialInstructions!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: TextWidget(
                        text: "Note: ${delivery.specialInstructions}",
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return Colors.blue;
      case 'picked_up':
        return Colors.orange;
      case 'in_transit':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.primaryColor;
    }
  }

  String _formatTimeSlot(String? timeSlot) {
    if (timeSlot == null || timeSlot.isEmpty) return 'N/A';
    try {
      final parts = timeSlot.split('-');
      if (parts.length == 2) {
        String formatTime(String time24) {
          final hour = int.parse(time24.split(':')[0]);
          if (hour == 0) return '12:00 AM';
          if (hour < 12) return '$hour:00 AM';
          if (hour == 12) return '12:00 PM';
          return '${hour - 12}:00 PM';
        }
        return '${formatTime(parts[0])} - ${formatTime(parts[1])}';
      }
      return timeSlot;
    } catch (e) {
      return timeSlot;
    }
  }
}
