import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/auth/sign_in/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PasswordChangeDonePage extends StatelessWidget {
  const PasswordChangeDonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(15.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.doneImage,
                height: 91.h,
              ),
              SizedBox(
                height: 20.h,
              ),
              TextWidget(
                text: 'Password Changed!',
                fontSize: 24.sp,
                color: AppColors.blackColor,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(
                height: 10.h,
              ),
              TextWidget(
                text:
                    'Password changed successfully, you can login again with a new password',
                color: AppColors.richTextColor,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30.h,
              ),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: Material(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                  child: InkWell(
                    onTap: () {
                      Get.offAll(SignInPage(), transition: Transition.cupertino);
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Center(
                      child: TextWidget(
                        text: 'Log In',
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
