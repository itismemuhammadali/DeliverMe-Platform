import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../common/constant/app_colors.dart';
import '../../../../common/constant/app_images.dart';
import '../../../../common/utils/text_widget.dart';
import '../../../auth/forgot_password/forgot_password_page.dart';
import '../controller/driver_auth_controller.dart';
import 'driver_unified_signup_screen.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late DriverAuthController _controller;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = DriverAuthController.to;
    // Create empty controllers - don't pre-fill with saved credentials (security risk)
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                text: 'Driver Login',
                fontSize: 32.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              SizedBox(height: 8.h),
              TextWidget(
                text: 'Sign in to your driver account',
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
              SizedBox(height: 32.h),
              // Email field
              TextWidget(
                text: 'Email',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              SizedBox(height: 8.h),
              Obx(() => TextFormField(
                    controller: _emailController,
                    onChanged: (value) =>
                        _controller.updateField('email', value),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.email_outlined,
                          color: Colors.grey[400], size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide:
                            BorderSide(color: AppColors.primaryColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.red[300]!),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.h, horizontal: 12.w),
                      errorText: _controller.email.value.isNotEmpty &&
                              !_controller.isEmailValid.value
                          ? 'Please enter a valid email'
                          : null,
                    ),
                  )),
              SizedBox(height: 20.h),
              // Password field
              TextWidget(
                text: 'Password',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              SizedBox(height: 8.h),
              Obx(() => TextFormField(
                    controller: _passwordController,
                    onChanged: (value) =>
                        _controller.updateField('password', value),
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.lock_outline,
                          color: Colors.grey[400], size: 20),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        child: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide:
                            BorderSide(color: AppColors.primaryColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: Colors.red[300]!),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 12.h, horizontal: 12.w),
                      errorText: _controller.password.value.isNotEmpty &&
                              !_controller.isPasswordValid.value
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                  )),
              SizedBox(height: 12.h),
              // Forgot password
              Align(
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
              ),
              SizedBox(height: 24.h),
              // Error message
              Obx(() {
                if (_controller.error.value.isNotEmpty) {
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
                            text: _controller.error.value,
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
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: Material(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8.r),
                      child: InkWell(
                        onTap: _controller.isLoading.value
                            ? null
                            : () {
                                if (_controller.isLoginFormValid &&
                                    !_controller.isLoading.value) {
                                  _controller.login().then((success) {
                                    if (success) {
                                      Get.offAllNamed('/driver/home');
                                    }
                                  });
                                }
                              },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Center(
                          child: TextWidget(
                            text: _controller.isLoading.value
                                ? 'Logging in...'
                                : 'Login',
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )),
              SizedBox(height: 20.h),
              // Sign up link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      text: "Don't have an account? ",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(
                          () => const DriverUnifiedSignupScreen(),
                          transition: Transition.cupertino,
                        );
                      },
                      child: TextWidget(
                        text: 'Register',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
