import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_container.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/driver/driver_bottom_bar/pages/driver_bottom_bar_screen.dart';
import 'package:deliver_mee/src/feature/driver/driver_pick_up/controller/driver_pick_up_controller.dart';
import 'package:deliver_mee/src/feature/driver/driver_pick_up/dialogue/driver_cancel_dialogue.dart';
import 'package:deliver_mee/src/feature/user/confirm_delivery/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class DriverPickUpScreen extends StatelessWidget {
  DriverPickUpScreen({super.key});
  final DriverPickUpController ctrl = Get.find<DriverPickUpController>();

  // Get delivery data from arguments
  Map<String, dynamic>? get deliveryData =>
      Get.arguments as Map<String, dynamic>?;
  Map<String, dynamic>? get delivery => deliveryData?['delivery'];
  Map<String, dynamic>? get customer => deliveryData?['customer'];
  Map<String, dynamic>? get nextSteps => deliveryData?['next_steps'];
  Map<String, dynamic>? get originalDeliveryData =>
      deliveryData?['original_delivery'];

  void _debugDeliveryData() {
    // Debug the received data
    print('🚚 ===== DRIVER PICKUP SCREEN DEBUG =====');
    print('🚚 Full delivery data received: $deliveryData');
    print('🚚 Delivery object: $delivery');
    print('🚚 Next steps: $nextSteps');
    print('🚚 Customer: $customer');
    print('🚚 Original delivery data: $originalDeliveryData');

    if (delivery != null) {
      print('🚚 Pickup address: ${delivery!['pickup_address']}');
      print('🚚 Dropoff address: ${delivery!['dropoff_address']}');
      print(
          '🚚 Pickup coordinates: ${delivery!['pickup_latitude']}, ${delivery!['pickup_longitude']}');
      print(
          '🚚 Dropoff coordinates: ${delivery!['dropoff_latitude']}, ${delivery!['dropoff_longitude']}');
    }

    if (nextSteps != null) {
      print('🚚 Next steps pickup: ${nextSteps!['pickup_location']}');
      print('🚚 Next steps dropoff: ${nextSteps!['dropoff_location']}');
    }

    if (originalDeliveryData != null) {
      print(
          '🚚 Original pickup address: ${originalDeliveryData!['pickup_address']}');
      print(
          '🚚 Original dropoff address: ${originalDeliveryData!['dropoff_address']}');
      print(
          '🚚 Original pickup coordinates: ${originalDeliveryData!['pickup_latitude']}, ${originalDeliveryData!['pickup_longitude']}');
      print(
          '🚚 Original dropoff coordinates: ${originalDeliveryData!['dropoff_latitude']}, ${originalDeliveryData!['dropoff_longitude']}');
    }
    print('🚚 ======================================');
  }

  String _formatScheduledDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return 'N/A';
    try {
      final dateOnly = dateStr.toString().split('T')[0];
      final dateTime = DateTime.parse(dateOnly);
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final weekday = weekdays[dateTime.weekday - 1];
      final month = months[dateTime.month - 1];
      return '$weekday, ${dateTime.day} $month';
    } catch (e) {
      return dateStr.toString();
    }
  }



  int _getStepFromDeliveryStatus(String? status) {
    if (status == null) return 0;
    switch (status.toLowerCase()) {
      case 'assigned':
      case 'accepted':
        return 0;
      case 'arriving':
        return 1;
      case 'arrived':
        return 2;
      case 'picked_up':
        return 3;
      case 'in_transit':
        return 4;
      case 'delivered':
      case 'completed':
        return 5;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug the delivery data
    _debugDeliveryData();

    // Initialize current step based on delivery status
    final currentStatus = delivery?['status'] as String?;
    final initialStep = _getStepFromDeliveryStatus(currentStatus);
    final confirmController = Get.find<ConfirmDeliveryController>();
    confirmController.currentStep.value = initialStep;
    confirmController.animationController.value = initialStep / 2.0;

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with delivery info
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16.r),
                      bottomRight: Radius.circular(16.r),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppColors.blackColor),
                            onPressed: () {
                              Navigator.of(Get.context!).pop();
                            },
                          ),
                          TextWidget(
                            text: (delivery?['estimated_fare'] ?? delivery?['estimated_cost']) != null
                                ? '\$${(delivery?['estimated_fare'] ?? delivery?['estimated_cost']).toStringAsFixed(2)}'
                                : 'N/A',
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      // Delivery tracking number if available
                      if (delivery?['tracking_number'] != null)
                        TextWidget(
                          text: 'Tracking: ${delivery?['tracking_number']}',
                          fontSize: 12.sp,
                          color: AppColors.greyTextColor,
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Scheduled date and time slot
                      if (delivery?['scheduled_date'] != null || delivery?['time_slot'] != null) ...[
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Color(0xFFF0F7FF),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (delivery?['scheduled_date'] != null) ...[
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16.sp,
                                      color: AppColors.primaryColor,
                                    ),
                                    SizedBox(width: 8.w),
                                    TextWidget(
                                      text: 'Scheduled for: ${_formatScheduledDate(delivery?['scheduled_date'])}',
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
                        SizedBox(height: 16.h),
                      ],

                      // Locations
                      TextWidget(
                        text: 'Pickup Location',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, size: 18.sp, color: AppColors.primaryColor),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextWidget(
                              text: delivery?['pickup_address'] ?? 'N/A',
                              fontSize: 12.sp,
                              color: AppColors.greyTextColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      
                      TextWidget(
                        text: 'Dropoff Location',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, size: 18.sp, color: AppColors.primaryColor),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextWidget(
                              text: delivery?['dropoff_address'] ?? 'N/A',
                              fontSize: 12.sp,
                              color: AppColors.greyTextColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Step progress
                      StepProgressBar(deliveryData: delivery),
                      SizedBox(height: 16.h),

                      // Item details
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: 'Item Details',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildDetailBox('Item', delivery?['item_name'] ?? 'N/A'),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildDetailBox('Distance', '${delivery?['estimated_distance_km']?.toStringAsFixed(2) ?? 'N/A'} km'),
                                _buildDetailBox('Weight', '${delivery?['weight']?.toStringAsFixed(1) ?? '5.0'} LB'),
                              ],
                            ),
                            if (delivery?['length'] != null || delivery?['width'] != null || delivery?['height'] != null) ...[
                              SizedBox(height: 12.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (delivery?['length'] != null)
                                    _buildDetailBox('Length', '${delivery?['length']?.toStringAsFixed(2) ?? '0'}"'),
                                  if (delivery?['width'] != null)
                                    _buildDetailBox('Width', '${delivery?['width']?.toStringAsFixed(2) ?? '0'}"'),
                                  if (delivery?['height'] != null)
                                    _buildDetailBox('Height', '${delivery?['height']?.toStringAsFixed(2) ?? '0'}"'),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),



                      // Photo upload section
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.primaryColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: 'Take picture of your delivery or upload',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.blackColor,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' *',
                                    style: TextStyle(
                                      color: AppColors.redColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Camera button
                                GetBuilder<DriverPickUpController>(
                                  id: 'selecteImage',
                                  builder: (scontext) {
                                    return GestureDetector(
                                      onTap: () async {
                                        await ctrl.pickImage();
                                      },
                                      child: Container(
                                        width: 80.w,
                                        height: 80.h,
                                        decoration: BoxDecoration(
                                          color: ctrl.selectedImage != null
                                              ? AppColors.primaryColor
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(12.r),
                                          border: Border.all(
                                            color: AppColors.primaryColor,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primaryColor.withValues(alpha: 0.1),
                                              blurRadius: 8.r,
                                              spreadRadius: 2.r,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              AppIcons.cameraIcon,
                                              colorFilter: ColorFilter.mode(
                                                ctrl.selectedImage != null
                                                    ? Colors.white
                                                    : AppColors.primaryColor,
                                                BlendMode.srcIn,
                                              ),
                                              height: 28.h,
                                            ),
                                            if (ctrl.selectedImage != null)
                                              TextWidget(
                                                text: '✓',
                                                color: Colors.white,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: 16.w),
                                // File upload button
                                GetBuilder<DriverPickUpController>(
                                  id: 'pickfile',
                                  builder: (scontext) {
                                    return GestureDetector(
                                      onTap: () async {
                                        await ctrl.pickFile();
                                      },
                                      child: Container(
                                        width: 80.w,
                                        height: 80.h,
                                        decoration: BoxDecoration(
                                          color: ctrl.pickedFilePath != null
                                              ? AppColors.primaryColor
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(12.r),
                                          border: Border.all(
                                            color: AppColors.primaryColor,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primaryColor.withValues(alpha: 0.1),
                                              blurRadius: 8.r,
                                              spreadRadius: 2.r,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              AppIcons.fileUploadIcon,
                                              colorFilter: ColorFilter.mode(
                                                ctrl.pickedFilePath != null
                                                    ? Colors.white
                                                    : AppColors.primaryColor,
                                                BlendMode.srcIn,
                                              ),
                                              height: 28.h,
                                            ),
                                            if (ctrl.pickedFilePath != null)
                                              TextWidget(
                                                text: '✓',
                                                color: Colors.white,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextWidget(
                                  text: 'Camera',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.greyTextColor,
                                ),
                                SizedBox(width: 60.w),
                                TextWidget(
                                  text: 'Gallery',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.greyTextColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Action buttons
                      Obx(() {
                        final currentStep = confirmController.currentStep.value;
                        final deliveryId = delivery?['id'];
                        
                        String buttonText = 'Complete';
                        if (currentStep == 0) buttonText = 'I am Arriving';
                        else if (currentStep == 1) buttonText = 'I have Arrived';
                        else if (currentStep == 2) buttonText = 'Picked Up Item';
                        else if (currentStep == 3) buttonText = 'Going to Deliver';
                        else if (currentStep == 4) buttonText = 'Complete Delivery';
                        
                        return Row(
                          children: [
                            // Cancel button (only show before transit)
                            if (currentStep < 3)
                              Expanded(
                                child: SizedBox(
                                  height: 48.h,
                                  child: Material(
                                    color: AppColors.redColor,
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: InkWell(
                                      onTap: () {
                                        _showCancelConfirmationDialog();
                                      },
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Center(
                                        child: TextWidget(
                                          text: 'Cancel',
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (currentStep < 3) SizedBox(width: 12.w),
                            
                            // Dynamic Action Button
                            Expanded(
                              child: SizedBox(
                                height: 48.h,
                                child: Material(
                                  color: ctrl.isLoading.value 
                                      ? Colors.grey 
                                      : AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: InkWell(
                                    onTap: ctrl.isLoading.value ? null : () async {
                                      print('🖱️ Action button clicked at step: $currentStep');
                                      if (deliveryId == null) {
                                        print('❌ Delivery ID is NULL');
                                        Get.snackbar('Error', 'Delivery ID not found',
                                            backgroundColor: Colors.red, colorText: Colors.white);
                                        return;
                                      }

                                      bool success = false;
                                      if (currentStep == 0) {
                                        print('ℹ️ Starting Arriving');
                                        success = await ctrl.startArrivingDelivery(deliveryId);
                                      } else if (currentStep == 1) {
                                        print('ℹ️ Starting Reached');
                                        success = await ctrl.reachedDelivery(deliveryId);
                                      } else if (currentStep == 2) {
                                        print('ℹ️ Starting Pickup');
                                        success = await ctrl.pickupDelivery(deliveryId);
                                      } else if (currentStep == 3) {
                                        print('ℹ️ Starting Transit');
                                        success = await ctrl.startTransitDelivery(deliveryId);
                                      } else if (currentStep == 4) {
                                        print('ℹ️ Starting Complete');
                                        // Removed mandatory image check for testing
                                        success = await ctrl.completeDelivery(deliveryId);
                                        print('ℹ️ Complete success: $success');
                                        if (success) {
                                          print('🚀 Navigating back to home');
                                          Get.offAll(() => DriverBottomBarScreen(),
                                              transition: Transition.cupertino);
                                          return;
                                        }
                                      }

                                      if (success) {
                                        print('✅ Action successful, moving to next step');
                                        confirmController.nextStep();
                                      } else {
                                        print('❌ Action failed at step: $currentStep');
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Center(
                                      child: ctrl.isLoading.value
                                          ? SizedBox(
                                              height: 20.h,
                                              width: 20.w,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : TextWidget(
                                              text: buttonText,
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryBox(String label, String value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            TextWidget(
                text: "${label} ${value}",
                fontWeight: FontWeight.w400,
                fontSize: 14.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBox(String label, String value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            TextWidget(
              text: label,
              fontWeight: FontWeight.w400,
              fontSize: 10.sp,
              color: AppColors.greyTextColor,
            ),
            SizedBox(height: 4.h),
            TextWidget(
              text: value,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showCancellationReviewDialog(int deliveryId, String reason) {
    // Directly cancel the delivery without additional feedback
    ctrl.cancelDelivery(
      deliveryId: deliveryId,
      cancellationReason: reason,
      rating: null,
      review: null,
    );
  }

  void _showCancelConfirmationDialog() {
    final deliveryId = delivery?['id'] as int?;
    if (deliveryId == null) {
      showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Delivery ID not found'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    Get.dialog(
      Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.redColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: AppColors.redColor,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 16.h),
              TextWidget(
                text: 'Cancel Delivery?',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
              SizedBox(height: 8.h),
              TextWidget(
                text: 'Are you sure you want to cancel this delivery? This action cannot be undone.',
                fontSize: 13.sp,
                color: AppColors.greyTextColor,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  // Left button - Green outline style
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(Get.context!);
                          },
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primaryColor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: TextWidget(
                                text: 'No, Keep It',
                                color: AppColors.primaryColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Right button - Red filled style (like Cancel Delivery)
                  Expanded(
                    child: SizedBox(
                      height: 48.h,
                      child: Material(
                        color: AppColors.redColor,
                        borderRadius: BorderRadius.circular(8.r),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(Get.context!);
                            // Show reason dialog
                            Get.dialog(driverCancleDialogue(
                              deliveryId: deliveryId,
                              onReasonSubmit: (reason) {
                                Navigator.pop(Get.context!);
                                _showCancellationReviewDialog(
                                  deliveryId,
                                  reason,
                                );
                              },
                            ));
                          },
                          borderRadius: BorderRadius.circular(8.r),
                          child: Center(
                            child: TextWidget(
                              text: 'Yes, Cancel',
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget buildPickupDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        StepProgressBar(deliveryData: delivery),
        SizedBox(height: 10.h),
        Row(
          children: [
            _summaryBox("Total Item", "${delivery?['item_count'] ?? '2'}"),
            _summaryBox("Item", "${delivery?['package_size'] ?? 'Small'}"),
            _summaryBox(
                "${delivery?['weight']?.toStringAsFixed(1) ?? '5.5'}", "LB"),
          ],
        ),
        SizedBox(height: 15.h),
        TextWidget(
          text: 'Preference',
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGreayTextColor,
        ),
        SizedBox(height: 10.h),
        TextWidget(
          text: delivery?['delivery_type'] == 'signature_required'
              ? 'Signature Required: Customer must sign for delivery.'
              : 'Leave at Residence/Location: Permission is granted for the driver to leave the item at the residence/location.',
          fontSize: 12.sp,
          color: AppColors.greyTextColor,
        ),
        SizedBox(
          height: 10.h,
        ),
        TextWidget(
          text: 'Extra Delivery Notes',
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.darkGreayTextColor,
        ),
        SizedBox(
          height: 10.h,
        ),
        TextWidget(
          text: delivery?['special_instructions'] ?? 'Call upon arrival.',
          fontSize: 12.sp,
          color: AppColors.greyTextColor,
        ),
        SizedBox(
          height: 10.h,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  text: 'Take picture of your delivery or upload ',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.blackColor,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        color: AppColors.redColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GetBuilder<DriverPickUpController>(
              id: 'pickfile',
              builder: (scontext) {
                return GestureDetector(
                  onTap: () async {
                    await ctrl.pickFile();
                  },
                  child: ctrl.pickedFilePath != null
                      ? Container(
                          width: 35.w,
                          height: 35.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: TextWidget(
                                text: '...',
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        )
                      : CustomContainer(
                          width: 39.w,
                          height: 30.h,
                          borderRadius: 6.r,
                          color: Color(0xffe3e3e3),
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: SvgPicture.asset(AppIcons.fileUploadIcon),
                          ),
                        ),
                );
              },
            ),
            SizedBox(width: 10.w),
            GetBuilder<DriverPickUpController>(
              id: 'selecteImage',
              builder: (scontext) {
                return GestureDetector(
                  onTap: () async {
                    await ctrl.pickImage();
                  },
                  child: ctrl.selectedImage != null
                      ? Container(
                          width: 35.w,
                          height: 35.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: TextWidget(
                                text: '...',
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        )
                      : CustomContainer(
                          onTap: () async {
                            await DriverPickUpController.to.pickImage();
                          },
                          width: 39.w,
                          height: 30.h,
                          borderRadius: 6.r,
                          color: Color(0xffe3e3e3),
                          child: Padding(
                            padding: EdgeInsets.all(2.0),
                            child: SvgPicture.asset(AppIcons.cameraIcon),
                          ),
                        ),
                );
              },
            ),
          ],
        )
      ],
    );
  }
}

class StepProgressBar extends StatelessWidget {
  final Map<String, dynamic>? deliveryData;

  StepProgressBar({Key? key, this.deliveryData}) : super(key: key);

  final List<String> assets = [
    AppIcons.markerIcon,
    AppIcons.homeIcon,
    AppIcons.twoIcon,
    AppIcons.threeIcon,
    AppIcons.fourIcon,
  ];
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConfirmDeliveryController>();
    final ctrl = Get.find<DriverPickUpController>();

    return Container(
      height: 60.h,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // BASE LINE
          Positioned(
            left: 40.w,
            right: 40.w,
            child: Container(
              height: 2.h,
              color: Colors.grey.shade300,
            ),
          ),
          // ANIMATED BLACK LINE
          Positioned(
            left: 40.w,
            right: 40.w,
            child: AnimatedBuilder(
              animation: controller.animationController,
              builder: (_, __) {
                return FractionallySizedBox(
                  widthFactor: controller.progressAnimation.value,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 2.h,
                    color: Colors.black,
                  ),
                );
              },
            ),
          ),
          // STEP ICONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              return Obx(() {
                // Icons become active at these steps:
                // index 0 (Marker): Step 1 (Arriving)
                // index 1 (Home): Step 2 (Arrived)
                // index 2 (Bag): Step 3 (Picked Up)
                // index 3 (Car): Step 4 (Going to Deliver)
                // index 4 (Done): Step 5 (Completed)
                bool isActive = controller.currentStep.value > index;
                bool isCurrentLoading = ctrl.isLoading.value && controller.currentStep.value == index;

                return Container(
                  height: 35.h,
                  width: 35.w,
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCurrentLoading 
                        ? AppColors.primaryColor 
                        : (isActive ? Colors.black : Colors.white),
                    border: Border.all(
                      color: isCurrentLoading 
                          ? AppColors.primaryColor 
                          : (isActive ? Colors.black : Colors.grey.shade400),
                      width: 1,
                    ),
                  ),
                  child: isCurrentLoading
                      ? Center(
                          child: SizedBox(
                            height: 15.h,
                            width: 15.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      : SvgPicture.asset(
                          assets[index],
                          colorFilter: ColorFilter.mode(
                            isActive ? Colors.white : Colors.grey,
                            BlendMode.srcIn,
                          ),
                          height: 25.h,
                          width: 25.w,
                        ),
                );
              });
            }),
          ),
        ],
      ),
    );
  }
}
