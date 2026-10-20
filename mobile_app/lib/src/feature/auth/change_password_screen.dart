import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/custom_app_bar.dart';
import 'package:deliver_mee/src/common/utils/custom_text_form_field.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/driver/profile/controller/password_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late PasswordController controller;
  
  TextEditingController currentPasswordCtrl = TextEditingController();
  TextEditingController newPasswordCtrl = TextEditingController();
  TextEditingController confirmPasswordCtrl = TextEditingController();
  
  final _formkey = GlobalKey<FormState>();
  bool isLoading = false;
  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    // Register controller if not already registered
    if (!Get.isRegistered<PasswordController>()) {
      Get.put(PasswordController());
    }
    controller = Get.find<PasswordController>();
  }

  @override
  void dispose() {
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    print('🔐 _changePassword method called');
    // Validate manually instead of using form
    if (currentPasswordCtrl.text.isEmpty) {
      print('❌ Current password is empty');
      Get.snackbar('Error', 'Current password is required', 
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        duration: const Duration(seconds: 3));
      return;
    }
    if (newPasswordCtrl.text.isEmpty) {
      print('❌ New password is empty');
      Get.snackbar('Error', 'New password is required', 
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        duration: const Duration(seconds: 3));
      return;
    }
    if (newPasswordCtrl.text.length < 6) {
      print('❌ New password too short');
      Get.snackbar('Error', 'Password must be at least 6 characters', 
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        duration: const Duration(seconds: 3));
      return;
    }
    if (confirmPasswordCtrl.text.isEmpty) {
      print('❌ Confirm password is empty');
      Get.snackbar('Error', 'Confirm password is required', 
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        duration: const Duration(seconds: 3));
      return;
    }

    // Check if new password and confirm password match
    if (newPasswordCtrl.text.trim() != confirmPasswordCtrl.text.trim()) {
      print('❌ Passwords do not match: "${newPasswordCtrl.text}" vs "${confirmPasswordCtrl.text}"');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Password Mismatch'),
          content: const Text('New password and confirm password do not match'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    print('✅ All validations passed, calling controller.changePassword()');
    setState(() {
      isLoading = true;
    });

    try {
      final result = await controller.changePassword(
        currentPassword: currentPasswordCtrl.text.trim(),
        newPassword: newPasswordCtrl.text.trim(),
      );

      print('📱 Controller returned: $result');
      setState(() {
        isLoading = false;
      });

      if (result) {
        print('✅ Password changed successfully');
        Get.snackbar(
          'Success',
          'Password changed successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        
        // Clear fields
        currentPasswordCtrl.clear();
        newPasswordCtrl.clear();
        confirmPasswordCtrl.clear();
        
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      } else {
        print('❌ Controller returned false');
        Get.snackbar(
          'Error',
          controller.error.value.isNotEmpty 
              ? controller.error.value 
              : 'Failed to change password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Exception: $e');
      setState(() {
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: "Change Password", leading: true),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formkey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                TextWidget(
                  text: 'Change Password',
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.naveBlue,
                ),
                SizedBox(height: 8.h),
                TextWidget(
                  text: 'Update your password to keep your account secure',
                  fontSize: 14.sp,
                  color: AppColors.greyColor,
                ),
                SizedBox(height: 32.h),
                
                // Current Password
                TextWidget(
                  text: 'Current Password *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                CustomTextFormField(
                  controller: currentPasswordCtrl,
                  obsecure: !showCurrentPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Current password is required';
                    }
                    return null;
                  },
                  hint: 'Enter current password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      showCurrentPassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.greyColor,
                    ),
                    onPressed: () {
                      setState(() {
                        showCurrentPassword = !showCurrentPassword;
                      });
                    },
                  ),
                ),
                SizedBox(height: 24.h),
                
                // New Password
                TextWidget(
                  text: 'New Password *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                CustomTextFormField(
                  controller: newPasswordCtrl,
                  obsecure: !showNewPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'New password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  hint: 'Enter new password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      showNewPassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.greyColor,
                    ),
                    onPressed: () {
                      setState(() {
                        showNewPassword = !showNewPassword;
                      });
                    },
                  ),
                ),
                SizedBox(height: 24.h),
                
                // Confirm Password
                TextWidget(
                  text: 'Confirm Password *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                CustomTextFormField(
                  controller: confirmPasswordCtrl,
                  obsecure: !showConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    return null;
                  },
                  hint: 'Confirm new password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.greyColor,
                    ),
                    onPressed: () {
                      setState(() {
                        showConfirmPassword = !showConfirmPassword;
                      });
                    },
                  ),
                ),
                SizedBox(height: 40.h),
                
                // Change Password Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: Material(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8.r),
                    child: InkWell(
                      onTap: () {
                        print('🔐 Change password button tapped');
                        _changePassword();
                      },
                      borderRadius: BorderRadius.circular(8.r),
                      child: Center(
                        child: isLoading
                            ? SizedBox(
                                width: 24.w,
                                height: 24.w,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.whiteColor,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : TextWidget(
                                text: 'Change Password',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.whiteColor,
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
