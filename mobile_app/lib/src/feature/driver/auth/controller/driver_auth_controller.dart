import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../common/services/driver_auth_service.dart';
import '../../../../common/services/driver_api_service.dart';
import '../../../../models/driver_model.dart';
import '../../../../common/services/driver_document_service.dart';

class DriverAuthController extends GetxController {
  static DriverAuthController get to => Get.find<DriverAuthController>();

  final DriverAuthService _authService = DriverAuthService.to;

  // Authentication state
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isLoggedIn = false.obs;

  // Form fields
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString driverLicenseNumber = ''.obs;
  final RxString vehicleType = ''.obs;
  final RxString vehicleMake = ''.obs;
  final RxString vehicleModel = ''.obs;
  final RxInt vehicleYear = 0.obs;
  final RxString vehiclePlateNumber = ''.obs;
  final RxString vehicleColor = ''.obs;

  // Document uploads
  final RxMap<String, XFile> documents = <String, XFile>{}.obs;
  final RxString drivingLicenseImagePath = ''.obs;
  final RxString idCardImagePath = ''.obs;

  // Document selection states (file picked but not uploaded)
  final RxBool isDriverLicenseSelected = false.obs;
  final RxBool isInsuranceSelected = false.obs;

  // Validation flags
  final RxBool isEmailValid = false.obs;
  final RxBool isPasswordValid = false.obs;
  final RxBool isConfirmPasswordValid = false.obs;
  final RxBool isFirstNameValid = false.obs;
  final RxBool isLastNameValid = false.obs;
  final RxBool isPhoneValid = false.obs;
  final RxBool isLicenseValid = false.obs;
  final RxBool isVehicleTypeValid = false.obs;
  final RxBool isVehicleMakeValid = false.obs;
  final RxBool isVehicleModelValid = false.obs;
  final RxBool isVehicleYearValid = false.obs;
  final RxBool isVehiclePlateValid = false.obs;
  final RxBool isVehicleColorValid = false.obs;
  final RxBool isDriverLicenseUploaded = false.obs;
  final RxBool isInsuranceUploaded = false.obs;

  final List<String> vehicleTypes = ['PICKUP_TRUCK', 'CARGO_VAN'];

  final List<String> vehicleMakes = [
    'Toyota', 'Honda', 'Ford', 'Chevrolet', 'Nissan', 'BMW', 'Mercedes-Benz',
    'Audi', 'Volkswagen', 'Hyundai', 'Kia', 'Mazda', 'Subaru', 'Lexus',
    'Acura', 'Infiniti', 'Cadillac', 'Lincoln', 'Buick', 'Chrysler', 'Dodge',
    'Jeep', 'Ram', 'GMC', 'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final loggedIn = await _authService.checkLoginStatus();
      isLoggedIn.value = loggedIn;
    } catch (_) {}
  }

  /// Firebase sign-in + fetch profile from backend.
  Future<bool> login() async {
    try {
      isLoading.value = true;
      error.value = '';

      if (!_validateLoginForm()) return false;

      await _authService.login(email.value, password.value);
      isLoggedIn.value = true;
      
      // Mark session as driver
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_user_role', 'driver');
      print('💾 Session saved as driver');
      
      return true;
    } on FirebaseAuthException catch (e) {
      error.value = _firebaseMessage(e);
      return false;
    } catch (e) {
      error.value = 'Login failed: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Firebase sign-up + backend profile creation + optional document upload.
  Future<bool> register() async {
    try {
      isLoading.value = true;
      error.value = '';

      if (!_validateRegistrationForm()) {
        error.value = 'Please fill in all required fields';
        return false;
      }

      final Map<String, XFile> documentsMap = {};
      if (documents.containsKey('driver_license')) {
        documentsMap['driver_license'] = documents['driver_license']!;
      }
      if (documents.containsKey('id_card')) {
        documentsMap['id_card'] = documents['id_card']!;
      }

      print('📤 Calling DriverAuthService.register()...');
      print('   Email: $email');
      print('   First Name: $firstName');
      print('   Last Name: $lastName');
      print('   Phone: $phoneNumber');
      print('   Vehicle Type: $vehicleType');
      print('   Documents: ${documentsMap.keys.toList()}');

      await _authService.register(
        email: email.value,
        password: password.value,
        phoneNumber: phoneNumber.value,
        firstName: firstName.value,
        lastName: lastName.value,
        driverLicenseNumber: driverLicenseNumber.value,
        vehicleType: vehicleType.value,
        vehicleMake: vehicleMake.value.isNotEmpty ? vehicleMake.value : null,
        vehicleModel: vehicleModel.value.isNotEmpty ? vehicleModel.value : null,
        vehicleYear: vehicleYear.value > 0 ? vehicleYear.value : null,
        vehiclePlateNumber: vehiclePlateNumber.value.isNotEmpty
            ? vehiclePlateNumber.value
            : null,
        documents: documentsMap.isNotEmpty ? documentsMap : null,
      );

      print('✅ DriverAuthService.register() completed successfully');
      isLoggedIn.value = true;
      return true;
    } on FirebaseAuthException catch (e) {
      error.value = _firebaseMessage(e);
      print('❌ Firebase Auth Error: ${error.value}');
      return false;
    } catch (e) {
      error.value = 'Registration failed: ${e.toString()}';
      print('❌ Registration Error: ${error.value}');
      print('❌ Error Type: ${e.runtimeType}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Document helpers ──────────────────────────────────────────────────────

  Future<void> pickDocument(String docType) async {
    try {
      final XFile? image = await DriverDocumentService.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image == null) return;

      final fileSize = await DriverDocumentService.getFileSizeInMB(image.path);
      if (!DriverDocumentService.isValidFileSize(fileSize)) {
        error.value = 'File size must be less than 10MB';
        return;
      }
      if (!DriverDocumentService.isValidFileType(image.path)) {
        error.value = 'Only JPG, PNG, and PDF files are allowed';
        return;
      }

      documents[docType] = image;
      if (docType == 'driver_license') {
        drivingLicenseImagePath.value = image.path;
        isDriverLicenseSelected.value = true;
      } else if (docType == 'id_card') {
        idCardImagePath.value = image.path;
        isInsuranceSelected.value = true;
      }

      // Automatically upload the document after selection
      await _uploadDocumentAfterSelection(docType, image);
    } catch (e) {
      error.value = 'Failed to pick document: ${e.toString()}';
    }
  }

  /// Upload document immediately after selection (before registration)
  Future<void> _uploadDocumentAfterSelection(String docType, XFile file) async {
    try {
      print('📤 Starting automatic upload for $docType after selection...');
      
      // Check if user is already logged in (post-registration upload)
      final isLoggedIn = await DriverApiService.isLoggedIn();
      
      if (isLoggedIn) {
        // User is logged in - upload immediately
        print('✅ User is logged in, uploading document...');
        final currentDriver = await DriverApiService.getCurrentDriver();
        if (currentDriver?.id == null) {
          print('⚠️ Driver ID not available, skipping upload');
          return;
        }

        final fileName = path.basename(file.path);
        final contentType = DriverDocumentService.getContentTypeFromExtension(file.path);

        // Get upload URL
        final uploadResponse = await DriverApiService.getPublicDocumentUploadUrl(
          driverId: currentDriver!.id!,
          docType: docType,
          filename: fileName,
          contentType: contentType,
        );

        // Upload to GCS
        final uploadSuccess = await DriverDocumentService.uploadFileToGCS(
          uploadUrl: uploadResponse.uploadUrl,
          filePath: file.path,
          contentType: contentType,
        );

        if (!uploadSuccess) {
          throw Exception('Failed to upload file to GCS');
        }

        // Confirm upload with backend
        await DriverApiService.confirmDocumentUpload(
          driverId: currentDriver.id!,
          docType: docType,
          objectKey: uploadResponse.objectKey,
          filename: fileName,
        );

        // Update controller state
        if (docType == 'driver_license') {
          isDriverLicenseUploaded.value = true;
        } else if (docType == 'id_card') {
          isInsuranceUploaded.value = true;
        }

        print('✅ Document uploaded successfully: $docType');
      } else {
        // User not logged in yet (during registration) - upload will happen during registration
        print('ℹ️ User not logged in yet, document will be uploaded during registration');
      }
    } catch (e) {
      print('⚠️ Automatic document upload failed: $e');
      // Don't set error here - this is a background operation
      // User can still proceed with registration and upload later
    }
  }

  void removeDocument(String docType) {
    documents.remove(docType);
    if (docType == 'driver_license') {
      drivingLicenseImagePath.value = '';
      isDriverLicenseSelected.value = false;
      isDriverLicenseUploaded.value = false;
    } else if (docType == 'id_card') {
      idCardImagePath.value = '';
      isInsuranceSelected.value = false;
      isInsuranceUploaded.value = false;
    }
  }

  String getDocumentFileName(String docType) =>
      documents[docType]?.name ?? '';

  bool hasDocument(String docType) => documents.containsKey(docType);

  Future<void> uploadDocumentsManually() async {
    try {
      if (documents.isEmpty) return;
      final currentDriver = await DriverApiService.getCurrentDriver();
      if (currentDriver?.id == null) return;

      final results =
          await DriverDocumentService.uploadDocumentsAfterRegistration(
        driverId: currentDriver!.id!,
        files: documents,
      );
      await DriverApiService.updateDocuments(
        drivingLicenseImage: results['driver_license'],
        idCardImage: results['id_card'],
      );
    } catch (e) {
      error.value = 'Document upload failed: ${e.toString()}';
    }
  }

  Future<void> testUploadApiCalls() async {
    try {
      if (documents.isEmpty) return;
      final currentDriver = await DriverApiService.getCurrentDriver();
      if (currentDriver?.id == null) return;

      for (final entry in documents.entries) {
        try {
          final fileName = path.basename(entry.value.path);
          final contentType =
              DriverDocumentService.getContentTypeFromExtension(entry.value.path);
          await DriverApiService.getPublicDocumentUploadUrl(
            driverId: currentDriver!.id!,
            docType: entry.key,
            filename: fileName,
            contentType: contentType,
          );
        } catch (_) {}
      }
    } catch (_) {}
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      isLoading.value = true;
      error.value = '';
      await _authService.logout();
      isLoggedIn.value = false;
      _clearForm();
      
      // Clear session marker
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_user_role');
    } catch (e) {
      error.value = 'Logout failed: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Restore driver session from persistent storage
  /// Called on app launch to auto-login if user was previously logged in
  Future<bool> restoreSession() async {
    try {
      print('🔄 Attempting to restore driver session...');
      
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ No Firebase user found in session');
        return false;
      }

      print('✅ Firebase user found: ${currentUser.email}');

      // Try to fetch and cache the profile
      try {
        print('🔄 Fetching driver profile...');
        final driver = await DriverApiService.getCurrentDriver();
        if (driver == null) {
          print('⚠️ Driver profile not found');
          return false;
        }
        
        print('✅ Driver profile restored successfully');
        isLoggedIn.value = true;
        
        // Mark role as driver
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_user_role', 'driver');
        
        return true;
      } catch (e) {
        print('⚠️ Profile fetch failed: $e');
        // User is authenticated in Firebase but profile fetch failed
        // This might be a network issue
        return false;
      }
    } catch (e) {
      print('❌ Session restore failed: $e');
      return false;
    }
  }

  // ── Field updater ─────────────────────────────────────────────────────────

  void updateField(String field, dynamic value) {
    switch (field) {
      case 'email':
        email.value = value;
        isEmailValid.value = value.isNotEmpty && _isValidEmail(value);
      case 'password':
        password.value = value;
        isPasswordValid.value = value.isNotEmpty && value.length >= 6;
      case 'confirmPassword':
        confirmPassword.value = value;
        isConfirmPasswordValid.value =
            value.isNotEmpty && password.value == value;
      case 'firstName':
        firstName.value = value;
        isFirstNameValid.value = value.isNotEmpty;
      case 'lastName':
        lastName.value = value;
        isLastNameValid.value = value.isNotEmpty;
      case 'phoneNumber':
        phoneNumber.value = value;
        isPhoneValid.value = value.isNotEmpty && _isValidPhone(value);
      case 'licenseNumber':
      case 'driverLicenseNumber':
        driverLicenseNumber.value = value;
        isLicenseValid.value = value.isNotEmpty && value.length >= 5;
      case 'vehicleType':
        vehicleType.value = value;
        isVehicleTypeValid.value = value.isNotEmpty;
      case 'vehicleMake':
        vehicleMake.value = value;
        isVehicleMakeValid.value = value.isNotEmpty && value.length >= 2;
      case 'vehicleModel':
        vehicleModel.value = value;
        isVehicleModelValid.value = value.isNotEmpty && value.length >= 2;
      case 'vehicleYear':
        final yr = value is int ? value : int.tryParse(value.toString());
        vehicleYear.value = yr ?? 0;
        isVehicleYearValid.value = yr != null &&
            yr > 0 &&
            yr >= 1900 &&
            yr <= DateTime.now().year + 1;
      case 'vehiclePlateNumber':
        vehiclePlateNumber.value = value;
        isVehiclePlateValid.value = value.isNotEmpty && value.length >= 3;
      case 'vehicleColor':
        vehicleColor.value = value;
        isVehicleColorValid.value = value.isEmpty || value.length >= 2;
      case 'drivingLicenseImage':
        drivingLicenseImagePath.value = value;
      case 'idCardImage':
        idCardImagePath.value = value;
    }
  }

  void updateVehicleType(String value) => updateField('vehicleType', value);
  void updateVehicleMake(String value) => updateField('vehicleMake', value);
  void updateVehicleModel(String value) => updateField('vehicleModel', value);
  void updateVehicleYear(int value) => updateField('vehicleYear', value);
  void updateVehiclePlateNumber(String value) =>
      updateField('vehiclePlateNumber', value);
  void updateVehicleColor(String value) => updateField('vehicleColor', value);

  // ── Validation ────────────────────────────────────────────────────────────

  bool _validateLoginForm() {
    isEmailValid.value =
        email.value.isNotEmpty && _isValidEmail(email.value);
    isPasswordValid.value =
        password.value.isNotEmpty && password.value.length >= 6;
    return isEmailValid.value && isPasswordValid.value;
  }

  bool _validateRegistrationForm() {
    isEmailValid.value =
        email.value.isNotEmpty && _isValidEmail(email.value);
    isPasswordValid.value =
        password.value.isNotEmpty && password.value.length >= 6;
    isConfirmPasswordValid.value =
        confirmPassword.value.isNotEmpty &&
            password.value == confirmPassword.value;
    isFirstNameValid.value = firstName.value.isNotEmpty;
    isLastNameValid.value = lastName.value.isNotEmpty;
    isPhoneValid.value =
        phoneNumber.value.isNotEmpty && _isValidPhone(phoneNumber.value);
    isLicenseValid.value =
        driverLicenseNumber.value.isNotEmpty &&
            driverLicenseNumber.value.length >= 5;
    isVehicleTypeValid.value = vehicleType.value.isNotEmpty;
    isVehicleMakeValid.value =
        vehicleMake.value.isNotEmpty && vehicleMake.value.length >= 2;
    isVehicleModelValid.value =
        vehicleModel.value.isNotEmpty && vehicleModel.value.length >= 2;
    final yr = vehicleYear.value;
    isVehicleYearValid.value =
        yr > 0 && yr >= 1900 && yr <= DateTime.now().year + 1;
    isVehiclePlateValid.value =
        vehiclePlateNumber.value.isNotEmpty &&
            vehiclePlateNumber.value.length >= 3;
    isDriverLicenseUploaded.value = documents.containsKey('driver_license');
    isInsuranceUploaded.value = documents.containsKey('id_card');

    return isEmailValid.value &&
        isPasswordValid.value &&
        isConfirmPasswordValid.value &&
        isFirstNameValid.value &&
        isLastNameValid.value &&
        isPhoneValid.value &&
        isLicenseValid.value &&
        isVehicleTypeValid.value &&
        isVehicleMakeValid.value &&
        isVehicleModelValid.value &&
        isVehicleYearValid.value &&
        isVehiclePlateValid.value &&
        isDriverLicenseUploaded.value &&
        isInsuranceUploaded.value;
  }

  bool _isValidEmail(String v) =>
      RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(v);

  bool _isValidPhone(String v) =>
      RegExp(r'^\+?1?\d{9,15}$').hasMatch(v);

  void _clearForm() {
    email.value = '';
    password.value = '';
    confirmPassword.value = '';
    firstName.value = '';
    lastName.value = '';
    phoneNumber.value = '';
    driverLicenseNumber.value = '';
    vehicleType.value = '';
    vehicleMake.value = '';
    vehicleModel.value = '';
    vehicleYear.value = 0;
    vehiclePlateNumber.value = '';
    vehicleColor.value = '';
    documents.clear();
    drivingLicenseImagePath.value = '';
    idCardImagePath.value = '';
    isEmailValid.value = false;
    isPasswordValid.value = false;
    isConfirmPasswordValid.value = false;
    isFirstNameValid.value = false;
    isLastNameValid.value = false;
    isPhoneValid.value = false;
    isLicenseValid.value = false;
    isVehicleTypeValid.value = false;
    isVehicleMakeValid.value = false;
    isVehicleModelValid.value = false;
    isVehicleYearValid.value = false;
    isVehiclePlateValid.value = false;
    isVehicleColorValid.value = false;
  }

  // ── Computed getters ──────────────────────────────────────────────────────

  bool get isLoginFormValid => isEmailValid.value && isPasswordValid.value;
  bool get isRegistrationFormValid =>
      isEmailValid.value &&
      isPasswordValid.value &&
      isConfirmPasswordValid.value &&
      isFirstNameValid.value &&
      isLastNameValid.value &&
      isPhoneValid.value &&
      isLicenseValid.value;
  bool get isVehicleInfoFormValid =>
      isVehicleTypeValid.value &&
      isVehicleMakeValid.value &&
      isVehicleModelValid.value &&
      isVehicleYearValid.value &&
      isVehiclePlateValid.value;
  bool get isDocumentsFormValid =>
      isDriverLicenseUploaded.value && isInsuranceUploaded.value;

  DriverModel? get currentDriver => _authService.driver;
  String get driverName => _authService.driverName;
  String get driverEmail => _authService.driverEmail;
  String get driverPhone => _authService.driverPhone;
  String get vehicleInfo => _authService.vehicleInfo;
  double? get rating => _authService.rating;
  int? get totalRides => _authService.totalRides;
  bool get isDriverAvailable => _authService.isDriverAvailable;
  bool get hasPaymentMethod => _authService.hasPaymentMethod;
  String get driverStatus => _authService.driverStatus;
  bool get isActive => _authService.isActive;
  bool get notificationEnabled => _authService.notificationEnabled;

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _firebaseMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters).';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication error.';
    }
  }
}
