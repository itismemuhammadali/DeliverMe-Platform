import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/validator.dart';
import 'package:deliver_mee/src/common/utils/custom_text_form_field.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/auth/controller/auth_controller.dart';
import 'package:deliver_mee/src/feature/auth/forgot_password/password_change_done_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NewPasswordPage extends StatefulWidget {
  final String userType;
  const NewPasswordPage({super.key, required this.userType});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Padding(
        padding: EdgeInsets.all(15.h),
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWidget(
                  text: 'New Password ',
                  fontSize: 24.sp,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 20.h),
                TextWidget(
                  text:
                      'Create your new password, so you can login to your account.',
                  fontSize: 16.sp,
                  color: AppColors.richTextColor,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w500,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextWidget(text: 'Password'),
                ),
                SizedBox(height: 10.h),
                Obx(() {
                  return CustomTextFormField(
                    controller: passwordController,
                    validator: (val) => passwordValidator(val),
                    obsecure: AuthController.to.newPassword.value,
                    suffixIcon: GestureDetector(
                      onTap: () => AuthController.to.setNewPassword(),
                      child: Icon(
                        AuthController.to.newPassword.value
                            ? Icons.visibility_off
                            : Icons.visibility_outlined,
                        color: AppColors.greyTextColor.withValues(alpha: .7),
                      ),
                    ),
                    hint: 'Enter your password',
                  );
                }),
                SizedBox(height: 15.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextWidget(text: 'Confirm Password'),
                ),
                SizedBox(height: 10.h),
                Obx(() {
                  return CustomTextFormField(
                    controller: confirmPasswordController,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter your password';
                      } else if (val != passwordController.text) {
                        return 'Password does not match';
                      }
                      return null;
                    },
                    obsecure: AuthController.to.newConfirmPassword.value,
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          AuthController.to.setNewConfirmPassword(),
                      child: Icon(
                        AuthController.to.newConfirmPassword.value
                            ? Icons.visibility_off
                            : Icons.visibility_outlined,
                        color: AppColors.greyTextColor.withValues(alpha: .7),
                      ),
                    ),
                    hint: 'Enter your password',
                  );
                }),
                SizedBox(height: 10.h),
                // Error message
                Obx(() {
                  final err = AuthController.to.forgotError.value;
                  if (err.isEmpty) return SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Text(
                      err,
                      style: TextStyle(
                          color: AppColors.redColor, fontSize: 13.sp),
                      textAlign: TextAlign.center,
                    ),
                  );
                }),
                SizedBox(height: 30.h),
                Obx(() {
                  final loading = AuthController.to.isForgotLoading.value;
                  return SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: Material(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                      child: InkWell(
                        onTap: loading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  final ok = await AuthController.to
                                      .resetForgotPassword(
                                          passwordController.text.trim());
                                  if (ok) {
                                    Get.to(
                                      const PasswordChangeDonePage(),
                                      transition: Transition.cupertino,
                                    );
                                  }
                                }
                              },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Center(
                          child: TextWidget(
                            text: loading ? 'Saving...' : 'Continue',
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
