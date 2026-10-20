import 'package:get/get.dart';
import '../../../../common/services/driver_auth_service.dart';
import '../../../../common/services/driver_api_service.dart';
import '../../../../models/driver_model.dart';

class DriverProfileController extends GetxController {
  static DriverProfileController get to => Get.find<DriverProfileController>();

  // Services
  final DriverAuthService _authService = DriverAuthService.to;

  // Profile state
  final Rx<DriverModel?> currentDriver = Rx<DriverModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Form fields for editing
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString email = ''.obs;
  final RxString driverLicenseNumber = ''.obs;
  final RxString vehicleType = ''.obs;
  final RxString vehicleMake = ''.obs;
  final RxString vehicleModel = ''.obs;
  final RxInt vehicleYear = 0.obs;
  final RxString vehiclePlateNumber = ''.obs;
  final RxString drivingLicenseImage = ''.obs;
  final RxString idCardImage = ''.obs;

  // Form validation
  final RxBool isFirstNameValid = false.obs;
  final RxBool isLastNameValid = false.obs;
  final RxBool isPhoneValid = false.obs;
  final RxBool isEmailValid = false.obs;
  final RxBool isLicenseValid = false.obs;
  final RxBool isVehicleTypeValid = false.obs;
  final RxBool isVehicleMakeValid = false.obs;
  final RxBool isVehicleModelValid = false.obs;
  final RxBool isVehicleYearValid = false.obs;
  final RxBool isVehiclePlateValid = false.obs;

  // Vehicle type and make lists
  final List<String> vehicleTypes = [
    'car',
    'suv',
    'van',
    'truck',
    'motorcycle',
    'pickup_truck',
    'cargo_van',
  ];

  final List<String> vehicleMakes = [
    'Toyota',
    'Honda',
    'Ford',
    'Chevrolet',
    'Nissan',
    'BMW',
    'Mercedes-Benz',
    'Audi',
    'Volkswagen',
    'Hyundai',
    'Kia',
    'Mazda',
    'Subaru',
    'Lexus',
    'Acura',
    'Infiniti',
    'Cadillac',
    'Lincoln',
    'Buick',
    'Chrysler',
    'Dodge',
    'Jeep',
    'Ram',
    'GMC',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadDriverProfile();
  }

  /// Public method to load/reload profile from edit screen
  Future<void> loadProfile() async {
    await _loadDriverProfile();
  }

  /// Load driver profile
  Future<void> _loadDriverProfile() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Check if driver is logged in
      final isLoggedIn = await _authService.checkLoginStatus();
      if (!isLoggedIn) {
        error.value = 'Driver not logged in';
        return;
      }

      // Get current driver
      currentDriver.value = _authService.driver;
      if (currentDriver.value != null) {
        _populateFormFields();
      }

      print('✅ Driver profile loaded');
    } catch (e) {
      print('❌ Error loading driver profile: $e');
      error.value = 'Error loading profile: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Populate form fields with current driver data
  void _populateFormFields() {
    if (currentDriver.value == null) return;

    final driver = currentDriver.value!;
    firstName.value = driver.firstName;
    lastName.value = driver.lastName;
    phoneNumber.value = driver.phoneNumber;
    email.value = driver.email;
    driverLicenseNumber.value = driver.licenseNumber;
    vehicleType.value = driver.vehicleType ?? '';
    vehicleMake.value = driver.vehicleMake ?? '';
    vehicleModel.value = driver.vehicleModel;
    vehicleYear.value = int.tryParse(driver.vehicleYear) ?? 0;
    vehiclePlateNumber.value = driver.vehiclePlate;
    drivingLicenseImage.value = driver.drivingLicenseImage ?? '';
    idCardImage.value = driver.idCardImage ?? '';

    // Validate all fields
    _validateAllFields();
  }

  /// Validate all form fields
  void _validateAllFields() {
    isFirstNameValid.value = firstName.value.isNotEmpty;
    isLastNameValid.value = lastName.value.isNotEmpty;
    isPhoneValid.value =
        phoneNumber.value.isNotEmpty && _isValidPhone(phoneNumber.value);
    isEmailValid.value = email.value.isNotEmpty && _isValidEmail(email.value);
    isLicenseValid.value = driverLicenseNumber.value.isNotEmpty;
    isVehicleTypeValid.value = vehicleType.value.isNotEmpty;
    isVehicleMakeValid.value =
        vehicleMake.value.isEmpty || vehicleMake.value.length >= 2;
    isVehicleModelValid.value = vehicleModel.value.isNotEmpty;
    isVehicleYearValid.value = vehicleYear.value == 0 ||
        (vehicleYear.value >= 1900 &&
            vehicleYear.value <= DateTime.now().year + 1);
    isVehiclePlateValid.value = vehiclePlateNumber.value.isNotEmpty;
  }

  /// Update profile
  Future<bool> updateProfile() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Validate form
      if (!_isFormValid()) {
        error.value = 'Please fill in all required fields correctly';
        return false;
      }

      // Create updated driver model
      final updatedDriver = currentDriver.value!.copyWith(
        firstName: firstName.value,
        lastName: lastName.value,
        phoneNumber: phoneNumber.value,
        email: email.value,
        licenseNumber: driverLicenseNumber.value,
        vehicleType: vehicleType.value.isNotEmpty ? vehicleType.value : null,
        vehicleMake: vehicleMake.value.isNotEmpty ? vehicleMake.value : null,
        vehicleModel: vehicleModel.value,
        vehicleYear:
            vehicleYear.value > 0 ? vehicleYear.value.toString() : null,
        vehiclePlate: vehiclePlateNumber.value,
        drivingLicenseImage: drivingLicenseImage.value.isNotEmpty
            ? drivingLicenseImage.value
            : null,
        idCardImage: idCardImage.value.isNotEmpty ? idCardImage.value : null,
      );

      // Update profile in auth service
      await _authService.updateProfile(updatedDriver);

      // Update local state
      currentDriver.value = updatedDriver;

      print('✅ Driver profile updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating driver profile: $e');
      error.value = 'Error updating profile: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update documents
  Future<bool> updateDocuments({
    String? drivingLicenseImage,
    String? idCardImage,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      await DriverApiService.updateDocuments(
        drivingLicenseImage: drivingLicenseImage,
        idCardImage: idCardImage,
      );

      // Update local form fields
      if (drivingLicenseImage != null) {
        this.drivingLicenseImage.value = drivingLicenseImage;
      }
      if (idCardImage != null) {
        this.idCardImage.value = idCardImage;
      }

      // Refresh profile
      await _loadDriverProfile();

      print('✅ Driver documents updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating driver documents: $e');
      error.value = 'Error updating documents: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update availability
  Future<bool> updateAvailability(bool isAvailable) async {
    try {
      isLoading.value = true;
      error.value = '';

      await DriverApiService.updateAvailability(isAvailable: isAvailable);

      // Update local state
      if (currentDriver.value != null) {
        currentDriver.value = currentDriver.value!.copyWith(
          isAvailable: isAvailable,
          status: isAvailable ? 'available' : 'offline',
        );
        await _authService.updateProfile(currentDriver.value!);
      }

      print('✅ Driver availability updated to: $isAvailable');
      return true;
    } catch (e) {
      print('❌ Error updating driver availability: $e');
      error.value = 'Error updating availability: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update payment method status
  Future<bool> updatePaymentMethodStatus(bool hasPaymentMethod) async {
    try {
      isLoading.value = true;
      error.value = '';

      await DriverApiService.updatePaymentMethod(
          hasPaymentMethod: hasPaymentMethod);

      // Update local state
      if (currentDriver.value != null) {
        currentDriver.value = currentDriver.value!.copyWith(
          hasPaymentMethod: hasPaymentMethod,
        );
        await _authService.updateProfile(currentDriver.value!);
      }

      print('✅ Driver payment method status updated to: $hasPaymentMethod');
      return true;
    } catch (e) {
      print('❌ Error updating driver payment method status: $e');
      error.value = 'Error updating payment method status: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh profile from server
  Future<void> refreshProfile() async {
    try {
      isLoading.value = true;
      error.value = '';

      await _authService.refreshProfile();
      currentDriver.value = _authService.driver;

      if (currentDriver.value != null) {
        _populateFormFields();
      }

      print('✅ Driver profile refreshed from server');
    } catch (e) {
      print('❌ Error refreshing driver profile: $e');
      error.value = 'Error refreshing profile: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Update form field
  void updateField(String field, String value) {
    switch (field) {
      case 'firstName':
        firstName.value = value;
        isFirstNameValid.value = value.isNotEmpty;
        break;
      case 'lastName':
        lastName.value = value;
        isLastNameValid.value = value.isNotEmpty;
        break;
      case 'phoneNumber':
        phoneNumber.value = value;
        isPhoneValid.value = value.isNotEmpty && _isValidPhone(value);
        break;
      case 'email':
        email.value = value;
        isEmailValid.value = value.isNotEmpty && _isValidEmail(value);
        break;
      case 'licenseNumber':
        driverLicenseNumber.value = value;
        isLicenseValid.value = value.isNotEmpty;
        break;
      case 'vehicleType':
        vehicleType.value = value;
        isVehicleTypeValid.value = value.isNotEmpty;
        break;
      case 'vehicleMake':
        vehicleMake.value = value;
        isVehicleMakeValid.value = value.isEmpty || value.length >= 2;
        break;
      case 'vehicleModel':
        vehicleModel.value = value;
        isVehicleModelValid.value = value.isNotEmpty;
        break;
      case 'vehicleYear':
        final yearInt = int.tryParse(value);
        vehicleYear.value = yearInt ?? 0;
        isVehicleYearValid.value = yearInt == null ||
            yearInt == 0 ||
            (yearInt >= 1900 && yearInt <= DateTime.now().year + 1);
        break;
      case 'vehiclePlateNumber':
        vehiclePlateNumber.value = value;
        isVehiclePlateValid.value = value.isNotEmpty;
        break;
      case 'drivingLicenseImage':
        drivingLicenseImage.value = value;
        break;
      case 'idCardImage':
        idCardImage.value = value;
        break;
    }
  }

  /// Update vehicle year
  void updateVehicleYear(int year) {
    vehicleYear.value = year;
    isVehicleYearValid.value =
        year > 0 && year >= 1900 && year <= DateTime.now().year + 1;
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email);
  }

  /// Validate phone number format
  bool _isValidPhone(String phone) {
    return RegExp(r'^\+?1?\d{9,15}$').hasMatch(phone);
  }

  /// Check if form is valid
  bool _isFormValid() {
    return isFirstNameValid.value &&
        isLastNameValid.value &&
        isPhoneValid.value &&
        isEmailValid.value &&
        isLicenseValid.value &&
        isVehicleTypeValid.value &&
        isVehicleMakeValid.value &&
        isVehicleModelValid.value &&
        isVehicleYearValid.value &&
        isVehiclePlateValid.value;
  }

  /// Get driver name
  String get driverName {
    if (currentDriver.value == null) return '';
    return '${currentDriver.value!.firstName} ${currentDriver.value!.lastName}';
  }

  /// Get driver email
  String get driverEmail => currentDriver.value?.email ?? '';

  /// Get driver phone
  String get driverPhone => currentDriver.value?.phoneNumber ?? '';

  /// Get vehicle info
  String get vehicleInfo {
    if (currentDriver.value == null) return '';
    return '${currentDriver.value!.vehicleYear} ${currentDriver.value!.vehicleModel} ${currentDriver.value!.vehicleColor}';
  }

  /// Get driver rating
  double? get rating => currentDriver.value?.rating;

  /// Get total rides
  int? get totalRides => currentDriver.value?.totalRides;

  /// Get driver status
  String get driverStatus => currentDriver.value?.status ?? 'offline';

  /// Check if driver is available
  bool get isAvailable => currentDriver.value?.isAvailable ?? false;

  /// Check if driver has payment method
  bool get hasPaymentMethod => currentDriver.value?.hasPaymentMethod ?? false;

  /// Check if driver is active
  bool get isActive => currentDriver.value?.isActive ?? false;

  /// Check if notifications are enabled
  bool get notificationEnabled =>
      currentDriver.value?.notificationEnabled ?? true;

  /// Get current location
  Map<String, double?> get currentLocation {
    final driver = currentDriver.value;
    return {
      'latitude': driver?.currentLatitude,
      'longitude': driver?.currentLongitude,
    };
  }
}
