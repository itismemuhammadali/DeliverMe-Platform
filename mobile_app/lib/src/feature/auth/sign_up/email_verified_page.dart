import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/custom_button.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/auth/controller/auth_controller.dart';
import 'package:deliver_mee/src/feature/user/bottom_bar/pages/bottom_bar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class EmailVerifiedPage extends StatefulWidget {
  final int index; // 0 for phone, 1 for email
  final String email;
  final String phoneNumber;
  final bool isLogin; // true if this is for login, false if for signup
  
  const EmailVerifiedPage({
    super.key,
    required this.index,
    required this.email,
    required this.phoneNumber,
    this.isLogin = false,
  });

  @override
  State<EmailVerifiedPage> createState() => _EmailVerifiedPageState();
}

class _EmailVerifiedPageState extends State<EmailVerifiedPage> {
  TextEditingController otpController = TextEditingController();

  void _handleVerify() async {
    try {
      if (otpController.text.length == 6) {
        bool success;
        
        if (widget.isLogin) {
          // Login OTP verification
          success = await AuthController.to.verifyLoginOtp(otpController.text);
          if (success) {
            Get.offAll(() => UserBottomBarPage(), transition: Transition.cupertino);
          }
        } else {
          // Signup OTP verification
          success = await AuthController.to.verifyRegistrationOtp(otpController.text);
          if (success) {
            Get.offAll(() => UserBottomBarPage(), transition: Transition.cupertino);
          }
        }
        
        if (!success) {
          // Show error message from controller
          Get.snackbar(
            'Verification Failed',
            AuthController.to.errorMessage.value.isNotEmpty
                ? AuthController.to.errorMessage.value
                : 'Failed to verify OTP. Please try again.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Invalid OTP',
          'Please enter a valid 6-digit OTP',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred during verification. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.blackColor),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(15.h),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWidget(
                  text: widget.index == 0
                      ? 'Verification Phone'
                      : 'Verification Email',
                  fontSize: 24.sp,
                  color: AppColors.naveBlue,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 10.h),
                TextWidget(
                  textAlign: TextAlign.center,
                  text: widget.index == 0
                      ? 'Please enter the code we just sent to Phone Number'
                      : 'Please enter the code we just sent to email',
                  fontSize: 14.sp,
                  color: AppColors.richTextColor,
                  fontWeight: FontWeight.w400,
                ),
                TextWidget(
                  textAlign: TextAlign.center,
                  text: widget.index == 0 ? widget.phoneNumber : widget.email,
                  fontSize: 14.sp,
                  color: AppColors.greyTextColor,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(
                  height: 30.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8.r),
                      fieldHeight: 50.h,
                      fieldWidth: 45.w,
                      activeFillColor: AppColors.whiteColor,
                      inactiveColor: AppColors.richTextColor.withValues(alpha: 0.3),
                      activeColor: AppColors.primaryColor,
                      selectedColor: AppColors.primaryColor,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      text: 'If you didn’t receive a code?',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.richTextColor,
                    ),
                    InkWell(
                      onTap: () async {
                        try {
                          if (widget.isLogin) {
                            // Resend login OTP
                            await AuthController.to.sendLoginOtp(widget.phoneNumber);
                          } else {
                            // Resend signup OTP
                            await AuthController.to.sendRegistrationOtp(
                              email: widget.email,
                              phoneNumber: widget.phoneNumber,
                              password: AuthController.to.regPassword,
                              firstName: AuthController.to.regFirstName,
                              lastName: AuthController.to.regLastName,
                            );
                          }
                          Get.snackbar(
                            'OTP Sent',
                            'We\'ve sent a new code to your ${widget.index == 0 ? 'phone' : 'email'}',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Failed to resend OTP. Please try again.',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: TextWidget(
                        text: '  Resend',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 40.h,
                ),
                Obx(() {
                  return AuthController.to.isLoading.value
                      ? CircularProgressIndicator(color: AppColors.primaryColor)
                      : CustomButton(
                          text: 'Continue',
                          ontap: _handleVerify,
                          borderRadius: 8.r,
                        );
                }),
                SizedBox(height: 20.h),
                Obx(() {
                  if (AuthController.to.errorMessage.value.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: TextWidget(
                        text: AuthController.to.errorMessage.value,
                        color: Colors.red,
                        fontSize: 14.sp,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return SizedBox.shrink();
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
