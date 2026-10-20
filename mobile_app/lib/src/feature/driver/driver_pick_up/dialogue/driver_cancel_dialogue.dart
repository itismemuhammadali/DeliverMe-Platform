import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/custom_text_form_field.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Widget driverCancleDialogue({
  required int deliveryId,
  required void Function(String reason) onReasonSubmit,
}) {
  final reasonController = TextEditingController();

  return Material(
    color: Colors.transparent,
    child: Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.all(24.w),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(Get.context!);
                    },
                    child: Icon(Icons.close, size: 24.sp),
                  ),
                ),
                SizedBox(height: 16.h),
                
                // Title
                TextWidget(
                  text: 'Are You Sure?',
                  color: AppColors.blackColor,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                
                // Description
                TextWidget(
                  text: 'Once you cancel this delivery, you won\'t be able to redo it.',
                  textAlign: TextAlign.center,
                  fontSize: 13.sp,
                  color: AppColors.greyTextColor,
                  fontWeight: FontWeight.w400,
                ),
                SizedBox(height: 20.h),
                
                // Reason label
                Row(
                  children: [
                    TextWidget(
                      text: 'Reason for Cancellation',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                    TextWidget(
                      text: ' *',
                      color: AppColors.redColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                
                // Reason input
                CustomTextFormField(
                  controller: reasonController,
                  validator: (validator) => null,
                  maxline: 5,
                  hint: 'Add comment here',
                ),
                SizedBox(height: 24.h),
                
                // Confirm button (like login button)
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: Material(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8.r),
                    child: InkWell(
                      onTap: () {
                        final reason = reasonController.text.trim();
                        if (reason.isEmpty) {
                          Get.snackbar(
                            'Required',
                            'Please provide a cancellation reason',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.orange,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        onReasonSubmit(reason);
                      },
                      borderRadius: BorderRadius.circular(8.r),
                      child: Center(
                        child: TextWidget(
                          text: 'Confirm',
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
