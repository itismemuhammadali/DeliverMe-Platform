import 'dart:async';

import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/feature/auth/controller/auth_controller.dart';
import 'package:deliver_mee/src/feature/driver/auth/controller/driver_auth_controller.dart';
import 'package:deliver_mee/src/common/services/driver_api_service.dart';
import 'package:deliver_mee/src/common/services/api_service.dart';
import 'package:deliver_mee/src/feature/onboarding_screen/controller.dart';
import 'package:deliver_mee/src/feature/onboarding_screen/pages/onboarding_screen.dart';
import 'package:deliver_mee/src/feature/driver/driver_bottom_bar/pages/driver_bottom_bar_screen.dart';
import 'package:deliver_mee/src/feature/onboarding_screen/turn_on_location/turn_on_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double _containerSize = 1.5;
  double _containerOpacity = 1.0;
  bool notificationinfo = false;
  AnimationController? _controller;
  Animation<double>? animation1;

  late final AnimationController _scaleController = AnimationController(
    duration: const Duration(seconds: 5),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<double> _scaleAnimation = CurvedAnimation(
    parent: _scaleController,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    animation1 = Tween<double>(begin: 40, end: 20).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.fastLinearToSlowEaseIn,
      ),
    )..addListener(() {
        setState(() {});
      });

    _controller!.forward();

    // Start the scale animation immediately
    _scaleController.forward();

    // Check for existing session and navigate accordingly
    _checkExistingSession();

    super.initState();
  }

  Future<void> _checkExistingSession() async {
    try {
      // Wait 4 seconds for splash animation
      await Future.delayed(const Duration(seconds: 4));

      if (!mounted) return;

      // Check if Firebase user is currently authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        print('🔄 Session found: ${currentUser.email ?? currentUser.phoneNumber}');
        
        // Check last saved role to prioritize check
        final prefs = await SharedPreferences.getInstance();
        final lastRole = prefs.getString('last_user_role');
        print('🔧 Last saved role: $lastRole');
        
        bool isDriver = false;
        
        // If we have a saved role, start with that assumption
        if (lastRole == 'driver') {
          // User was a driver last time - check driver first
          print('🔧 Last session was DRIVER - checking driver profile first...');
          try {
            final driver = await DriverApiService.getCurrentDriver();
            if (driver != null) {
              print('✅ User is a DRIVER - driver profile confirmed');
              isDriver = true;
            } else {
              print('ℹ️ No driver profile found - checking customer profile...');
              try {
                await ApiService.fetchProfile();
                print('✅ User is a CUSTOMER - profile fetched successfully');
                isDriver = false;
              } catch (e) {
                print('❌ Customer profile also failed: $e');
                isDriver = false;
              }
            }
          } catch (e) {
            print('ℹ️ Driver profile check failed: $e - Checking customer profile...');
            try {
              await ApiService.fetchProfile();
              print('✅ User is a CUSTOMER - profile fetched successfully');
              isDriver = false;
            } catch (e2) {
              print('❌ Customer profile also failed: $e2');
              isDriver = false;
            }
          }
        } else {
          // Default to customer (most users are customers) or no role saved yet
          print('🔧 Checking CUSTOMER profile first (default)...');
          try {
            await ApiService.fetchProfile();
            print('✅ User is a CUSTOMER - profile fetched successfully');
            isDriver = false;
          } catch (e) {
            print('ℹ️ Customer profile fetch failed: $e - Checking if user is a driver...');
            
            // If customer profile fails, try driver
            try {
              print('🔧 Attempting to fetch driver profile...');
              final driver = await DriverApiService.getCurrentDriver();
              if (driver != null) {
                print('✅ User is a DRIVER - driver profile found');
                isDriver = true;
              } else {
                print('❌ Neither customer nor driver profile found');
                isDriver = false;
              }
            } catch (driverError) {
              print('❌ Driver profile fetch also failed: $driverError - Defaulting to customer');
              isDriver = false;
            }
          }
        }

        if (isDriver) {
          // Restore driver session
          print('🔧 Restoring DRIVER session...');
          try {
            // Set the selectedIndex to driver (0)
            if (!Get.isRegistered<AuthController>()) {
              Get.put(AuthController());
            }
            AuthController.to.setSelectedIndex(0);
            print('🔧 Set selectedIndex to 0 (driver)');
            
            await DriverAuthController.to.restoreSession();
            if (mounted) {
              Get.offAll(() => DriverBottomBarScreen(), transition: Transition.cupertino);
            }
          } catch (e) {
            print('❌ Failed to restore driver session: $e');
            _navigateToLogin();
          }
        } else {
          // Restore customer session
          print('🔧 Restoring CUSTOMER session...');
          try {
            // Initialize AuthController if not already done
            if (!Get.isRegistered<AuthController>()) {
              Get.put(AuthController());
            }
            
            // Set the selectedIndex to customer (1) before restoring session
            AuthController.to.setSelectedIndex(1);
            print('🔧 Set selectedIndex to 1 (customer)');
            
            // Properly restore customer session in AuthController
            final sessionRestored = await AuthController.to.restoreSession();
            
            if (sessionRestored && mounted) {
              print('✅ Customer session restored - navigating to home');
              Get.offAll(() => TurnOnLocation(), transition: Transition.cupertino);
            } else if (mounted) {
              print('❌ Customer session restore returned false - showing login');
              _navigateToLogin();
            }
          } catch (e) {
            print('❌ Failed to restore customer session: $e');
            _navigateToLogin();
          }
        }
      } else {
        print('ℹ️ No active session found - showing onboarding');
        _navigateToLogin();
      }
    } catch (e) {
      print('❌ Error checking session: $e');
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (mounted) {
      Get.put(OnBoardingController());
      Get.offAll(const OnboardingScreen(), transition: Transition.fadeIn);
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
          child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 1),
          curve: Curves.fastLinearToSlowEaseIn,
          opacity: _containerOpacity,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 2000),
            curve: Curves.fastLinearToSlowEaseIn,
            height: ScreenUtil().screenWidth / _containerSize,
            width: ScreenUtil().screenWidth / _containerSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.contain,
                image: AssetImage(AppImages.splashlogo),
              ),
            ),
          ),
        ),
      )),
    );
  }
}
