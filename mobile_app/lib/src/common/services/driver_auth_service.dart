import 'dart:async';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/driver_model.dart';
import '../../feature/driver/auth/controller/driver_auth_controller.dart';
import 'driver_api_service.dart';
import 'driver_document_service.dart';
import 'firebase_auth_service.dart';

class DriverAuthService extends GetxService {
  static DriverAuthService get to => Get.find<DriverAuthService>();

  final Rx<DriverModel?> currentDriver = Rx<DriverModel?>(null);
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isRegistering = false.obs;

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      isLoading.value = true;
      if (!FirebaseAuthService.to.isSignedIn) return;
      final driver = await DriverApiService.getCurrentDriver();
      if (driver != null) {
        currentDriver.value = driver;
        isLoggedIn.value = true;
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  /// Firebase sign-up then backend profile creation.
  Future<DriverRegistrationResponse> register({
    required String email,
    required String password,
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String driverLicenseNumber,
    required String vehicleType,
    String? vehicleMake,
    String? vehicleModel,
    int? vehicleYear,
    String? vehiclePlateNumber,
    Map<String, XFile>? documents,
    bool isAvailable = true,
  }) async {
    try {
      isLoading.value = true;
      isRegistering.value = true;

      // 1. Create Firebase Auth account
      print('🔐 Creating Firebase Auth account...');
      await FirebaseAuthService.to.signUpWithEmail(email, password);
      print('✅ Firebase Auth account created');

      // 2. Create Firestore profile (email comes from Firebase token server-side)
      print('📝 Creating Firestore driver profile...');
      final response = await DriverApiService.register(
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName,
        driverLicenseNumber: driverLicenseNumber,
        vehicleType: vehicleType,
        vehicleMake: vehicleMake ?? 'Other',
        vehicleModel: vehicleModel ?? 'Unknown',
        vehicleYear: vehicleYear ?? DateTime.now().year,
        vehiclePlateNumber: vehiclePlateNumber ?? 'TBD',
        isAvailable: isAvailable,
      );
      print('✅ Firestore driver profile created');
      print('   Driver ID: ${response.driver.id}');
      print('   Driver Name: ${response.driver.firstName} ${response.driver.lastName}');

      // 3. Upload documents if provided
      if (documents != null &&
          documents.isNotEmpty &&
          response.driver.id != null) {
        try {
          print('📤 Uploading documents...');
          final uploadResults =
              await DriverDocumentService.uploadDocumentsAfterRegistration(
            driverId: response.driver.id!,
            files: documents,
          );
          print('✅ Documents uploaded');
          print('   Driver License: ${uploadResults['driver_license']}');
          print('   ID Card: ${uploadResults['id_card']}');
          
          // Mark documents as uploaded in controller
          try {
            final controller = Get.find<DriverAuthController>();
            if (uploadResults['driver_license'] != null) {
              controller.isDriverLicenseUploaded.value = true;
            }
            if (uploadResults['id_card'] != null) {
              controller.isInsuranceUploaded.value = true;
            }
          } catch (_) {
            // Controller might not be initialized yet
          }
          
          await DriverApiService.updateDocuments(
            drivingLicenseImage: uploadResults['driver_license'],
            idCardImage: uploadResults['id_card'],
          );
          print('✅ Document URLs updated in profile');
        } catch (e) {
          print('⚠️  Document upload failed (non-fatal): $e');
          // Non-fatal — registration succeeded even if upload fails
        }
      }

      currentDriver.value = response.driver;
      isLoggedIn.value = true;
      return response;
    } catch (e) {
      print('❌ Registration error: $e');
      print('❌ Error type: ${e.runtimeType}');
      rethrow;
    } finally {
      isLoading.value = false;
      isRegistering.value = false;
    }
  }

  /// Firebase sign-in then fetch profile from backend.
  Future<DriverModel> login(String email, String password) async {
    try {
      isLoading.value = true;

      await FirebaseAuthService.to.signInWithEmail(email, password);
      final driver = await DriverApiService.getProfile();

      currentDriver.value = driver;
      isLoggedIn.value = true;
      return driver;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await DriverApiService.logout(); // also calls FirebaseAuth.signOut()
      currentDriver.value = null;
      isLoggedIn.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    if (!isLoggedIn.value) return;
    try {
      isLoading.value = true;
      final driver = await DriverApiService.getProfile();
      currentDriver.value = driver;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkLoginStatus() async {
    if (isRegistering.value) return false;
    final signedIn = FirebaseAuthService.to.isSignedIn;
    if (!signedIn) {
      isLoggedIn.value = false;
      return false;
    }
    
    if (currentDriver.value == null) {
      await _restoreSession();
    }
    
    // Only logged in if we have a driver profile
    isLoggedIn.value = currentDriver.value != null;
    return isLoggedIn.value;
  }

  Future<void> clearDriverData() async {
    await DriverApiService.logout();
    currentDriver.value = null;
    isLoggedIn.value = false;
  }

  Future<void> updateProfile(DriverModel driver) async {
    try {
      isLoading.value = true;
      await DriverApiService.updateProfile(
        firstName: driver.firstName,
        lastName: driver.lastName,
        phoneNumber: driver.phoneNumber,
      );
      currentDriver.value = driver;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete driver account and all associated data.
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      isLoading.value = true;
      
      // 1. Delete data from backend database first
      final result = await DriverApiService.deleteAccount();
      
      if (!result['success']) {
        return result;
      }

      // 2. Delete from Firebase Auth
      await FirebaseAuthService.to.deleteAccount();
      
      // 3. Clear local storage and state
      await DriverApiService.logout(); // Clears prefs and Firebase signOut (though deleteAccount already signs out)
      currentDriver.value = null;
      isLoggedIn.value = false;
      
      return {'success': true, 'message': 'Driver account and data deleted successfully'};
    } catch (e) {
      print('❌ Driver delete account error: $e');
      return {
        'success': false,
        'error': 'An error occurred during account deletion: ${e.toString()}',
      };
    } finally {
      isLoading.value = false;
    }
  }

  DriverModel? get driver => currentDriver.value;
  int? get driverId => currentDriver.value?.id;
  bool get isDriverAvailable => currentDriver.value?.isAvailable ?? false;
  bool get hasPaymentMethod => currentDriver.value?.hasPaymentMethod ?? false;
  String get driverStatus => currentDriver.value?.status ?? 'offline';
  String get driverName {
    final d = currentDriver.value;
    if (d == null) return '';
    return '${d.firstName} ${d.lastName}';
  }

  String get driverEmail => currentDriver.value?.email ?? '';
  String get driverPhone => currentDriver.value?.phoneNumber ?? '';
  String get vehicleInfo {
    final d = currentDriver.value;
    if (d == null) return '';
    return '${d.vehicleYear} ${d.vehicleModel} ${d.vehicleColor}';
  }

  String get licenseNumber => currentDriver.value?.licenseNumber ?? '';
  double? get rating => currentDriver.value?.rating;
  int? get totalRides => currentDriver.value?.totalRides;
  bool get isActive => currentDriver.value?.isActive ?? false;
  bool get notificationEnabled =>
      currentDriver.value?.notificationEnabled ?? true;

  Map<String, double?> get currentLocation {
    final driver = currentDriver.value;
    return {
      'latitude': driver?.currentLatitude,
      'longitude': driver?.currentLongitude,
    };
  }
}
