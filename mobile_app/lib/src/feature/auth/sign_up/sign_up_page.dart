import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/constant/validator.dart';
import 'package:deliver_mee/src/common/constant/country_codes.dart';
import 'package:deliver_mee/src/common/utils/custom_text_form_field.dart';
import 'package:deliver_mee/src/common/utils/rich_text.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/auth/controller/auth_controller.dart';
import 'package:deliver_mee/src/feature/auth/sign_in/sign_in_page.dart';
import 'package:deliver_mee/src/feature/auth/sign_up/email_verified_page.dart';
// Navigate to user bottom bar after successful signup
import 'package:deliver_mee/src/feature/user/bottom_bar/pages/bottom_bar_page.dart';
import 'package:deliver_mee/src/feature/onboarding_screen/term_of_service/term_of_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();
  final TextEditingController phoneNumberCtrl = TextEditingController();
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();

  // Country code selection
  final selectedCountryCode = ValueNotifier<CountryCode>(getDefaultCountryCode());

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordCtrl.dispose();
    phoneNumberCtrl.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    selectedCountryCode.dispose();
    super.dispose();
  }

  void _handleRegistration() async {
    try {
      if (_formkey.currentState == null || !_formkey.currentState!.validate()) {
        return;
      }
      if (!AuthController.to.hasMinLength ||
          !AuthController.to.hasNumber ||
          !AuthController.to.hasUppercase) {
        return;
      }
      AuthController.to.clearError();

      // Combine country code with phone number — strip any non-digit chars from input
      final rawPhone = phoneNumberCtrl.text.trim().replaceAll(RegExp(r'[^\d]'), '');
      final fullPhoneNumber = '${selectedCountryCode.value.dialCode}$rawPhone';

      if (AuthController.to.otpMethod.value == 0) {
        // Phone OTP flow
        final success = await AuthController.to.sendRegistrationOtp(
          email: emailController.text.trim(),
          phoneNumber: fullPhoneNumber,
          password: passwordController.text.trim(),
          firstName: firstNameCtrl.text.trim(),
          lastName: lastNameCtrl.text.trim(),
        );
        if (success && mounted) {
          Get.to(
            () => EmailVerifiedPage(
              index: AuthController.to.otpMethod.value,
              email: emailController.text.trim(),
              phoneNumber: fullPhoneNumber,
            ),
            transition: Transition.cupertino,
          );
        }
      } else {
        // Email registration flow - create account directly
        final success = await AuthController.to.sendRegistrationOtp(
          email: emailController.text.trim(),
          phoneNumber: fullPhoneNumber,
          password: passwordController.text.trim(),
          firstName: firstNameCtrl.text.trim(),
          lastName: lastNameCtrl.text.trim(),
        );
        if (success) {
          // For email, account is already created, just complete registration
          final registrationSuccess = await AuthController.to.verifyRegistrationOtp('');
          if (registrationSuccess && mounted) {
            Get.offAll(() => UserBottomBarPage(), transition: Transition.cupertino);
          }
        }
      }
    } catch (e) {
      print('❌ Error in _handleRegistration: $e');
      AuthController.to.errorMessage.value = 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.whiteColor,
      body: Padding(
        padding: EdgeInsets.all(15.h),
        child: Form(
          key: _formkey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 30.h,
                ),
                // Role indicator
                Obx(() {
                  final isDriver = AuthController.to.selectedIndex.value == 0;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isDriver ? Colors.blue[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isDriver ? Colors.blue[200]! : Colors.green[200]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDriver ? Icons.local_shipping_outlined : Icons.shopping_bag_outlined,
                          color: isDriver ? Colors.blue : Colors.green,
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        TextWidget(
                          text: isDriver ? 'Driver' : 'Customer',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isDriver ? Colors.blue : Colors.green,
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(
                  height: 20.h,
                ),
                Center(
                  child: Image.asset(
                    AppImages.logo,
                    height: 100.h,
                  ),
                ),
                SizedBox(
                  height: 50.h,
                ),
                TextWidget(
                  text: 'Sign Up',
                  fontSize: 28.sp,
                  color: AppColors.naveBlue,
                ),
                SizedBox(
                  height: 30.h,
                ),
                TextWidget(
                  text: 'Email *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomTextFormField(
                  controller: emailController,
                  validator: (validator) => emailValidator(
                    validator,
                  ),
                  hint: 'Email',
                ),
                SizedBox(
                  height: 10.h,
                ),
                TextWidget(
                  text: 'First Name *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomTextFormField(
                  controller: firstNameCtrl,
                  validator: (validator) {
                    if (validator == null || validator.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  hint: 'First Name',
                ),
                SizedBox(
                  height: 10.h,
                ),
                TextWidget(
                  text: 'Last Name *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(
                  height: 10.h,
                ),
                CustomTextFormField(
                  controller: lastNameCtrl,
                  validator: (validator) {
                    if (validator == null || validator.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                  hint: 'Last Name',
                ),
                SizedBox(
                  height: 10.h,
                ),
                TextWidget(
                  text: 'Phone Number *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  children: [
                    // Country Code Dropdown
                    ValueListenableBuilder<CountryCode>(
                      valueListenable: selectedCountryCode,
                      builder: (context, country, child) {
                        return SizedBox(
                          height: 50.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.greyColor.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(8.r),
                              color: AppColors.textfieldColor,
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: DropdownButton<CountryCode>(
                                value: country,
                                isDense: true,
                                underline: SizedBox(),
                                items: countryCodes.map((CountryCode cc) {
                                  return DropdownMenuItem<CountryCode>(
                                    value: cc,
                                    child: Text('${cc.flag} ${cc.dialCode}'),
                                  );
                                }).toList(),
                                onChanged: (CountryCode? newCountry) {
                                  if (newCountry != null) {
                                    selectedCountryCode.value = newCountry;
                                  }
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 10.w),
                    // Phone Number Input
                    Expanded(
                      child: CustomTextFormField(
                        controller: phoneNumberCtrl,
                        validator: (validator) => validatePhoneNumber(validator),
                        hint: 'Phone Number',
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                TextWidget(
                  text: 'Password *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Obx(() {
                  return CustomTextFormField(
                      onChanged: (value) =>
                          AuthController.to.password.value = value,
                      controller: passwordController,
                      validator: (validator) {
                        if (validator == null || validator.isEmpty) {
                          return 'Please enter your password';
                        } else if (validator != passwordController.text) {
                          return 'Password does not match';
                        } else {
                          return null;
                        }
                      },
                      hint: 'Your password',
                      obsecure: AuthController.to.passwordTwoVisibility.value,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          AuthController.to.setPasswordtVisibility();
                        },
                        child: Icon(
                          AuthController.to.passwordTwoVisibility.value
                              ? Icons.visibility_off
                              : Icons.visibility_outlined,
                          color: AppColors.greyTextColor.withValues(alpha: .7),
                        ),
                      ));
                }),
                SizedBox(
                  height: 15.h,
                ),
                Obx(() {
                  return AuthController.to.password.value.isEmpty
                      ? SizedBox()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildValidationItem("Minimum 8 characters",
                                AuthController.to.hasMinLength),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                              child: buildValidationItem(
                                  "Atleast 1 number (1-9)",
                                  AuthController.to.hasNumber),
                            ),
                            buildValidationItem(
                                "Atleast lowercase or uppercase letters",
                                AuthController.to.hasUppercase),
                          ],
                        );
                }),
                SizedBox(
                  height: 10.h,
                ),
                TextWidget(
                  text: 'Confirm Password *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Obx(() {
                  return CustomTextFormField(
                    controller: confirmPasswordCtrl,
                    validator: (validator) {
                      if (validator == null || validator.isEmpty) {
                        return 'Please enter your password';
                      } else if (validator != confirmPasswordCtrl.text) {
                        return 'Password does not match';
                      } else {
                        return null;
                      }
                    },
                    hint: 'Confirm password',
                    obsecure:
                        AuthController.to.confirmpasswordTwoVisibility.value,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        AuthController.to.setConfirmPasswordtVisibility();
                      },
                      child: Icon(
                        AuthController.to.confirmpasswordTwoVisibility.value
                            ? Icons.visibility_off
                            : Icons.visibility_outlined,
                        color: AppColors.greyTextColor.withValues(alpha: .7),
                      ),
                    ),
                  );
                }),
                SizedBox(
                  height: 10.h,
                ),
                TextWidget(
                  text: 'Send OTP',
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  children: List.generate(2, (index) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          AuthController.to.setOtpMethod(index);
                        },
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Obx(() {
                                return Container(
                                  height: 18,
                                  width: 18,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.whiteColor,
                                      border: Border.all(
                                          color: AppColors.primaryColor,
                                          width: 1)),
                                  child: Padding(
                                    padding: EdgeInsets.all(2.0),
                                    child: Container(
                                      height: 18,
                                      width: 18,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            AuthController.to.otpMethod.value ==
                                                    index
                                                ? AppColors.primaryColor
                                                : AppColors.whiteColor,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            TextWidget(
                              text: index == 0 ? 'Phone Number' : 'Email',
                            )
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(
                  height: 15.h,
                ),
                Obx(() {
                  if (AuthController.to.errorMessage.value.isNotEmpty) {
                    return Container(
                      padding: EdgeInsets.all(12.h),
                      margin: EdgeInsets.only(bottom: 15.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: TextWidget(
                        text: AuthController.to.errorMessage.value,
                        fontSize: 14.sp,
                        color: Colors.red,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return SizedBox.shrink();
                }),
                SizedBox(
                  height: 10.h,
                ),
                // Duplicate section removed
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.primaryColor,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextWidget(
                              text: 'Legal Agreement',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      TextWidget(
                        textAlign: TextAlign.center,
                        text:
                            'By creating an account, you agree to our comprehensive Terms and Conditions and Privacy Policy.',
                        fontSize: 12.sp,
                        color: Color(0xff607080),
                      ),
                      SizedBox(height: 12.h),
                      Column(
                        children: [
                          // Terms and Conditions Button
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () {
                                Get.to(
                                    () => TermofServiceScreen(isprivecy: false),
                                    transition: Transition.cupertino);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color:
                                        AppColors.primaryColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      color: AppColors.primaryColor,
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Flexible(
                                      child: TextWidget(
                                        text: 'View Terms & Conditions',
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryColor,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          // Privacy Policy Button
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () {
                                Get.to(
                                    () => TermofServiceScreen(isprivecy: true),
                                    transition: Transition.cupertino);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color:
                                        AppColors.primaryColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.privacy_tip_outlined,
                                      color: AppColors.primaryColor,
                                      size: 16.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Flexible(
                                      child: TextWidget(
                                        text: 'View Privacy Policy',
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryColor,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Obx(() {
                  return SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: Material(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                      child: InkWell(
                        onTap: AuthController.to.isLoading.value ? null : _handleRegistration,
                        borderRadius: BorderRadius.circular(8.r),
                        child: Center(
                          child: TextWidget(
                            text: AuthController.to.isLoading.value
                                ? 'Signing up...'
                                : 'Sign Up',
                            color: AppColors.whiteColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(
                  height: 30.h,
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Get.to(SignInPage(), transition: Transition.cupertino);
                    },
                    child: authRightText(
                        textOne: 'Already have an account?',
                        textTwo: 'Sign In'),
                  ),
                ),
                SizedBox(
                  height: 15.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildValidationItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(isValid ? Icons.check : Icons.close,
            color: isValid ? AppColors.primaryColor : Colors.red, size: 18.h),
        SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
              color: isValid ? AppColors.richTextColor : Colors.red,
              fontWeight: FontWeight.w500,
              fontSize: 14.sp),
        ),
      ],
    );
  }
}
