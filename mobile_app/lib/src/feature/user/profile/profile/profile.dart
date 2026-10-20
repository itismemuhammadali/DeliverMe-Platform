import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/common/services/firebase_auth_service.dart';
import 'package:deliver_mee/src/common/services/customer_service.dart';
import 'package:deliver_mee/src/feature/auth/controller/auth_controller.dart';
import 'package:deliver_mee/src/feature/auth/role_selected/role_selected_page.dart';
import 'package:deliver_mee/src/feature/user/profile/customer_support/customer_support.dart';
import 'package:deliver_mee/src/feature/user/profile/edit_profile/edit_profile.dart';
import 'package:deliver_mee/src/feature/auth/change_password_screen.dart';
import 'package:deliver_mee/src/feature/onboarding_screen/term_of_service/term_of_service.dart';
import 'package:deliver_mee/src/feature/user/schedule/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<Map<String, String>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _loadUserData();
  }

  Future<Map<String, String>> _loadUserData() async {
    try {
      // Try to get from SharedPreferences first
      final prefs = await SharedPreferences.getInstance();
      final firstName = prefs.getString('first_name') ?? '';
      final lastName = prefs.getString('last_name') ?? '';

      if (firstName.isNotEmpty) {
        final fullName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;
        return <String, String>{
          'firstName': firstName,
          'lastName': lastName,
          'fullName': fullName,
          'initial': firstName[0].toUpperCase(),
        };
      }

      // Fallback to AuthController if available
      try {
        final authCtrl = Get.find<AuthController>();
        if (authCtrl.regFirstName.isNotEmpty) {
          final fullName = authCtrl.regLastName.isNotEmpty 
              ? '${authCtrl.regFirstName} ${authCtrl.regLastName}' 
              : authCtrl.regFirstName;
          return <String, String>{
            'firstName': authCtrl.regFirstName,
            'lastName': authCtrl.regLastName,
            'fullName': fullName,
            'initial': authCtrl.regFirstName[0].toUpperCase(),
          };
        }
      } catch (e) {
        print('Error getting user data from auth: $e');
      }
    } catch (e) {
      print('Error loading user data: $e');
    }

    // Fallback
    return <String, String>{
      'firstName': 'Customer',
      'lastName': '',
      'fullName': 'Customer',
      'initial': 'C',
    };
  }

  @override
  Widget build(BuildContext context) {
    // Initialize CustomerScheduleController if not already registered
    if (!Get.isRegistered<CustomerScheduleController>()) {
      Get.put(CustomerScheduleController());
    }
    final scheduleCtrl = Get.find<CustomerScheduleController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<Map<String, String>>(
          future: _userDataFuture,
          builder: (context, snapshot) {
            final userData = snapshot.data ?? {
              'firstName': 'Customer',
              'lastName': '',
              'fullName': 'Customer',
              'initial': 'C',
            };

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header with customer greeting
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: 'Profile',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greyTextColor,
                        ),
                      ],
                    ),
                  ),

                  // Profile Card
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 12.r,
                            spreadRadius: 2.r,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Profile Avatar
                          Container(
                            width: 70.w,
                            height: 70.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8.r,
                                ),
                              ],
                            ),
                            child: Center(
                              child: TextWidget(
                                text: userData['initial'] ?? 'C',
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          // Profile Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextWidget(
                                  text: '${userData['firstName']} ${userData['lastName']}',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 4.h),
                                Obx(() => TextWidget(
                                  text: '${scheduleCtrl.deliveries.length} Deliveries completed',
                                  fontSize: 12.sp,
                                  color: Colors.white.withValues(alpha: 0.8),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Stats Section
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Obx(() {
                      final totalDeliveries = scheduleCtrl.deliveries.length;
                      double totalSpent = 0.0;
                      for (var d in scheduleCtrl.deliveries) {
                        if (d.status.toLowerCase() == 'delivered' || d.status.toLowerCase() == 'completed') {
                          totalSpent += d.estimatedCost ?? 0.0;
                        }
                      }
                      
                      return Row(
                        children: [
                          _buildStatCard(totalDeliveries.toString(), 'Deliveries', Colors.blue),
                          SizedBox(width: 12.w),
                          _buildStatCard('\$${totalSpent.toStringAsFixed(0)}', 'Spent', Colors.green),
                        ],
                      );
                    }),
                  ),
                  SizedBox(height: 24.h),

                  // Menu Section Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextWidget(
                        text: 'Account',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyTextColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Menu Items
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        _buildMenuItemCard(
                          icon: AppIcons.profileFillIcon,
                          title: 'Edit Profile',
                          subtitle: 'Update your information',
                          onTap: () {
                            Get.to(EditProfileScreen(),
                                transition: Transition.cupertino);
                          },
                        ),
                        SizedBox(height: 12.h),
                        _buildMenuItemCard(
                          iconData: Icons.lock_outline,
                          title: 'Change Password',
                          subtitle: 'Update your password',
                          onTap: () {
                            Get.to(const ChangePasswordScreen(),
                                transition: Transition.cupertino);
                          },
                        ),
                        SizedBox(height: 12.h),
                        _buildMenuItemCard(
                          icon: AppIcons.messageIcon,
                          title: 'Customer Support',
                          subtitle: 'Get help and support',
                          onTap: () {
                            Get.to(CustomerSupportScreen(),
                                transition: Transition.cupertino);
                          },
                        ),
                        SizedBox(height: 12.h),
                        _buildMenuItemCard(
                          icon: AppIcons.logoutIcon,
                          title: 'Logout',
                          subtitle: 'Sign out from your account',
                          onTap: () async {
                            // Show confirmation dialog
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Logout'),
                                content: Text('Are you sure you want to logout?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text('Logout',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              // Clear all user data
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.clear();

                              // Sign out from Firebase
                              try {
                                if (Get.isRegistered<FirebaseAuthService>()) {
                                  await Get.find<FirebaseAuthService>().signOut();
                                }
                              } catch (e) {}

                              // Navigate to role selection
                              Get.offAll(RoleSelectedPage(),
                                  transition: Transition.cupertino);
                            }
                          },
                          isLogout: true,
                        ),
                        SizedBox(height: 12.h),
                        GestureDetector(
                          onTap: () async {
                            // Show confirmation dialog for delete account
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Account'),
                                content: Text('Are you sure you want to permanently delete your account? This action cannot be undone and will delete all your delivery history.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text('Delete Permanently',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              try {
                                // 1. Delete data from backend database first
                                final customerService = Get.find<CustomerService>();
                                final result = await customerService.deleteAccount();
                                
                                if (!result['success']) {
                                  Get.snackbar(
                                    'Error',
                                    result['error'] ?? 'Failed to delete data from server',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  // Continue anyway or return? Usually better to try to complete deletion
                                }

                                // 2. Delete from Firebase Auth
                                if (Get.isRegistered<FirebaseAuthService>()) {
                                  await Get.find<FirebaseAuthService>().deleteAccount();
                                }
                                
                                // 3. Clear local storage
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.clear();
                                
                                Get.snackbar(
                                  'Account Deleted',
                                  'Your account and all data have been permanently deleted.',
                                  backgroundColor: Colors.orange,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 3),
                                );
                                
                                // Wait for snackbar to be initialized before navigating
                                await Future.delayed(const Duration(milliseconds: 500));
                                
                                Get.offAll(RoleSelectedPage(), transition: Transition.cupertino);
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  'Failed to delete account. You might need to re-login to perform this action.',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextWidget(
                                        text: 'Delete Account',
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                      SizedBox(height: 2.h),
                                      TextWidget(
                                        text: 'Permanently delete your account',
                                        fontSize: 11.sp,
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Legal Section Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextWidget(
                        text: 'Legal',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyTextColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Legal Menu Items
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        _buildMenuItemCard(
                          iconData: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'View our privacy policy',
                          onTap: () {
                            Get.to(
                                () => TermofServiceScreen(isprivecy: true),
                                transition: Transition.cupertino);
                          },
                        ),
                        SizedBox(height: 12.h),
                        _buildMenuItemCard(
                          iconData: Icons.description_outlined,
                          title: 'Terms & Conditions',
                          subtitle: 'View our terms and conditions',
                          onTap: () {
                            Get.to(
                                () => TermofServiceScreen(isprivecy: false),
                                transition: Transition.cupertino);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            TextWidget(
              text: value,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            SizedBox(height: 4.h),
            TextWidget(
              text: label,
              fontSize: 10.sp,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemCard({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
    String? icon,
    IconData? iconData,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.withValues(alpha: 0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isLogout
                ? Colors.red.withValues(alpha: 0.2)
                : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isLogout
                    ? Colors.red.withValues(alpha: 0.1)
                    : AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: iconData != null
                  ? Icon(
                      iconData,
                      color: isLogout ? Colors.red : AppColors.primaryColor,
                      size: 20.sp,
                    )
                  : SvgPicture.asset(
                      icon!,
                      colorFilter: ColorFilter.mode(
                        isLogout ? Colors.red : AppColors.primaryColor,
                        BlendMode.srcIn,
                      ),
                      height: 20.h,
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: title,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isLogout ? Colors.red : AppColors.blackColor,
                  ),
                  SizedBox(height: 2.h),
                  TextWidget(
                    text: subtitle,
                    fontSize: 11.sp,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
