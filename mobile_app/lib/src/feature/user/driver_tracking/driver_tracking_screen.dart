import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/common/services/customer_delivery_tracking_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverTrackingScreen extends StatefulWidget {
  const DriverTrackingScreen({super.key});

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final trackingService = Get.find<CustomerDeliveryTrackingService>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: TextWidget(
          text: 'Track Delivery',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        centerTitle: true,
      ),
      body: Obx(() => Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Driver info card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      // Driver avatar
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 40.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Driver name
                      TextWidget(
                        text: trackingService.driverName.value.isNotEmpty
                            ? trackingService.driverName.value
                            : 'Driver',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      SizedBox(height: 8.h),

                      // Driver rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16.sp),
                          SizedBox(width: 4.w),
                          TextWidget(
                            text: trackingService.driverRating.value.isNotEmpty
                                ? trackingService.driverRating.value
                                : '4.5',
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Contact button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // Get phone from tracking service
                            String? phone = trackingService.driverPhone.value;
                            
                            // If not in service, try from driver data
                            if (phone.isEmpty && trackingService.driverData.isNotEmpty) {
                              phone = trackingService.driverData['phone']?.toString() ?? 
                                      trackingService.driverData['phone_number']?.toString() ?? '';
                            }
                            
                            // If still empty, try from delivery data
                            if (phone.isEmpty && trackingService.deliveryData['driver'] != null) {
                              final driver = trackingService.deliveryData['driver'] as Map<String, dynamic>;
                              phone = driver['phone']?.toString() ?? 
                                      driver['phone_number']?.toString() ?? '';
                            }
                            
                            if (phone.isNotEmpty) {
                              try {
                                // Ensure phone number has + prefix for international format
                                if (!phone.startsWith('+')) {
                                  phone = '+$phone';
                                }
                                
                                final Uri phoneUri = Uri(scheme: 'tel', path: phone);
                                if (await canLaunchUrl(phoneUri)) {
                                  await launchUrl(phoneUri);
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Cannot make phone calls on this device',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              } catch (e) {
                                print('❌ Error launching phone dialer: $e');
                                Get.snackbar(
                                  'Error',
                                  'Failed to open phone dialer',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            } else {
                              Get.snackbar(
                                'Phone Not Available',
                                'Driver phone number is not available',
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            }
                          },
                          icon: Icon(Icons.phone, size: 18.sp),
                          label: TextWidget(
                            text: 'Call Driver',
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Status card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: 'Delivery Status',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      SizedBox(height: 16.h),

                      // Status message
                      TextWidget(
                        text: trackingService.statusMessage.value,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(height: 8.h),

                      // Sub status message
                      TextWidget(
                        text: trackingService.subStatusMessage.value,
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(height: 16.h),

                      // Estimated arrival
                      if (trackingService.estimatedArrival.value.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 16.sp, color: Colors.grey[600]),
                            SizedBox(width: 8.w),
                            TextWidget(
                              text: 'ETA: ${trackingService.estimatedArrival.value}',
                              fontSize: 14.sp,
                              color: Colors.grey[700],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Progress indicator
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      TextWidget(
                        text: 'Delivery Progress',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      SizedBox(height: 16.h),
                      LinearProgressIndicator(
                        value: trackingService.progressValue.value,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor),
                      ),
                      SizedBox(height: 8.h),
                      TextWidget(
                        text:
                            '${(trackingService.progressValue.value * 100).toInt()}% Complete',
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),

                Spacer(),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Implement message functionality
                          Get.snackbar(
                            'Message Driver',
                            'Messaging ${trackingService.driverName.value}...',
                            backgroundColor: Colors.blue,
                            colorText: Colors.white,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          side: BorderSide(color: AppColors.primaryColor),
                        ),
                        child: TextWidget(
                          text: 'Message',
                          fontSize: 16.sp,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement tracking functionality
                          Get.snackbar(
                            'Live Tracking',
                            'Opening live tracking...',
                            backgroundColor: AppColors.primaryColor,
                            colorText: Colors.white,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: TextWidget(
                          text: 'Live Track',
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
