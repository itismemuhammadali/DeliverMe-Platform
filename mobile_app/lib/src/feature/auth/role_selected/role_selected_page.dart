import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/auth/controller/auth_controller.dart';
import 'package:deliver_mee/src/feature/auth/sign_in/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RoleSelectedPage extends StatelessWidget {
  const RoleSelectedPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut(() => AuthController());
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Spacer at top
            SizedBox(height: 20.h),
            // Spacer
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and text
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: Column(
                      children: [
                        Image.asset(
                          AppImages.logo,
                          height: 60.h,
                        ),
                        SizedBox(height: 16.h),
                        Image.asset(
                          AppImages.logoText,
                          height: 40.h,
                        ),
                      ],
                    ),
                  ),
                  // Title
                  TextWidget(
                    text: 'Continue as',
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 32.sp,
                  ),
                  SizedBox(height: 12.h),
                  TextWidget(
                    text: 'Choose your role to get started',
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                  ),
                  SizedBox(height: 48.h),
                  // Role buttons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        // Driver Button
                        _buildRoleButton(
                          title: 'Driver',
                          subtitle: 'Earn money by delivering',
                          icon: Icons.local_shipping_outlined,
                          isPrimary: true,
                          onTap: () {
                            AuthController.to.setSelectedIndex(0);
                            Get.to(
                              () => SignInPage(),
                              transition: Transition.cupertino,
                            );
                          },
                        ),
                        SizedBox(height: 16.h),
                        // Customer Button
                        _buildRoleButton(
                          title: 'Customer',
                          subtitle: 'Get your items delivered',
                          icon: Icons.shopping_bag_outlined,
                          isPrimary: false,
                          onTap: () {
                            AuthController.to.setSelectedIndex(1);
                            Get.to(
                              () => SignInPage(),
                              transition: Transition.cupertino,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.primaryColor : Colors.grey[100],
            borderRadius: BorderRadius.circular(12.r),
            border: isPrimary
                ? null
                : Border.all(color: Colors.grey[300]!, width: 1),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 12.r,
                      spreadRadius: 2.r,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8.r,
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white.withValues(alpha: 0.2)
                      : AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? Colors.white : AppColors.primaryColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: title,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: isPrimary ? Colors.white : Colors.black,
                    ),
                    SizedBox(height: 4.h),
                    TextWidget(
                      text: subtitle,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: isPrimary
                          ? Colors.white.withValues(alpha: 0.8)
                          : Colors.grey[600],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isPrimary ? Colors.white : Colors.grey[400],
                size: 16.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
