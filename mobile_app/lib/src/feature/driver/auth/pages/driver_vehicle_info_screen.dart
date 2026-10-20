import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../common/constant/app_colors.dart';
import '../../../../common/constant/app_images.dart';
import '../../../../common/utils/custom_button.dart';
import '../../../../common/utils/custom_text_form_field.dart';
import '../../../../common/services/driver_auth_service.dart';
import '../controller/driver_auth_controller.dart';
import '../../driver_bottom_bar/pages/driver_bottom_bar_screen.dart';

class DriverVehicleInfoScreen extends StatelessWidget {
  const DriverVehicleInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('🚗 DriverVehicleInfoScreen is loading...');
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
          'Vehicle Information',
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      AppImages.logo,
                      width: 60.w,
                      height: 60.h,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Complete Your Profile',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Add your vehicle details and documents',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30.h),

              // Vehicle Information Section
              Text(
                'Vehicle Information',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ),
              SizedBox(height: 16.h),

              Obx(() => Column(
                    children: [
                      // Vehicle Type Dropdown (Required)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.greyColor),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.vehicleType.value.isNotEmpty
                                ? controller.vehicleType.value
                                : null,
                            hint: Text(
                              'Select Vehicle Type*',
                              style: TextStyle(
                                color: AppColors.greyColor,
                                fontSize: 14.sp,
                              ),
                            ),
                            items: controller.vehicleTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(
                                  type.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              if (value != null) {
                                controller.updateVehicleType(value);
                              }
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Vehicle Make Dropdown (Required)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.greyColor),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.vehicleMake.value.isNotEmpty
                                ? controller.vehicleMake.value
                                : null,
                            hint: Text(
                              'Select Vehicle Make*',
                              style: TextStyle(
                                color: AppColors.greyColor,
                                fontSize: 14.sp,
                              ),
                            ),
                            items: controller.vehicleMakes.map((String make) {
                              return DropdownMenuItem<String>(
                                value: make,
                                child: Text(
                                  make,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              if (value != null) {
                                controller.updateVehicleMake(value);
                              }
                            },
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Vehicle Model (Required)
                      CustomTextFormField(
                        controller: TextEditingController(
                            text: controller.vehicleModel.value),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vehicle model is required';
                          }
                          if (value.length < 2) {
                            return 'Vehicle model must be at least 2 characters';
                          }
                          return null;
                        },
                        hint: 'Vehicle Model*',
                        onFieldSubmitted: (value) =>
                            controller.updateVehicleModel(value),
                      ),

                      SizedBox(height: 16.h),

                      // Vehicle Year (Required)
                      CustomTextFormField(
                        controller: TextEditingController(
                          text: controller.vehicleYear.value > 0
                              ? controller.vehicleYear.value.toString()
                              : '',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vehicle year is required';
                          }
                          final year = int.tryParse(value);
                          if (year == null) {
                            return 'Please enter a valid year';
                          }
                          final currentYear = DateTime.now().year;
                          if (year < 1900 || year > currentYear + 1) {
                            return 'Year must be between 1900 and ${currentYear + 1}';
                          }
                          return null;
                        },
                        hint: 'Vehicle Year*',
                        onFieldSubmitted: (value) {
                          final year = int.tryParse(value);
                          if (year != null) {
                            controller.updateVehicleYear(year);
                          }
                        },
                      ),

                      SizedBox(height: 16.h),

                      // Vehicle Plate Number (Required)
                      CustomTextFormField(
                        controller: TextEditingController(
                            text: controller.vehiclePlateNumber.value),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Plate number is required';
                          }
                          if (value.length < 3) {
                            return 'Plate number must be at least 3 characters';
                          }
                          return null;
                        },
                        hint: 'Vehicle Plate Number*',
                        onFieldSubmitted: (value) =>
                            controller.updateVehiclePlateNumber(value),
                      ),

                      SizedBox(height: 30.h),

                      // Documents Section
                      Text(
                        'Required Documents',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Driver License Upload (Required)
                      _buildDocumentUpload(
                        title: 'Driver License*',
                        subtitle: 'Upload your valid driver license',
                        isUploaded: controller.hasDocument('driver_license'),
                        fileName:
                            controller.getDocumentFileName('driver_license'),
                        onUpload: () =>
                            controller.pickDocument('driver_license'),
                        onRemove: () =>
                            controller.removeDocument('driver_license'),
                      ),

                      SizedBox(height: 16.h),

                      // Insurance Upload (Required, uses 'id_card' key under the hood)
                      _buildDocumentUpload(
                        title: 'Insurance*',
                        subtitle: 'Upload your vehicle insurance document',
                        isUploaded: controller.hasDocument('id_card'),
                        fileName: controller.getDocumentFileName('id_card'),
                        onUpload: () => controller.pickDocument('id_card'),
                        onRemove: () => controller.removeDocument('id_card'),
                      ),

                      SizedBox(height: 20.h),

                      // Debug Upload Button (for testing)
                      if (controller.documents.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              print('🔧 Testing document upload...');
                              await controller.uploadDocumentsManually();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            child: Text(
                                'Test Upload Documents (${controller.documents.length})'),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              print('🧪 Testing API calls...');
                              await controller.testUploadApiCalls();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            child: Text('Test API Calls Only'),
                          ),
                        ),
                      ],

                      SizedBox(height: 10.h),

                      // Complete Setup Button
                      CustomButton(
                        text: 'Complete Setup',
                        ontap: controller.isVehicleInfoFormValid &&
                                !controller.isLoading.value
                            ? () async {
                                print('🚗 Completing vehicle setup...');
                                // Set login status and reset registration flag
                                DriverAuthService.to.isLoggedIn.value = true;
                                DriverAuthService.to.isRegistering.value =
                                    false;
                                print(
                                    '✅ Vehicle setup complete, navigating to driver dashboard');
                                Get.offAll(() => DriverBottomBarScreen());
                              }
                            : () {
                                print('⚠️ Vehicle form not valid or loading');
                              },
                      ),

                      SizedBox(height: 20.h),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentUpload({
    required String title,
    required String subtitle,
    required bool isUploaded,
    required String fileName,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: isUploaded ? AppColors.primaryColor : AppColors.greyColor,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isUploaded ? Icons.check_circle : Icons.upload_file,
                color:
                    isUploaded ? AppColors.primaryColor : AppColors.greyColor,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUploaded)
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.close,
                    color: AppColors.redColor,
                    size: 20.sp,
                  ),
                ),
            ],
          ),
          if (isUploaded && fileName.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              'File: $fileName',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (!isUploaded) ...[
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onUpload,
                icon: Icon(Icons.upload, size: 16.sp),
                label: Text('Upload Document'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.whiteColor,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
