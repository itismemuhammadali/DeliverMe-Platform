import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/constant/validator.dart';
import 'package:deliver_mee/src/common/constant/country_codes.dart';
import 'package:deliver_mee/src/common/utils/custom_text_form_field.dart';
import 'package:deliver_mee/src/common/utils/rich_text.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/auth/controller/auth_controller.dart';
import 'package:deliver_mee/src/feature/auth/forgot_password/forgot_password_page.dart';
import 'package:deliver_mee/src/feature/auth/sign_up/sign_up_page.dart';
import 'package:deliver_mee/src/feature/auth/sign_up/email_verified_page.dart';
import 'package:deliver_mee/src/feature/driver/auth/pages/driver_unified_signup_screen.dart';
import 'package:deliver_mee/src/feature/driver/auth/controller/driver_auth_controller.dart';
import 'package:deliver_mee/src/feature/driver/driver_bottom_bar/pages/driver_bottom_bar_screen.dart';
import 'package:deliver_mee/src/feature/onboarding_screen/turn_on_location/turn_on_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // Phone login controllers
  final TextEditingController phoneNumberCtrl = TextEditingController();
  final selectedCountryCode = Rx<CountryCode>(getDefaultCountryCode());
  final loginPhoneMethod = 0.obs; // 0 for phone, 1 for email

  late TextEditingController _driverEmailController;
  late TextEditingController _driverPasswordController;

  @override
  void initState() {
    super.initState();
    try {
      _driverEmailController =
          TextEditingController(text: DriverAuthController.to.email.value);
      _driverPasswordController =
          TextEditingController(text: DriverAuthController.to.password.value);
    } catch (e) {
      print('⚠️ DriverAuthController not available: $e');
      _driverEmailController = TextEditingController();
      _driverPasswordController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _driverEmailController.dispose();
    _driverPasswordController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneNumberCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    print('🔐 Login button tapped');
    
    if (AuthController.to.selectedIndex.value == 0) {
      // Driver login
      print('👨‍✈️ Driver login');
      if (_formkey.currentState!.validate()) {
        print('✅ Form validation passed');
        DriverAuthController.to.error.value = '';
        final success = await DriverAuthController.to.login();
        if (success) {
          Get.offAll(() => DriverBottomBarScreen());
        }
      }
    } else {
      // Customer login - can be email or phone
      print('👤 Customer login');
      
      if (loginPhoneMethod.value == 1) {
        // Email login
        print('📧 Email login');
        if (_formkey.currentState!.validate()) {
          AuthController.to.clearError();
          final success = await AuthController.to.login(
            emailController.text.trim(),
            passwordController.text.trim(),
          );
          print('📊 Login result: $success');
          if (success) {
            print('✅ Login successful - navigating to home');
            Get.offAll(TurnOnLocation(), transition: Transition.cupertino);
          } else {
            print('❌ Login failed');
          }
        }
      } else {
        // Phone OTP login
        print('📱 Phone OTP login');
        if (phoneNumberCtrl.text.isEmpty) {
          AuthController.to.errorMessage.value = 'Please enter your phone number';
          return;
        }
        
        AuthController.to.clearError();
        
        // Combine country code with phone number
        final rawPhone = phoneNumberCtrl.text.trim().replaceAll(RegExp(r'[^\d]'), '');
        final fullPhoneNumber = '${selectedCountryCode.value.dialCode}$rawPhone';
        
        // Set OTP method to phone (0 = phone, 1 = email)
        AuthController.to.setOtpMethod(0);
        
        // Send login OTP
        final success = await AuthController.to.sendLoginOtp(fullPhoneNumber);
        if (success) {
          print('✅ OTP sent - navigating to verification');
          Get.to(
            () => EmailVerifiedPage(
              index: 0, // Phone verification
              email: '',
              phoneNumber: fullPhoneNumber,
            ),
            transition: Transition.cupertino,
          );
        } else {
          print('❌ Failed to send OTP');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  SizedBox(height: 20.h),
                  // Logo
                  Center(
                    child: Image.asset(
                      AppImages.logo,
                      height: 80.h,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  // Title
                  TextWidget(
                    text: 'Sign In',
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  SizedBox(height: 8.h),
                  TextWidget(
                    text: 'Welcome back to DeliverMee',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                  SizedBox(height: 32.h),
                  // Email/Phone tabs for Customer login
                  Obx(() {
                    if (AuthController.to.selectedIndex.value == 1) {
                      // Customer tab - show Email/Phone toggle
                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            padding: EdgeInsets.all(4.w),
                            child: Row(
                              children: [
                                // Email tab
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => loginPhoneMethod.value = 1,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 10.h),
                                      decoration: BoxDecoration(
                                        color: loginPhoneMethod.value == 1
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Center(
                                        child: TextWidget(
                                          text: 'Email',
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: loginPhoneMethod.value == 1
                                              ? AppColors.primaryColor
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Phone tab
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => loginPhoneMethod.value = 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 10.h),
                                      decoration: BoxDecoration(
                                        color: loginPhoneMethod.value == 0
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Center(
                                        child: TextWidget(
                                          text: 'Phone',
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: loginPhoneMethod.value == 0
                                              ? AppColors.primaryColor
                                              : Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      );
                    }
                    return SizedBox.shrink();
                  }),
                  // Email/Phone input fields
                  Obx(() {
                    if (AuthController.to.selectedIndex.value == 0) {
                      // Driver login
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: 'Email or Phone Number',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          SizedBox(height: 8.h),
                          CustomTextFormField(
                            controller: _driverEmailController,
                            onChanged: (value) =>
                                DriverAuthController.to.updateField('email', value),
                            validator: (validator) => emailValidator(validator),
                            hint: 'Enter your email',
                          ),
                          SizedBox(height: 20.h),
                          TextWidget(
                            text: 'Password',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          SizedBox(height: 8.h),
                          CustomTextFormField(
                            controller: _driverPasswordController,
                            onChanged: (value) => DriverAuthController.to
                                .updateField('password', value),
                            validator: (validator) => passwordValidator(validator),
                            hint: 'Enter your password',
                            obsecure: AuthController.to.isVisibility.value,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                AuthController.to.setVisibility();
                              },
                              child: Icon(
                                AuthController.to.isVisibility.value
                                    ? Icons.visibility_off
                                    : Icons.visibility_outlined,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Customer login
                      if (loginPhoneMethod.value == 1) {
                        // Email tab
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: 'Email',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            SizedBox(height: 8.h),
                            CustomTextFormField(
                              controller: emailController,
                              validator: (validator) {
                                if (validator == null || validator.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!validator.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              hint: 'Enter your email',
                            ),
                            SizedBox(height: 20.h),
                            TextWidget(
                              text: 'Password',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            SizedBox(height: 8.h),
                            CustomTextFormField(
                              controller: passwordController,
                              validator: (validator) => passwordValidator(validator),
                              hint: 'Enter your password',
                              obsecure: AuthController.to.isVisibility.value,
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  AuthController.to.setVisibility();
                                },
                                child: Icon(
                                  AuthController.to.isVisibility.value
                                      ? Icons.visibility_off
                                      : Icons.visibility_outlined,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Phone tab
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(
                              text: 'Phone Number',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                // Country code dropdown
                                Obx(() {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                                    child: DropdownButton<CountryCode>(
                                      value: selectedCountryCode.value,
                                      underline: SizedBox.shrink(),
                                      items: countryCodes
                                          .map((code) =>
                                          DropdownMenuItem<CountryCode>(
                                            value: code,
                                            child: TextWidget(
                                              text:
                                              '${code.flag} ${code.dialCode}',
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ))
                                          .toList(),
                                      onChanged: (CountryCode? newCode) {
                                        if (newCode != null) {
                                          selectedCountryCode.value = newCode;
                                        }
                                      },
                                    ),
                                  );
                                }),
                                SizedBox(width: 12.w),
                                // Phone number field
                                Expanded(
                                  child: CustomTextFormField(
                                    controller: phoneNumberCtrl,
                                    keyboardType: TextInputType.phone,
                                    validator: (validator) {
                                      if (validator == null || validator.isEmpty) {
                                        return 'Please enter phone number';
                                      }
                                      return null;
                                    },
                                    hint: 'Phone number',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    }
                  }),
                  SizedBox(height: 20.h),
                  // Forgot password - only for email login
                  Obx(() {
                    if (AuthController.to.selectedIndex.value == 1 &&
                        loginPhoneMethod.value == 1) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Get.to(
                              ForgotPasswordPage(userType: 'customer'),
                              transition: Transition.cupertino,
                            );
                          },
                          child: TextWidget(
                            text: 'Forgot Password?',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      );
                    } else if (AuthController.to.selectedIndex.value == 0) {
                      return Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Get.to(
                              ForgotPasswordPage(userType: 'driver'),
                              transition: Transition.cupertino,
                            );
                          },
                          child: TextWidget(
                            text: 'Forgot Password?',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                  SizedBox(height: 24.h),
                  // Error message
                  Obx(() {
                    String errorMessage = '';
                    if (AuthController.to.selectedIndex.value == 0) {
                      errorMessage = DriverAuthController.to.error.value;
                    } else {
                      errorMessage = AuthController.to.errorMessage.value;
                    }

                    if (errorMessage.isNotEmpty) {
                      return Container(
                        padding: EdgeInsets.all(12.w),
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red, size: 18.sp),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: TextWidget(
                                text: errorMessage,
                                fontSize: 13.sp,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                  // Login button
                  Obx(() {
                    bool isLoading = false;
                    if (AuthController.to.selectedIndex.value == 0) {
                      isLoading = DriverAuthController.to.isLoading.value;
                    } else {
                      isLoading = AuthController.to.isLoading.value;
                    }

                    return SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: Material(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(8.r),
                        child: InkWell(
                          onTap: isLoading ? null : _handleLogin,
                          borderRadius: BorderRadius.circular(8.r),
                          child: Center(
                            child: TextWidget(
                              text: isLoading ? 'Logging in...' : 'Login',
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 20.h),
                  // Sign up link
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (AuthController.to.selectedIndex.value == 0) {
                          Get.to(() => const DriverUnifiedSignupScreen(),
                              transition: Transition.cupertino);
                        } else {
                          Get.to(() => SignUpPage(),
                              transition: Transition.cupertino);
                        }
                      },
                      child: authRightText(
                          textOne: 'Don\'t have an account?',
                          textTwo: 'Sign Up'),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
