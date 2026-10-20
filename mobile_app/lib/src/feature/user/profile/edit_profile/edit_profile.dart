import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/constant/validator.dart';
import 'package:deliver_mee/src/common/constant/country_codes.dart';
import 'package:deliver_mee/src/common/utils/custom_app_bar.dart';
import 'package:deliver_mee/src/common/utils/custom_text_form_field.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/common/services/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<EditProfileScreen> {
  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isLoadingProfile = true;
  
  // Country code selection
  late CountryCode selectedCountryCode;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      isLoadingProfile = true;
    });

    try {
      // Fetch fresh profile data from API
      final customerService = Get.find<CustomerService>();
      final result = await customerService.getProfile();

      if (result['success']) {
        final customer = result['data'];
        
        // Extract country code from phone number
        String phoneNumber = customer['phone_number'] ?? '';
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
          firstName.text = customer['first_name'] ?? '';
          lastName.text = customer['last_name'] ?? '';
          email.text = customer['email'] ?? '';
          phone.text = phoneNumber;
          selectedCountryCode = defaultCountry;
          isLoadingProfile = false;
        });
        
        print('✅ Profile loaded successfully');
      } else {
        // Fallback to SharedPreferences if API fails
        print('⚠️ API failed, loading from SharedPreferences');
        final prefs = await SharedPreferences.getInstance();
        final fName = prefs.getString('first_name') ?? '';
        final lName = prefs.getString('last_name') ?? '';
        final phoneNum = prefs.getString('phone_number') ?? '';
        
        // Extract country code from phone number
        CountryCode defaultCountry = getDefaultCountryCode();
        String phoneNumber = phoneNum;
        for (var country in countryCodes) {
          if (phoneNumber.startsWith(country.dialCode)) {
            defaultCountry = country;
            phoneNumber = phoneNumber.replaceFirst(country.dialCode, '').trim();
            break;
          }
        }
        
        setState(() {
          firstName.text = fName;
          lastName.text = lName;
          email.text = prefs.getString('email') ?? '';
          phone.text = phoneNumber;
          selectedCountryCode = defaultCountry;
          isLoadingProfile = false;
        });
      }
    } catch (e) {
      print('❌ Error loading profile: $e');
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
      // Combine country code with phone number
      final fullPhoneNumber = '${selectedCountryCode.dialCode}${phone.text.trim()}';
      
      print('📝 Updating profile: ${firstName.text} ${lastName.text}, $fullPhoneNumber');

      final customerService = Get.find<CustomerService>();
      final result = await customerService.updateProfile(
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        email: email.text.trim(),
        phoneNumber: fullPhoneNumber,
      );

      setState(() {
        isLoading = false;
      });

      if (result['success']) {
        // Reload profile to get fresh data
        await _loadProfile();

        Get.snackbar(
          'Success',
          result['message'] ?? 'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );

        // Wait a bit for user to see the success message
        await Future.delayed(Duration(milliseconds: 500));
        Navigator.pop(context);
      } else {
        Get.snackbar(
          'Error',
          result['error'] ?? 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('❌ Save profile error: $e');
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
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
        child: Container(
          height: ScreenUtil().screenHeight,
          width: ScreenUtil().screenWidth,
          child: Form(
            key: _formkey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextWidget(
                      text: 'Edit Profile',
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.naveBlue,
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: 'First Name',
                          fontSize: 14.sp,
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        CustomTextFormField(
                          controller: firstName,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SvgPicture.asset(
                              AppIcons.profileIcon,
                              colorFilter: ColorFilter.mode(
                                Colors.grey,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          validator: (validator) => nameValidator(validator),
                          hint: 'First Name',
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        TextWidget(
                          text: 'Last Name',
                          fontSize: 14.sp,
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        CustomTextFormField(
                          controller: lastName,
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SvgPicture.asset(
                              AppIcons.profileIcon,
                              colorFilter: ColorFilter.mode(
                                Colors.grey,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          validator: (validator) => nameValidator(validator),
                          hint: 'Last Name',
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        TextWidget(
                          text: 'Email',
                          fontSize: 14.sp,
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        CustomTextFormField(
                          controller: email,
                          validator: (value) => emailValidator(value),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: SvgPicture.asset(
                              AppIcons.mailprofileIcon,
                              colorFilter: ColorFilter.mode(
                                Colors.grey,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          hint: 'Email',
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        TextWidget(
                          text: 'Phone',
                          fontSize: 14.sp,
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
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
                                controller: phone,
                                validator: (validator) => validatePhoneNumber(validator),
                                hint: 'Phone Number',
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
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
                          child: TextWidget(
                            text: isLoading ? 'Saving...' : 'Save Changes',
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
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
    );
  }
}
