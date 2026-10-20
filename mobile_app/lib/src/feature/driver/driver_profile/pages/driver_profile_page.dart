import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_container.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/common/services/firebase_auth_service.dart';
import 'package:deliver_mee/src/common/services/driver_auth_service.dart';
import 'package:deliver_mee/src/feature/auth/role_selected/role_selected_page.dart';
import 'package:deliver_mee/src/feature/driver/driver_home/controller/controller.dart';
import 'package:deliver_mee/src/feature/driver/driver_pick_up/controller/driver_delivery_history_controller.dart';
import 'package:deliver_mee/src/feature/driver/driver_profile/pages/driver_customer_support.dart';
import 'package:deliver_mee/src/feature/driver/driver_profile/pages/driver_edit_profile.dart';
import 'package:deliver_mee/src/feature/auth/change_password_screen.dart';
import 'package:deliver_mee/src/feature/driver/driver_profile/pages/driver_documents_upload.dart';
import 'package:deliver_mee/src/feature/onboarding_screen/term_of_service/term_of_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverProfilePage extends StatefulWidget {
  const DriverProfilePage({super.key});

  @override
  State<DriverProfilePage> createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  @override
  Widget build(BuildContext context) {
    // Initialize DriverDeliveryHistoryController if not already registered
    if (!Get.isRegistered<DriverDeliveryHistoryController>()) {
      Get.put(DriverDeliveryHistoryController());
    }
    final historyCtrl = Get.find<DriverDeliveryHistoryController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with driver name, refresh, and notification
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() {
                      try {
                        final homeController = Get.find<DriverHomeController>();
                        final driverName = homeController.driverName.isNotEmpty
                            ? homeController.driverName
                            : 'Driver';
                        return TextWidget(
                          text: 'Hello, $driverName!',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.greyTextColor,
                        );
                      } catch (e) {
                        return TextWidget(
                          text: 'Hello, Driver!',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.greyTextColor,
                        );
                      }
                    }),
                    Row(
                      children: [
                        CustomContainer(
                          onTap: () => historyCtrl.refreshDeliveries(),
                          height: 35,
                          width: 35,
                          borderRadius: 100.r,
                          borderColor: AppColors.brownColor,
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: Icon(
                              Icons.refresh,
                              color: AppColors.primaryColor,
                              size: 20.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                      ],
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
                        child: Obx(() {
                          try {
                            final homeController = Get.find<DriverHomeController>();
                            final initial = homeController.driverName.isNotEmpty
                                ? homeController.driverName[0].toUpperCase()
                                : 'D';
                            return Center(
                              child: TextWidget(
                                text: initial,
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            );
                          } catch (e) {
                            return Center(
                              child: TextWidget(
                                text: 'D',
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            );
                          }
                        }),
                      ),
                      SizedBox(width: 16.w),
                      // Profile Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() {
                              try {
                                final homeController = Get.find<DriverHomeController>();
                                return TextWidget(
                                  text: homeController.driverName.isNotEmpty
                                      ? homeController.driverName
                                      : 'Driver',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                );
                              } catch (e) {
                                return TextWidget(
                                  text: 'Driver',
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                );
                              }
                            }),
                            SizedBox(height: 4.h),
                            Obx(() => TextWidget(
                              text: '${historyCtrl.getDeliveredCount()} Deliveries completed',
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
                  final deliveredCount = historyCtrl.getDeliveredCount();
                  final earnings = historyCtrl.calculateEarnings();
                  
                  return Row(
                    children: [
                      _buildStatCard(deliveredCount.toString(), 'Deliveries', Colors.blue),
                      SizedBox(width: 12.w),
                      _buildStatCard('\$${earnings.toStringAsFixed(0)}', 'Earnings', Colors.green),
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
                        Get.to(DriverEditProfile(),
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
                      iconData: Icons.document_scanner_outlined,
                      title: 'Manage Documents',
                      subtitle: 'Upload and manage your documents',
                      onTap: () {
                        Get.to(const DriverDocumentsUpload(),
                            transition: Transition.cupertino);
                      },
                    ),
                    SizedBox(height: 12.h),
                    _buildMenuItemCard(
                      icon: AppIcons.messageIcon,
                      title: 'Customer Support',
                      subtitle: 'Get help and support',
                      onTap: () {
                        Get.to(DriverCustomerSupport(),
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
                          final prefs = await SharedPreferences.getInstance();
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
                            content: Text('Are you sure you want to permanently delete your account? This action cannot be undone and will delete all your driver history.'),
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
                            if (Get.isRegistered<DriverAuthService>()) {
                              final result = await Get.find<DriverAuthService>().deleteAccount();
                              if (!result['success']) {
                                Get.snackbar(
                                  'Error',
                                  result['error'] ?? 'Failed to delete data from server',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                // Optional: Return or continue. Service method already tries to delete FB and clear prefs.
                              }
                            } else {
                              // Fallback if service not registered
                              if (Get.isRegistered<FirebaseAuthService>()) {
                                await Get.find<FirebaseAuthService>().deleteAccount();
                              }
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.clear();
                            }
                            
                            Get.snackbar(
                              'Account Deleted',
                              'Your driver account and all data have been permanently deleted.',
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
