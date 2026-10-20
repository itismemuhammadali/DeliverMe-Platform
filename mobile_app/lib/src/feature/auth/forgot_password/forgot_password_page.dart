import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_container.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/auth/controller/auth_controller.dart';
import 'package:deliver_mee/src/feature/auth/forgot_password/forgot_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ForgotPasswordPage extends StatelessWidget {
  /// 'customer' or 'driver'
  final String userType;
  const ForgotPasswordPage({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(15.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextWidget(
                text: 'Forget password',
                fontSize: 24.sp,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 20.h),
              TextWidget(
                text:
                    'Select which contact details should we use to reset your password',
                fontSize: 16.sp,
                color: AppColors.richTextColor,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 30.h),
              Row(
                children: List.generate(2, (index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Obx(() {
                      return CustomContainer(
                        onTap: () {
                          AuthController.to.setSelectedForgotIndex(index);
                        },
                        color: Color(0xfffafafa),
                        height: 151.h,
                        width: 158.w,
                        borderColor:
                            AuthController.to.selectedForgotIndex.value == index
                                ? AppColors.primaryColor
                                : null,
                        borderWidth: 1,
                        borderRadius: 8.r,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CircleAvatar(
                                radius: 25.r,
                                backgroundColor: AppColors.whiteColor,
                                child: SvgPicture.asset(index == 0
                                    ? AppIcons.mailIcon
                                    : AppIcons.phoneIcon),
                              ),
                              TextWidget(
                                text: index == 0 ? 'Email' : 'Phone Number',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              TextWidget(
                                text: index == 0
                                    ? 'Send to your email'
                                    : 'Send to your Phone',
                                fontSize: 14.sp,
                                color: AppColors.richTextColor,
                              ),
                              SizedBox()
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                }),
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
                      Get.to(
                        ForgotEmailScreen(
                          index: AuthController.to.selectedForgotIndex.value,
                          userType: userType,
                        ),
                        transition: Transition.cupertino,
                      );
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Center(
                      child: TextWidget(
                        text: 'Continue',
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
