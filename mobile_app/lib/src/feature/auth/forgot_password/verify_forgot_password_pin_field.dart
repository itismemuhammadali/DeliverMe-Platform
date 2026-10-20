import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/auth/controller/auth_controller.dart';
import 'package:deliver_mee/src/feature/auth/forgot_password/email_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyForgotPasswordPinField extends StatefulWidget {
  final String text;
  final String controllerText;
  final String userType;

  const VerifyForgotPasswordPinField({
    super.key,
    required this.text,
    required this.controllerText,
    required this.userType,
  });

  @override
  State<VerifyForgotPasswordPinField> createState() =>
      _VerifyForgotPasswordPinFieldState();
}

class _VerifyForgotPasswordPinFieldState
    extends State<VerifyForgotPasswordPinField> {
  final TextEditingController otpController = TextEditingController();

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
              TextWidget(
                text: 'Verification Code',
                fontSize: 24.sp,
                color: AppColors.naveBlue,
                fontWeight: FontWeight.w600,
              ),
              TextWidget(
                textAlign: TextAlign.center,
                text:
                    'Please enter the code we just sent to ${widget.text}',
                fontSize: 14.sp,
                color: AppColors.richTextColor,
                fontWeight: FontWeight.w400,
              ),
              TextWidget(
                textAlign: TextAlign.center,
                text: widget.controllerText,
                fontSize: 14.sp,
                color: AppColors.greyTextColor,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(height: 30.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8.r),
                    fieldHeight: 60.h,
                    fieldWidth: 45.w,
                    activeFillColor: AppColors.whiteColor,
                    inactiveColor: AppColors.richTextColor,
                    activeColor: AppColors.richTextColor,
                    selectedColor: AppColors.primaryColor,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              SizedBox(height: 15.h),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWidget(
                    text: 'If you didn\'t receive a code?',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.richTextColor,
                  ),
                  Obx(() {
                    final loading =
                        AuthController.to.isForgotLoading.value;
                    return InkWell(
                      onTap: loading
                          ? null
                          : () async {
                              otpController.clear();
                              bool ok;
                              if (AuthController.to.forgotIsPhone) {
                                ok = await AuthController.to.sendForgotOtpPhone(
                                  widget.controllerText,
                                  widget.userType,
                                );
                              } else {
                                ok = await AuthController.to.sendForgotOtp(
                                  widget.controllerText,
                                  widget.userType,
                                );
                              }
                              if (ok) {
                                Get.snackbar(
                                  'OTP Sent',
                                  'A new code has been sent to ${widget.controllerText}',
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: AppColors.primaryColor,
                                  colorText: AppColors.whiteColor,
                                );
                              }
                            },
                      child: TextWidget(
                        text: '  Resend',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(height: 40.h),
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
                              if (otpController.text.length == 6) {
                                final ok =
                                    await AuthController.to.verifyForgotOtp(
                                  otpController.text,
                                );
                                if (ok) {
                                  Get.to(
                                    EmailVerificationScreen(userType: widget.userType),
                                    transition: Transition.cupertino,
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content:
                                      Text('Please enter the 6-digit code'),
                                  backgroundColor: AppColors.redColor,
                                ));
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
    );
  }
}
