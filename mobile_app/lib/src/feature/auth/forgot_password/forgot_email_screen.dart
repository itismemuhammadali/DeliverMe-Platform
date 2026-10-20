import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/validator.dart';
import 'package:deliver_mee/src/common/utils/custom_text_form_field.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/auth/controller/auth_controller.dart';
import 'package:deliver_mee/src/feature/auth/forgot_password/verify_forgot_password_pin_field.dart';
import 'package:deliver_mee/src/feature/auth/forgot_password/email_sent_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ForgotEmailScreen extends StatefulWidget {
  final int index;
  final String userType;

  const ForgotEmailScreen(
      {super.key, required this.index, required this.userType});

  @override
  State<ForgotEmailScreen> createState() => _ForgotEmailScreenState();
}

class _ForgotEmailScreenState extends State<ForgotEmailScreen> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(15.h),
          child: Form(
            key: _formKey,
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextWidget(
                      text: widget.index == 0 ? 'Email' : 'Phone Number'),
                ),
                SizedBox(height: 10.h),
                CustomTextFormField(
                  controller: controller,
                  validator: (val) => widget.index == 0
                      ? emailValidator(val)
                      : validatePhoneNumber(val!),
                  hint: widget.index == 0
                      ? 'Enter Email'
                      : 'Enter Phone Number',
                  keyboardType: widget.index == 0
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
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
                                  bool ok;
                                  if (widget.index == 0) {
                                    // Email password reset
                                    ok = await AuthController.to.sendForgotOtp(
                                      controller.text.trim(),
                                      widget.userType,
                                    );
                                    if (ok) {
                                      Get.to(
                                        EmailSentScreen(
                                          email: controller.text.trim(),
                                        ),
                                        transition: Transition.cupertino,
                                      );
                                    }
                                  } else {
                                    // Phone OTP
                                    ok = await AuthController.to
                                        .sendForgotOtpPhone(
                                      controller.text.trim(),
                                      widget.userType,
                                    );
                                    if (ok) {
                                      Get.to(
                                        VerifyForgotPasswordPinField(
                                          text: 'phone',
                                          controllerText:
                                              controller.text.trim(),
                                          userType: widget.userType,
                                        ),
                                        transition: Transition.cupertino,
                                      );
                                    }
                                  }
                                }
                              },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Center(
                          child: TextWidget(
                            text: loading ? 'Sending...' : 'Send',
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
