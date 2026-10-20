import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/services/location_service.dart';
import 'package:deliver_mee/src/common/services/delivery_service.dart';
import 'package:deliver_mee/src/common/services/location_suggestion_service.dart';
import 'package:deliver_mee/src/common/services/pricing_service.dart';
import 'package:deliver_mee/src/common/services/payment_service.dart';
import 'package:deliver_mee/src/common/services/stripe_config_service.dart';
import 'package:deliver_mee/src/common/services/driver_auth_service.dart';
import 'package:deliver_mee/src/common/services/firebase_auth_service.dart';
import 'package:deliver_mee/src/common/services/driver_location_service.dart';
import 'package:deliver_mee/src/common/services/driver_notification_service.dart';
import 'package:deliver_mee/src/common/services/customer_delivery_tracking_service.dart';
import 'package:deliver_mee/src/common/services/customer_service.dart';
import 'package:deliver_mee/src/feature/auth/controller/auth_controller.dart';
import 'package:deliver_mee/src/feature/auth/upload_document/controller.dart';
import 'package:deliver_mee/src/feature/driver/driver_bottom_bar/controller/driver_bottom_bar_controller.dart';
import 'package:deliver_mee/src/feature/driver/driver_home/controller/controller.dart';
import 'package:deliver_mee/src/feature/driver/driver_pick_up/controller/driver_pick_up_controller.dart';
import 'package:deliver_mee/src/feature/driver/notification/controller/controller.dart';
import 'package:deliver_mee/src/feature/driver/auth/controller/driver_auth_controller.dart';
import 'package:deliver_mee/src/feature/driver/profile/controller/driver_profile_controller.dart';
import 'package:deliver_mee/src/feature/onboarding_screen/controller.dart';
import 'package:deliver_mee/src/feature/splash_screen.dart';
import 'package:deliver_mee/src/feature/user/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:deliver_mee/src/feature/user/car_selection/controller.dart';
import 'package:deliver_mee/src/feature/user/chat/controller.dart';
import 'package:deliver_mee/src/feature/user/confirm_delivery/controller.dart';
import 'package:deliver_mee/src/feature/user/deliveries/controller.dart';
import 'package:deliver_mee/src/feature/user/delivery/controller.dart';
import 'package:deliver_mee/src/feature/user/home/controller/controller.dart';
import 'package:deliver_mee/src/feature/user/notification/controller.dart';
import 'package:deliver_mee/src/feature/user/payment/controller.dart';
import 'package:deliver_mee/src/feature/user/driver_acceptance/controller.dart';
import 'package:deliver_mee/src/common/utils/rating_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase - handle duplicate app error gracefully
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully');
    } else {
      print('ℹ️ Firebase already initialized');
    }
  } catch (e) {
    // Firebase already initialized by Android - this is fine
    print('ℹ️ Firebase initialization handled: ${e.toString().contains('duplicate') ? 'Already initialized' : e}');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return SafeArea(child: child!);
          },
          onInit: () async {
            // Initialize services first
            print('🔧 Initializing services...');
            Get.put(FirebaseAuthService());
            Get.put(LocationService());
            Get.put(DeliveryService());
            Get.put(LocationSuggestionService());
            Get.put(PricingService());
            
            // Initialize and wait for StripeConfigService (must complete before PaymentService)
            final stripeConfigService = StripeConfigService();
            await stripeConfigService.initializeRemoteConfig();
            Get.put(stripeConfigService);
            print('✅ StripeConfigService initialized and ready');
            
            Get.put(PaymentService());
            Get.put(DriverAuthService());
            Get.put(DriverLocationService());
            Get.put(DriverNotificationService());
            Get.put(CustomerDeliveryTrackingService());
            Get.put(CustomerService());
            print('✅ All services registered successfully');

            // Then initialize controllers
            print('🔧 Initializing controllers...');
            Get.lazyPut(() => OnBoardingController());
            Get.put(AuthController());
            Get.put(BottomBarController());
            Get.put(DriverBottomBarController());
            Get.put(DeliveresController());
            Get.put(HomeController());
            Get.put(CarController());
            Get.put(ChatController());
            Get.put(UserNotificationController());
            Get.put(DriverNotificationController());
            Get.put(DriverHomeController());
            Get.put(DriverPickUpController());
            Get.put(DeliverController());
            Get.put(PaymentController());
            Get.put(PaymentMethodController());
            Get.put(ConfirmDeliveryController());
            Get.put(RatingController());
            Get.put(DriverAcceptanceController());
            Get.put(DriverAuthController());
            Get.put(DriverProfileController());
            print('✅ All controllers initialized successfully');
          },
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.whiteColor,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryColor,
            ),
            appBarTheme: const AppBarTheme(backgroundColor: AppColors.whiteColor),
            useMaterial3: true,
          ),
          home: SplashScreen(),
        );
      },
    );
  }
}
