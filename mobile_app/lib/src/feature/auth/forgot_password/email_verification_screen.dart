import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/validator.dart';
import 'package:deliver_mee/src/common/utils/custom_text_form_field.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/auth/controller/auth_controller.dart';
import 'package:deliver_mee/src/feature/auth/forgot_password/new_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String userType;
  const EmailVerificationScreen({super.key, required this.userType});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController emailController = TextEditingController();
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
                  text: 'Verify Email',
                  fontSize: 24.sp,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 20.h),
                TextWidget(
                  text:
                      'Enter your email address to proceed with password reset',
                  fontSize: 16.sp,
                  color: AppColors.richTextColor,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 30.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextWidget(text: 'Email Address'),
                ),
                SizedBox(height: 10.h),
                CustomTextFormField(
                  controller: emailController,
                  validator: (val) => emailValidator(val),
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                ),
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
                                  // Store email and proceed to password screen
                                  AuthController.to.forgotEmail =
                                      emailController.text.trim();
                                  Get.to(
                                    NewPasswordPage(userType: widget.userType),
                                    transition: Transition.cupertino,
                                  );
                                }
                              },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Center(
                          child: TextWidget(
                            text: loading ? 'Verifying...' : 'Continue',
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
