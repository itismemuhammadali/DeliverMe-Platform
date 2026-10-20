import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../common/constant/app_colors.dart';
import '../../../../common/utils/custom_text_form_field.dart';
import '../controller/driver_auth_controller.dart';
import 'driver_vehicle_info_screen.dart';

class DriverRegisterScreen extends StatefulWidget {
  const DriverRegisterScreen({super.key});

  @override
  State<DriverRegisterScreen> createState() => _DriverRegisterScreenState();
}

class _DriverRegisterScreenState extends State<DriverRegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  late TabController _tabController;

  int _currentStep = 0;
  final int _totalSteps = 3;

  // Password visibility states
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _hasAgreedToContract = false;

  // TextEditingControllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _licenseController;
  late TextEditingController _vehicleModelController;
  late TextEditingController _vehiclePlateController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _totalSteps, vsync: this);
    final controller = DriverAuthController.to;

    _firstNameController =
        TextEditingController(text: controller.firstName.value);
    _lastNameController =
        TextEditingController(text: controller.lastName.value);
    _emailController = TextEditingController(text: controller.email.value);
    _phoneController =
        TextEditingController(text: controller.phoneNumber.value);
    _passwordController =
        TextEditingController(text: controller.password.value);
    _confirmPasswordController =
        TextEditingController(text: controller.confirmPassword.value);
    _licenseController =
        TextEditingController(text: controller.driverLicenseNumber.value);
    _vehicleModelController =
        TextEditingController(text: controller.vehicleModel.value);
    _vehiclePlateController =
        TextEditingController(text: controller.vehiclePlateNumber.value);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licenseController.dispose();
    _vehicleModelController.dispose();
    _vehiclePlateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = DriverAuthController.to;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.blackColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Driver Registration',
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: _buildProgressIndicator(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step indicator
            _buildStepIndicator(),

            // Form content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildPersonalInfoStep(controller),
                  _buildVehicleInfoStep(controller),
                  _buildDocumentsStep(controller),
                ],
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              height: 4.h,
              decoration: BoxDecoration(
                color: index <= _currentStep
                    ? AppColors.primaryColor
                    : AppColors.greyColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepItem(0, 'Personal', Icons.person),
          _buildStepConnector(),
          _buildStepItem(1, 'Vehicle', Icons.directions_car),
          _buildStepConnector(),
          _buildStepItem(2, 'Documents', Icons.upload_file),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String title, IconData icon) {
    final isActive = step <= _currentStep;
    final isCompleted = step < _currentStep;

    return Column(
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryColor
                : AppColors.greyColor.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: AppColors.whiteColor,
            size: 20.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? AppColors.primaryColor : AppColors.greyColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector() {
    return Container(
      width: 30.w,
      height: 2.h,
      color: AppColors.greyColor.withValues(alpha: 0.3),
    );
  }

  Widget _buildPersonalInfoStep(DriverAuthController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(
              'Personal Information',
              'Tell us about yourself',
              Icons.person,
            ),
            SizedBox(height: 24.h),

            // First Name
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'First Name *',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    hint: 'Enter your first name',
                    controller: _firstNameController,
                    onChanged: (value) =>
                        controller.updateField('firstName', value),
                    prefixIcon: Icon(Icons.person_outline,
                        color: AppColors.primaryColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            // Last Name
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Name *',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    hint: 'Enter your last name',
                    controller: _lastNameController,
                    onChanged: (value) =>
                        controller.updateField('lastName', value),
                    prefixIcon: Icon(Icons.person_outline,
                        color: AppColors.primaryColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            // Email
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email Address *',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    hint: 'Enter your email address',
                    controller: _emailController,
                    onChanged: (value) =>
                        controller.updateField('email', value),
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icon(Icons.email_outlined,
                        color: AppColors.primaryColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            // Phone
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone Number *',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    hint: 'Enter your phone number',
                    controller: _phoneController,
                    onChanged: (value) =>
                        controller.updateField('phoneNumber', value),
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icon(Icons.phone_outlined,
                        color: AppColors.primaryColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone number is required';
                      }
                      if (!_isValidPhone(value)) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            // Password
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password *',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    hint: 'Enter your password (min 6 characters)',
                    controller: _passwordController,
                    onChanged: (value) =>
                        controller.updateField('password', value),
                    obsecure: !_isPasswordVisible,
                    prefixIcon:
                        Icon(Icons.lock_outline, color: AppColors.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            // Confirm Password
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm Password *',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    hint: 'Re-enter your password to confirm',
                    controller: _confirmPasswordController,
                    onChanged: (value) =>
                        controller.updateField('confirmPassword', value),
                    obsecure: !_isConfirmPasswordVisible,
                    prefixIcon:
                        Icon(Icons.lock_outline, color: AppColors.primaryColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            // License Number
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Driver License Number *',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomTextFormField(
                    hint: 'Enter your driver license number',
                    controller: _licenseController,
                    onChanged: (value) =>
                        controller.updateField('driverLicenseNumber', value),
                    prefixIcon: Icon(Icons.credit_card_outlined,
                        color: AppColors.primaryColor),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'License number is required';
                      }
                      if (value.length < 5) {
                        return 'License number must be at least 5 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfoStep(DriverAuthController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Vehicle Information',
            'Tell us about your vehicle',
            Icons.directions_car,
          ),
          SizedBox(height: 24.h),

          // Vehicle Type
          Obx(() => _buildDropdownField(
                'Vehicle Type',
                'Select your vehicle type',
                Icons.directions_car,
                controller.vehicleType.value.isEmpty
                    ? null
                    : controller.vehicleType.value,
                controller.vehicleTypes
                    .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type.replaceAll('_', ' ').toUpperCase()),
                        ))
                    .toList(),
                (value) => controller.updateField('vehicleType', value ?? ''),
                (value) => value == null || value.isEmpty
                    ? 'Vehicle type is required'
                    : null,
              )),
          SizedBox(height: 16.h),

          // Vehicle Make
          Obx(() => _buildDropdownField(
                'Vehicle Make',
                'Select your vehicle make',
                Icons.branding_watermark,
                controller.vehicleMake.value.isEmpty
                    ? null
                    : controller.vehicleMake.value,
                controller.vehicleMakes
                    .map((make) => DropdownMenuItem<String>(
                          value: make,
                          child: Text(make),
                        ))
                    .toList(),
                (value) => controller.updateField('vehicleMake', value ?? ''),
                (value) => value == null || value.isEmpty
                    ? 'Vehicle make is required'
                    : null,
              )),
          SizedBox(height: 16.h),

          // Vehicle Model
          Container(
            margin: EdgeInsets.only(bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vehicle Model *',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackColor,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextFormField(
                  hint: 'Enter your vehicle model (e.g., Camry, Accord)',
                  controller: _vehicleModelController,
                  onChanged: (value) =>
                      controller.updateField('vehicleModel', value),
                  prefixIcon: Icon(Icons.directions_car_outlined,
                      color: AppColors.primaryColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vehicle model is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Vehicle Year
          Obx(() => _buildDropdownField(
                'Vehicle Year',
                'Select your vehicle year',
                Icons.calendar_today,
                controller.vehicleYear.value == 0
                    ? null
                    : controller.vehicleYear.value,
                List.generate(30, (index) {
                  final year = DateTime.now().year - index;
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(year.toString()),
                  );
                }),
                (value) => controller.updateField('vehicleYear', value ?? 0),
                (value) => value == null || value == 0
                    ? 'Vehicle year is required'
                    : null,
              )),
          SizedBox(height: 16.h),

          // Vehicle Plate
          Container(
            margin: EdgeInsets.only(bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vehicle Plate Number *',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blackColor,
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextFormField(
                  hint: 'Enter your vehicle plate number',
                  controller: _vehiclePlateController,
                  onChanged: (value) =>
                      controller.updateField('vehiclePlateNumber', value),
                  prefixIcon: Icon(Icons.confirmation_number,
                      color: AppColors.primaryColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vehicle plate number is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep(DriverAuthController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(
            'Document Upload',
            'Upload your required documents',
            Icons.upload_file,
          ),
          SizedBox(height: 24.h),

          // Driving License Upload
          _buildDocumentUploadCard(
            'Driving License',
            'Upload a clear photo of your driving license',
            Icons.credit_card,
            'driver_license',
            controller,
          ),
          SizedBox(height: 16.h),

          // ID Card Upload
          _buildDocumentUploadCard(
            'ID Card',
            'Upload a clear photo of your ID card',
            Icons.badge,
            'id_card',
            controller,
          ),
          SizedBox(height: 24.h),

          // Independent Contractor Agreement
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.greyColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.greyColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _hasAgreedToContract,
                      onChanged: (value) {
                        setState(() {
                          _hasAgreedToContract = value ?? false;
                        });
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                    Expanded(
                      child: Text(
                        'Independent Contractor Agreement',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'By registering as a driver, you agree to work as an independent contractor. You must be at least 21 years old, have a valid driving license, and understand that you are responsible for your own taxes and insurance. You agree to comply with all local laws and regulations.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.greyColor,
                    height: 1.4,
                  ),
                ),
                if (!_hasAgreedToContract)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      'You must agree to the Independent Contractor Agreement to continue.',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25.r),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 24.sp,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blackColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.greyColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>(
    String label,
    String hint,
    IconData icon,
    T? value,
    List<DropdownMenuItem<T>> items,
    Function(T?) onChanged,
    String? Function(T?) validator,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<T>(
          initialValue: value,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide:
                  BorderSide(color: AppColors.greyColor.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide:
                  BorderSide(color: AppColors.greyColor.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primaryColor),
            ),
            filled: true,
            fillColor: AppColors.whiteColor,
          ),
          items: items,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDocumentUploadCard(
    String title,
    String description,
    IconData icon,
    String docType,
    DriverAuthController controller,
  ) {
    return Obx(() {
      final hasDocument = controller.documents.containsKey(docType);
      final document = controller.documents[docType];

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: hasDocument
              ? AppColors.primaryColor.withValues(alpha: 0.1)
              : AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasDocument
                ? AppColors.primaryColor
                : AppColors.greyColor.withValues(alpha: 0.3),
            width: hasDocument ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: hasDocument
                        ? AppColors.primaryColor
                        : AppColors.greyColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    hasDocument ? Icons.check : icon,
                    color: hasDocument
                        ? AppColors.whiteColor
                        : AppColors.greyColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.greyColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasDocument)
                  IconButton(
                    onPressed: () => controller.removeDocument(docType),
                    icon: Icon(Icons.close, color: AppColors.redColor),
                  ),
              ],
            ),
            if (hasDocument) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.file_present,
                        color: AppColors.primaryColor, size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        document?.name ?? 'Document uploaded',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => controller.pickDocument(docType),
                  icon: Icon(Icons.upload, size: 18.sp),
                  label: Text('Upload Document'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.whiteColor,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildNavigationButtons(DriverAuthController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: SizedBox(
                height: 48.h,
                child: Material(
                  color: AppColors.greyColor,
                  borderRadius: BorderRadius.circular(8.r),
                  child: InkWell(
                    onTap: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Center(
                      child: Text(
                        'Previous',
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) SizedBox(width: 16.w),
          Expanded(
            child: Obx(() {
              final isLoading = controller.isLoading.value;
              return SizedBox(
                height: 48.h,
                child: Material(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                  child: InkWell(
                    onTap: isLoading ? null : () => _handleNextStep(controller),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Center(
                      child: Text(
                        _currentStep == _totalSteps - 1
                            ? (isLoading ? 'Registering...' : 'Complete Registration')
                            : 'Next',
                        style: TextStyle(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _handleNextStep(DriverAuthController controller) async {
    if (_currentStep == _totalSteps - 1) {
      // Final step - complete registration
      if (_formKey.currentState!.validate()) {
        print('🚀 Starting driver registration...');
        final success = await controller.register();
        print('📋 Registration result: $success');
        if (success) {
          print('✅ Registration successful, navigating to vehicle info screen');
          Get.offAll(() => const DriverVehicleInfoScreen());
        } else {
          print('❌ Registration failed, staying on registration screen');
        }
      }
    } else {
      // Validate current step and move to next
      if (_validateCurrentStep()) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Personal info
        return _formKey.currentState!.validate();
      case 1: // Vehicle info
        final controller = DriverAuthController.to;
        return controller.vehicleType.value.isNotEmpty &&
            controller.vehicleMake.value.isNotEmpty &&
            controller.vehicleModel.value.isNotEmpty &&
            controller.vehicleYear.value > 0 &&
            controller.vehiclePlateNumber.value.isNotEmpty;
      case 2: // Documents
        return _hasAgreedToContract; // Must agree to Independent Contractor Agreement
      default:
        return false;
    }
  }

  bool _isValidPhone(String phone) {
    // Basic phone validation - can be enhanced
    return phone.length >= 10 && RegExp(r'^[0-9+\-\s()]+$').hasMatch(phone);
  }
}
