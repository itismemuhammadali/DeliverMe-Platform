import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/validator.dart';
import 'package:deliver_mee/src/common/constant/country_codes.dart';
import 'package:deliver_mee/src/common/utils/custom_app_bar.dart';
import 'package:deliver_mee/src/common/utils/custom_text_form_field.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/driver/profile/controller/driver_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DriverEditProfile extends StatefulWidget {
  const DriverEditProfile({super.key});

  @override
  State<DriverEditProfile> createState() => _DriverEditProfileState();
}

class _DriverEditProfileState extends State<DriverEditProfile> {
  late DriverProfileController controller;
  
  TextEditingController firstNameCtrl = TextEditingController();
  TextEditingController lastNameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController phoneCtrl = TextEditingController();
  TextEditingController licenseCtrl = TextEditingController();
  TextEditingController vehicleModelCtrl = TextEditingController();
  TextEditingController vehiclePlateCtrl = TextEditingController();
  
  final _formkey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isLoadingProfile = true;
  String? selectedVehicleType;
  String? selectedVehicleMake;
  int? selectedVehicleYear;
  
  // Country code selection
  late CountryCode selectedCountryCode;

  @override
  void initState() {
    super.initState();
    controller = DriverProfileController.to;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      await controller.loadProfile();
      
      // Extract country code from phone number
      String phoneNumber = controller.phoneNumber.value;
      CountryCode defaultCountry = getDefaultCountryCode();
      
      // Try to match country code with phone number
      for (var country in countryCodes) {
        if (phoneNumber.startsWith(country.dialCode)) {
          defaultCountry = country;
          phoneNumber = phoneNumber.replaceFirst(country.dialCode, '').trim();
          break;
        }
      }
      
      setState(() {
        firstNameCtrl.text = controller.firstName.value;
        lastNameCtrl.text = controller.lastName.value;
        emailCtrl.text = controller.email.value;
        phoneCtrl.text = phoneNumber;
        licenseCtrl.text = controller.driverLicenseNumber.value;
        vehicleModelCtrl.text = controller.vehicleModel.value;
        vehiclePlateCtrl.text = controller.vehiclePlateNumber.value;
        selectedCountryCode = defaultCountry;
        
        // Set dropdown values - normalize to lowercase
        if (controller.vehicleType.value.isNotEmpty) {
          final normalizedType = controller.vehicleType.value.toLowerCase();
          // Check if it's in the list
          if (controller.vehicleTypes.contains(normalizedType)) {
            selectedVehicleType = normalizedType;
          } else {
            selectedVehicleType = null;
          }
        } else {
          selectedVehicleType = null;
        }
        
        selectedVehicleMake = controller.vehicleMake.value.isNotEmpty 
            ? controller.vehicleMake.value 
            : null;
        selectedVehicleYear = controller.vehicleYear.value > 0 
            ? controller.vehicleYear.value 
            : null;
        
        isLoadingProfile = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        isLoadingProfile = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formkey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Update controller values
      controller.updateField('firstName', firstNameCtrl.text.trim());
      controller.updateField('lastName', lastNameCtrl.text.trim());
      
      // Combine country code with phone number
      final fullPhoneNumber = '${selectedCountryCode.dialCode}${phoneCtrl.text.trim()}';
      controller.updateField('phoneNumber', fullPhoneNumber);
      
      controller.updateField('licenseNumber', licenseCtrl.text.trim());
      controller.updateField('vehicleType', controller.vehicleType.value);
      controller.updateField('vehicleMake', controller.vehicleMake.value);
      controller.updateField('vehicleModel', vehicleModelCtrl.text.trim());
      controller.updateField('vehicleYear', controller.vehicleYear.value.toString());
      controller.updateField('vehiclePlateNumber', vehiclePlateCtrl.text.trim());

      final result = await controller.updateProfile();

      setState(() {
        isLoading = false;
      });

      if (result) {
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Navigate back after a short delay
        Future.delayed(Duration(milliseconds: 800), () {
          Navigator.pop(context);
        });
      } else {
        Get.snackbar(
          'Error',
          controller.error.value.isNotEmpty 
              ? controller.error.value 
              : 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
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
    if (isLoadingProfile) {
      return Scaffold(
        appBar: CustomAppBar(text: "Edit Profile", leading: true),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(text: "Edit Profile", leading: true),
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
                  text: 'Edit Profile',
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.naveBlue,
                ),
                SizedBox(height: 24.h),
                
                // PERSONAL INFORMATION SECTION
                TextWidget(
                  text: 'Personal Information',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blackColor,
                ),
                SizedBox(height: 16.h),
                
                // First Name
                TextWidget(
                  text: 'First Name *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                CustomTextFormField(
                  controller: firstNameCtrl,
                  validator: (value) => value?.isEmpty ?? true ? 'First name is required' : null,
                  hint: 'First Name',
                ),
                SizedBox(height: 16.h),
                
                // Last Name
                TextWidget(
                  text: 'Last Name *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                CustomTextFormField(
                  controller: lastNameCtrl,
                  validator: (value) => value?.isEmpty ?? true ? 'Last name is required' : null,
                  hint: 'Last Name',
                ),
                SizedBox(height: 16.h),
                
                // Phone
                TextWidget(
                  text: 'Phone Number *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    // Country Code Dropdown
                    SizedBox(
                      height: 50.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.greyColor.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(8.r),
                          color: AppColors.textfieldColor,
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: DropdownButton<CountryCode>(
                            value: selectedCountryCode,
                            isDense: true,
                            underline: SizedBox(),
                            items: countryCodes.map((CountryCode cc) {
                              return DropdownMenuItem<CountryCode>(
                                value: cc,
                                child: Text('${cc.flag} ${cc.dialCode}'),
                              );
                            }).toList(),
                            onChanged: (CountryCode? newCountry) {
                              if (newCountry != null) {
                                setState(() {
                                  selectedCountryCode = newCountry;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    // Phone Number Input
                    Expanded(
                      child: CustomTextFormField(
                        controller: phoneCtrl,
                        validator: (value) => validatePhoneNumber(value),
                        hint: 'Phone Number',
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                
                // Email (Read-only)
                TextWidget(
                  text: 'Email',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                CustomTextFormField(
                  controller: emailCtrl,
                  enable: false,
                  validator: (value) => null,
                  hint: 'Email',
                ),
                SizedBox(height: 24.h),
                
                // VEHICLE INFORMATION SECTION
                TextWidget(
                  text: 'Vehicle Information',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blackColor,
                ),
                SizedBox(height: 16.h),
                
                // Vehicle Type
                TextWidget(
                  text: 'Vehicle Type *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  value: selectedVehicleType,
                  decoration: InputDecoration(
                    hintText: 'Select vehicle type',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                  items: controller.vehicleTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type.replaceAll('_', ' ').toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        selectedVehicleType = value;
                      });
                      controller.updateField('vehicleType', value);
                    }
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Vehicle type is required' : null,
                ),
                SizedBox(height: 16.h),
                
                // Vehicle Make
                TextWidget(
                  text: 'Vehicle Make *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<String>(
                  value: selectedVehicleMake,
                  decoration: InputDecoration(
                    hintText: 'Select vehicle make',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                  items: controller.vehicleMakes.map((String make) {
                    return DropdownMenuItem<String>(
                      value: make,
                      child: Text(make),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        selectedVehicleMake = value;
                      });
                      controller.updateField('vehicleMake', value);
                    }
                  },
                  validator: (value) => value == null || value.isEmpty ? 'Vehicle make is required' : null,
                ),
                SizedBox(height: 16.h),
                
                // Vehicle Model
                TextWidget(
                  text: 'Vehicle Model *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                CustomTextFormField(
                  controller: vehicleModelCtrl,
                  validator: (value) => value?.isEmpty ?? true ? 'Vehicle model is required' : null,
                  hint: 'Vehicle Model',
                ),
                SizedBox(height: 16.h),
                
                // Vehicle Year
                TextWidget(
                  text: 'Vehicle Year *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                DropdownButtonFormField<int>(
                  value: selectedVehicleYear,
                  decoration: InputDecoration(
                    hintText: 'Select vehicle year',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: AppColors.primaryColor),
                    ),
                  ),
                  items: List.generate(30, (index) {
                    final year = DateTime.now().year - index;
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }),
                  onChanged: (int? value) {
                    if (value != null) {
                      setState(() {
                        selectedVehicleYear = value;
                      });
                      controller.updateVehicleYear(value);
                    }
                  },
                  validator: (value) => value == null || value == 0 ? 'Vehicle year is required' : null,
                ),
                SizedBox(height: 16.h),
                
                // Vehicle Plate Number
                TextWidget(
                  text: 'Vehicle Plate Number *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                CustomTextFormField(
                  controller: vehiclePlateCtrl,
                  validator: (value) => value?.isEmpty ?? true ? 'Vehicle plate number is required' : null,
                  hint: 'Vehicle Plate Number',
                ),
                SizedBox(height: 24.h),
                
                // LICENSE INFORMATION SECTION
                TextWidget(
                  text: 'License Information',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blackColor,
                ),
                SizedBox(height: 16.h),
                
                // Driver License Number
                TextWidget(
                  text: 'Driver License Number *',
                  fontSize: 14.sp,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 8.h),
                CustomTextFormField(
                  controller: licenseCtrl,
                  validator: (value) => value?.isEmpty ?? true ? 'Driver license number is required' : null,
                  hint: 'Driver License Number',
                ),
                SizedBox(height: 30.h),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: Material(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8.r),
                    child: InkWell(
                      onTap: isLoading ? null : _saveProfile,
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
                                text: 'Save Changes',
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
