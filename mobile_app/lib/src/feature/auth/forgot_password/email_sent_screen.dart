import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmailSentScreen extends StatelessWidget {
  final String email;

  const EmailSentScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Padding(
        padding: EdgeInsets.all(15.h),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 80.sp,
                color: AppColors.primaryColor,
              ),
              SizedBox(height: 30.h),
              TextWidget(
                text: 'Reset Email Sent',
                fontSize: 24.sp,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 20.h),
              TextWidget(
                textAlign: TextAlign.center,
                text:
                    'A password reset link has been sent to your email address.',
                fontSize: 16.sp,
                color: AppColors.richTextColor,
                fontWeight: FontWeight.w400,
              ),
              SizedBox(height: 10.h),
              TextWidget(
                textAlign: TextAlign.center,
                text: email,
                fontSize: 14.sp,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 20.h),
              TextWidget(
                textAlign: TextAlign.center,
                text:
                    'Please check your email and click the link to reset your password.',
                fontSize: 14.sp,
                color: AppColors.greyTextColor,
                fontWeight: FontWeight.w400,
              ),
              SizedBox(height: 50.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: Material(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Center(
                      child: TextWidget(
                        text: 'Back to Login',
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
    );
  }
}
