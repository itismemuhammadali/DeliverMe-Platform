import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/user/delivery_tracking/pages/customer_delivery_tracking_page.dart';
import 'package:deliver_mee/src/feature/user/schedule/controller.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize controller if not already initialized
    if (!Get.isRegistered<CustomerScheduleController>()) {
      Get.put(CustomerScheduleController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomerScheduleController>();

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: TextWidget(
          text: 'Scheduled Deliveries',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.deliveries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.deliveries.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64.w,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    TextWidget(
                      text: 'No scheduled deliveries yet',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    TextWidget(
                      text: 'Create your first delivery from the Home tab',
                      fontSize: 14.sp,
                      textAlign: TextAlign.center,
                      color: Colors.grey[600],
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () => controller.refreshDeliveries(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32.w,
                          vertical: 12.h,
                        ),
                      ),
                      child: TextWidget(
                        text: 'Refresh',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.deliveries.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 64.w,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    TextWidget(
                      text: 'No deliveries yet',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    TextWidget(
                      text: 'Start by creating a delivery from Home',
                      fontSize: 14.sp,
                      textAlign: TextAlign.center,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.refreshDeliveries(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              itemCount: controller.deliveries.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final d = controller.deliveries[index];
                // Show payment status if pending, otherwise show delivery status
                final status = (d.paymentStatus == 'pending' || d.status == 'pending_payment')
                    ? 'PAYMENT PENDING'
                    : d.status.toUpperCase();
                
                // Allow tracking for ALL statuses
                return InkWell(
                  onTap: () {
                    Get.to(
                      () => CustomerDeliveryTrackingPage(
                        deliveryId: d.id,
                        initialData: d.toJson(),
                        viewOnly: false,
                      ),
                      transition: Transition.cupertino,
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.35),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text: 'Status: $status',
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                  if (d.paymentStatus != null &&
                                      d.paymentStatus!.isNotEmpty)
                                    TextWidget(
                                      text:
                                          'Payment: ${d.paymentStatus!.toUpperCase()}',
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                      color: d.paymentStatus == 'paid'
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                ],
                              ),
                            ),
                            TextWidget(
                              text: 'Track',
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        TextWidget(
                          text: 'From: ${d.pickupAddress}',
                          fontSize: 12.sp,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        TextWidget(
                          text: 'To: ${d.dropoffAddress}',
                          fontSize: 12.sp,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            const Spacer(),
                            if (d.estimatedCost != null)
                              TextWidget(
                                text:
                                    '\$${d.estimatedCost!.toStringAsFixed(2)}',
                                fontWeight: FontWeight.w600,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
