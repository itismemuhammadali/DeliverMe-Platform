import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/user/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:deliver_mee/src/feature/user/bottom_bar/pages/bottom_bar_page.dart';
import 'package:deliver_mee/src/feature/user/schedule/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  void _goToScheduledDeliveries() {
    // Ensure bottom bar controller exists before we set the tab.
    if (!Get.isRegistered<BottomBarController>()) {
      Get.put(BottomBarController(), permanent: true);
    }
    BottomBarController.to.setSelectedIndex(2); // Scheduled tab

    // Refresh schedule controller so updated payment status is fetched
    if (Get.isRegistered<CustomerScheduleController>()) {
      Get.find<CustomerScheduleController>().refreshDeliveries();
    }

    Get.offAll(() => UserBottomBarPage(), transition: Transition.cupertino);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 86.w,
                height: 86.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.primaryColor,
                  size: 56.sp,
                ),
              ),
              SizedBox(height: 18.h),
              TextWidget(
                text: 'Payment Confirmed',
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              TextWidget(
                text:
                    'Thank you for choosing DeliverMee. Your delivery is scheduled successfully. You can track your delivery in the Scheduled Deliveries section.',
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.center,
                color: Colors.grey[700],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToScheduledDeliveries,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: TextWidget(
                    text: 'Go to Scheduled Deliveries',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // Navigate to home instead of back since we used offAll
                    Get.offAll(() => UserBottomBarPage(), transition: Transition.cupertino);
                  },
                  child: TextWidget(
                    text: 'Back to Home',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


