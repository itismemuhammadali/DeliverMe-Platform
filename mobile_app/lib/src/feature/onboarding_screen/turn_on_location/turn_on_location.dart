import 'dart:async';
import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/auth/controller/auth_controller.dart';
import 'package:deliver_mee/src/feature/driver/driver_bottom_bar/pages/driver_bottom_bar_screen.dart';
import 'package:deliver_mee/src/feature/user/bottom_bar/pages/bottom_bar_page.dart';
import 'package:deliver_mee/src/common/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class TurnOnLocation extends StatefulWidget {
  const TurnOnLocation({super.key});

  @override
  State<TurnOnLocation> createState() => _TurnOnLocationState();
}

class _TurnOnLocationState extends State<TurnOnLocation> {
  final LocationService _locationService = LocationService.to;
  bool _isRequestingPermission = false;

  @override
  void initState() {
    super.initState();
    // Check location permission on init and navigate directly if already granted
    _checkLocationAndNavigate();
  }

  /// Check if location permission is already granted, if so navigate directly to home
  Future<void> _checkLocationAndNavigate() async {
    try {
      // Check if location permission is already granted
      if (_locationService.isLocationPermissionGranted) {
        print('✅ Location permission already granted - navigating to home');
        // Small delay to ensure UI is ready
        await Future.delayed(Duration(milliseconds: 300));
        _navigateToNextScreen();
      }
      // If permission not granted, stay on this screen to request it
    } catch (e) {
      print('❌ Error checking location permission: $e');
    }
  }

  /// Request location permission and navigate to appropriate screen
  Future<void> _requestLocationPermission() async {
    setState(() {
      _isRequestingPermission = true;
    });

    try {
      // Request location permission with timeout
      final permissionGranted = await _locationService
          .requestLocationPermission()
          .timeout(Duration(seconds: 10));

      if (permissionGranted) {
        // Try to get current location to ensure everything works
        final location = await _locationService
            .getCurrentLocation()
            .timeout(Duration(seconds: 15));

        if (location != null) {
          // Location permission granted and location obtained successfully
          _navigateToNextScreen();
        } else {
          // Permission granted but couldn't get location
          _showLocationError(
              'Location permission granted but unable to get your current location. Please check your device settings.');
        }
      } else {
        // Permission denied
        _showLocationError(
            'Location permission is required for delivery services. Please enable it in your device settings.');
      }
    } on TimeoutException {
      _showLocationError(
          'Location request timed out. Please check your device settings and try again.');
    } catch (e) {
      print('❌ Error requesting location permission: $e');
      _showLocationError(
          'An error occurred while requesting location permission. Please try again.');
    } finally {
      setState(() {
        _isRequestingPermission = false;
      });
    }
  }

  /// Navigate to the appropriate screen based on user type
  void _navigateToNextScreen() {
    if (AuthController.to.selectedIndex.value == 1) {
      Get.offAll(() => UserBottomBarPage(), transition: Transition.cupertino);
    } else {
      Get.offAll(() => DriverBottomBarScreen(),
          transition: Transition.cupertino);
    }
  }

  /// Show location error and allow user to continue
  void _showLocationError(String message) {
    Get.dialog(
      AlertDialog(
        title: Text('Location Permission'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              _navigateToNextScreen(); // Continue anyway
            },
            child: Text('Continue Anyway'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              _requestLocationPermission(); // Try again
            },
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: ScreenUtil().screenHeight,
        width: ScreenUtil().screenWidth,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15.h),
            child: Center(
              child: Container(
                width: 327.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 170.h,
                    ),
                    SvgPicture.asset(
                      AppIcons.pinIcon,
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    TextWidget(
                      text: 'Turn On Location',
                      fontSize: 24.sp,
                      textAlign: TextAlign.center,
                      color: AppColors.naveBlue,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    TextWidget(
                      text:
                          'Enable notifications to share your location with us.',
                      fontSize: 16.sp,
                      color: AppColors.richTextColor,
                      textAlign: TextAlign.center,
                      fontWeight: FontWeight.w400,
                    ),
                    SizedBox(
                      height: 70.h,
                    ),
                    // Allow button - matching sign-in button style
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: Material(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(8.r),
                        child: InkWell(
                          onTap: _isRequestingPermission
                              ? null
                              : () => _requestLocationPermission(),
                          borderRadius: BorderRadius.circular(8.r),
                          child: Center(
                            child: TextWidget(
                              text: _isRequestingPermission
                                  ? 'Requesting...'
                                  : 'Allow',
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 12.h,
                    ),
                    // Skip for Now button - outline style with border
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8.r),
                        child: InkWell(
                          onTap: () {
                            _navigateToNextScreen();
                          },
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: AppColors.primaryColor,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: TextWidget(
                                text: 'Skip for Now',
                                color: AppColors.primaryColor,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
