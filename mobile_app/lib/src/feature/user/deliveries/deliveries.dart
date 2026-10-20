import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/user/schedule/controller.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
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
          text: 'My Deliveries',
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.deliveries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.deliveries.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 80.w,
                      color: Colors.grey[300],
                    ),
                    SizedBox(height: 24.h),
                    TextWidget(
                      text: 'No deliveries yet',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    TextWidget(
                      text:
                          'Create your first delivery from the Home tab to get started',
                      fontSize: 14.sp,
                      textAlign: TextAlign.center,
                      color: Colors.grey[600],
                      maxLines: 2,
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
                final status = d.status.toUpperCase();

                Color statusColor;
                switch (status) {
                  case 'DELIVERED':
                    statusColor = Colors.green;
                    break;
                  case 'IN_TRANSIT':
                  case 'PICKED_UP':
                    statusColor = Colors.blue;
                    break;
                  case 'CANCELLED':
                    statusColor = Colors.red;
                    break;
                  default:
                    statusColor = Colors.orange;
                }

                return Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: TextWidget(
                              text: status.replaceAll('_', ' '),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                          const Spacer(),
                          if (d.trackingNumber != null)
                            TextWidget(
                              text: '#${d.trackingNumber}',
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16.w,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextWidget(
                              text: d.pickupAddress,
                              fontSize: 13.sp,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 16.w,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextWidget(
                              text: d.dropoffAddress,
                              fontSize: 13.sp,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          if (d.estimatedCost != null) ...[
                            Icon(
                              Icons.attach_money,
                              size: 16.w,
                              color: AppColors.primaryColor,
                            ),
                            TextWidget(
                              text: '\$${d.estimatedCost!.toStringAsFixed(2)}',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          ],
                          const Spacer(),
                        ],
                      ),
                    ],
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
