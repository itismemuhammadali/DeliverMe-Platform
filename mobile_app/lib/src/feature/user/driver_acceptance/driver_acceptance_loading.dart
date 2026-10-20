import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/user/driver_acceptance/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DriverAcceptanceLoadingScreen extends StatefulWidget {
  final String deliveryId;
  final String trackingNumber;
  final double amount;
  final String fromLocation;
  final String toLocation;

  const DriverAcceptanceLoadingScreen({
    super.key,
    required this.deliveryId,
    required this.trackingNumber,
    required this.amount,
    required this.fromLocation,
    required this.toLocation,
  });

  @override
  State<DriverAcceptanceLoadingScreen> createState() =>
      _DriverAcceptanceLoadingScreenState();
}

class _DriverAcceptanceLoadingScreenState
    extends State<DriverAcceptanceLoadingScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    // Create animations
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Start animations
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();

    // Start checking for driver acceptance
    _startDriverAcceptanceCheck();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _startDriverAcceptanceCheck() {
    // Get the controller and start checking for driver acceptance
    final controller = Get.find<DriverAcceptanceController>();
    controller.startCheckingDriverAcceptance(widget.deliveryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black87,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: TextWidget(
                      text: 'Waiting for Driver',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.h),

              // Animated delivery icon
              Center(
                child: AnimatedBuilder(
                  animation:
                      Listenable.merge([_pulseAnimation, _rotationAnimation]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value * 2 * 3.14159,
                        child: Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.local_shipping,
                            size: 60.sp,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 32.h),

              // Status text
              Obx(() {
                final controller = Get.find<DriverAcceptanceController>();
                return Column(
                  children: [
                    TextWidget(
                      text: controller.statusMessage.value,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    TextWidget(
                      text: controller.subStatusMessage.value,
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }),

              SizedBox(height: 40.h),

              // Delivery details card
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
                      text: 'Delivery Details',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    SizedBox(height: 16.h),

                    // Tracking number
                    Row(
                      children: [
                        Icon(Icons.qr_code,
                            size: 16.sp, color: Colors.grey[600]),
                        SizedBox(width: 8.w),
                        TextWidget(
                          text: 'Tracking: ${widget.trackingNumber}',
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Amount
                    Row(
                      children: [
                        Icon(Icons.attach_money,
                            size: 16.sp, color: Colors.grey[600]),
                        SizedBox(width: 8.w),
                        TextWidget(
                          text: 'Amount: \$${widget.amount.toStringAsFixed(2)}',
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // From location
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 16.sp, color: AppColors.primaryColor),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: TextWidget(
                            text: 'From: ${widget.fromLocation}',
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // To location
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16.sp, color: Colors.red),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: TextWidget(
                            text: 'To: ${widget.toLocation}',
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Progress indicator
              Obx(() {
                final controller = Get.find<DriverAcceptanceController>();
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: controller.progressValue.value,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    ),
                    SizedBox(height: 8.h),
                    TextWidget(
                      text: 'Searching for available drivers...',
                      fontSize: 12.sp,
                      color: Colors.grey[500],
                    ),
                  ],
                );
              }),

              Spacer(),

              // Cancel button
              Obx(() {
                final controller = Get.find<DriverAcceptanceController>();
                return SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: controller.canCancel.value
                        ? () {
                            _showCancelDialog();
                          }
                        : null,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: TextWidget(
                      text: 'Cancel Delivery',
                      fontSize: 16.sp,
                      color:
                          controller.canCancel.value ? Colors.red : Colors.grey,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelDialog() {
    Get.dialog(
      AlertDialog(
        title: TextWidget(
          text: 'Cancel Delivery',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        content: TextWidget(
          text:
              'Are you sure you want to cancel this delivery? You will be refunded the full amount.',
          fontSize: 14.sp,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: TextWidget(
              text: 'Keep Waiting',
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              _cancelDelivery();
            },
            child: TextWidget(
              text: 'Cancel Delivery',
              fontSize: 14.sp,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  void _cancelDelivery() {
    final controller = Get.find<DriverAcceptanceController>();
    controller.cancelDelivery(widget.deliveryId);
  }
}
