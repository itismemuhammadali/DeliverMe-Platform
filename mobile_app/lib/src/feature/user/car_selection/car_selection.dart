import 'dart:io';
import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_container.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/user/car_selection/controller.dart';
import 'package:deliver_mee/src/feature/user/home/controller/controller.dart';
import 'package:deliver_mee/src/feature/user/payment/payment.dart';
import 'package:deliver_mee/src/feature/user/search/search.dart';
import 'package:deliver_mee/src/models/car_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CarSelectionScreen extends StatefulWidget {
  final CarModel model;
  CarSelectionScreen({super.key, required this.model});

  @override
  State<CarSelectionScreen> createState() => _CarSelectionScreenState();
}

class _CarSelectionScreenState extends State<CarSelectionScreen> {
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemWeightController = TextEditingController();
  final TextEditingController itemCountController = TextEditingController();
  final TextEditingController itemHeightController = TextEditingController();
  final TextEditingController itemLengthController = TextEditingController();
  final TextEditingController itemWidthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Calculate distance and time when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final CarController ctrl = Get.find<CarController>();
      final HomeController homeController = Get.find<HomeController>();

      // Calculate initial distance and time
      ctrl.calculateDistanceAndTime();

      // Listen to vehicle type changes and recalculate
      homeController.selectedVehicleType.listen((_) {
        ctrl.calculateDistanceAndTime();
      });

      // Listen to location changes and recalculate
      homeController.fromlocation.listen((_) {
        ctrl.calculateDistanceAndTime();
      });
      homeController.tolocation.listen((_) {
        ctrl.calculateDistanceAndTime();
      });
    });
  }

  @override
  void dispose() {
    itemNameController.dispose();
    itemWeightController.dispose();
    itemCountController.dispose();
    itemHeightController.dispose();
    itemLengthController.dispose();
    itemWidthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CarController ctrl = Get.find<CarController>();
    final HomeController homectrl = Get.find<HomeController>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header with back button and "Select Service" title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              print('🔙 Back button tapped');
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 35.h,
                              width: 35.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xffC9C9C9),
                                ),
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.black),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          TextWidget(
                            text: 'Select Service',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Location card
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Obx(
                        () => _buildLocationCard(
                          from: homectrl.fromlocation.value,
                          to: homectrl.tolocation.value,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Type heading
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextWidget(
                          text: 'Type',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Service selection options (Cargo Van, Pickup Truck)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: SizedBox(
                        height: 100.h,
                        child: Obx(
                          () => Row(
                            children: List.generate(
                              ctrl.carslist.length,
                              (index) => _buildServiceItem(
                                ctrl.carslist[index].image!,
                                ctrl.carslist[index].name!,
                                () {
                                  ctrl.selectedindex.value = index;

                                  // Update home controller with selected service type
                                  final homeController = Get.find<HomeController>();
                                  final selectedService = ctrl.carslist[index];

                                  // Map service name to vehicle type and delivery type
                                  String vehicleType = '';
                                  String deliveryType = '';

                                  switch (selectedService.name!.toLowerCase()) {
                                    case 'cargo van':
                                      vehicleType = 'cargo_van';
                                      deliveryType = 'cargo';
                                      break;
                                    case 'pickup truck':
                                      vehicleType = 'pickup_truck';
                                      deliveryType = 'pickup';
                                      break;
                                    default:
                                      vehicleType = 'cargo_van';
                                      deliveryType = 'cargo';
                                  }

                                  homeController.setVehicleType(vehicleType);
                                  homeController.setDeliveryType(deliveryType);
                                },
                                index,
                                ctrl,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Item Details - All fields in order
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Item Name
                          TextWidget(
                            text: 'Item Name',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(height: 4.h),
                          TextField(
                            controller: itemNameController,
                            decoration: InputDecoration(
                              hintText: 'e.g., Item, Box',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(color: AppColors.primaryColor),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          
                          // 2. Weight and 3. Item Count in a row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: 'Weight (lbs)',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    SizedBox(height: 4.h),
                                    TextField(
                                      controller: itemWeightController,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        hintText: '5.0',
                                        hintStyle: TextStyle(color: Colors.grey[400]),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                          borderSide: BorderSide(color: AppColors.primaryColor),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          // 4. Height, 5. Length, 6. Width in a row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: 'Height (in)',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    SizedBox(height: 4.h),
                                    TextField(
                                      controller: itemHeightController,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        hintText: '10',
                                        hintStyle: TextStyle(color: Colors.grey[400]),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                          borderSide: BorderSide(color: AppColors.primaryColor),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: 'Length (in)',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    SizedBox(height: 4.h),
                                    TextField(
                                      controller: itemLengthController,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        hintText: '15',
                                        hintStyle: TextStyle(color: Colors.grey[400]),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                          borderSide: BorderSide(color: AppColors.primaryColor),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextWidget(
                                      text: 'Width (in)',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    SizedBox(height: 4.h),
                                    TextField(
                                      controller: itemWidthController,
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      decoration: InputDecoration(
                                        hintText: '8',
                                        hintStyle: TextStyle(color: Colors.grey[400]),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r),
                                          borderSide: BorderSide(color: AppColors.primaryColor),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),

                          // Scheduled Delivery Details (Always scheduled)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: 'Scheduled Date',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(height: 4.h),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: homectrl.scheduledDate.value ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(Duration(days: 30)),
                                  );
                                  if (picked != null) {
                                    homectrl.scheduledDate.value = picked;
                                    // Reset time slot when date changes to ensure it's valid for new date
                                    homectrl.timeSlot.value = '';
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Obx(() => Text(
                                        homectrl.scheduledDate.value != null
                                            ? '${homectrl.scheduledDate.value!.year}-${homectrl.scheduledDate.value!.month.toString().padLeft(2, '0')}-${homectrl.scheduledDate.value!.day.toString().padLeft(2, '0')}'
                                            : 'Select date',
                                      )),
                                      Icon(Icons.calendar_today),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),

                              TextWidget(
                                text: 'Time Slot',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(height: 4.h),
                              Obx(() {
                                final date = homectrl.scheduledDate.value;
                                List<String> slots = [];
                                
                                if (date != null) {
                                  final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
                                  if (isWeekend) {
                                    slots = ['08:00-10:00', '10:00-12:00', '12:00-14:00', '14:00-16:00', '16:00-18:00', '18:00-20:00'];
                                  } else {
                                    slots = ['16:00-18:00', '18:00-20:00'];
                                  }
                                }

                                return DropdownButtonFormField<String>(
                                  initialValue: homectrl.timeSlot.value.isNotEmpty && slots.contains(homectrl.timeSlot.value) 
                                      ? homectrl.timeSlot.value 
                                      : null,
                                  items: slots
                                      .map((slot) {
                                        String label = '';
                                        switch(slot) {
                                          case '08:00-10:00': label = '8:00 AM - 10:00 AM'; break;
                                          case '10:00-12:00': label = '10:00 AM - 12:00 PM'; break;
                                          case '12:00-14:00': label = '12:00 PM - 2:00 PM'; break;
                                          case '14:00-16:00': label = '2:00 PM - 4:00 PM'; break;
                                          case '16:00-18:00': label = '4:00 PM - 6:00 PM'; break;
                                          case '18:00-20:00': label = '6:00 PM - 8:00 PM'; break;
                                          default: label = slot;
                                        }
                                        return DropdownMenuItem(
                                          value: slot,
                                          child: Text(label),
                                        );
                                      })
                                      .toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      homectrl.timeSlot.value = value;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: date == null ? 'Please select a date first' : 'Select time slot',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                      borderSide: BorderSide(color: AppColors.primaryColor),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                  ),
                                );
                              }),
                              SizedBox(height: 12.h),
                            ],
                          ),

                          // Item Photo heading
                          TextWidget(
                            text: 'Item Photo',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(height: 12.h),

                          // Item Photo Upload Card
                          Obx(() => Container(
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(alpha: 0.08),
                              border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3), width: 2),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: homectrl.itemPhotoFile.value != null
                              ? Column(
                                  children: [
                                    // Show the uploaded image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: Image.file(
                                        homectrl.itemPhotoFile.value!,
                                        width: double.infinity,
                                        height: 250.h,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(height: 16.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                                        SizedBox(width: 8.w),
                                        TextWidget(
                                          text: 'Picture uploaded successfully',
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12.h),
                                    // Button to retake/change picture
                                    GestureDetector(
                                      onTap: () async {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                              padding: EdgeInsets.all(16.w),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ListTile(
                                                    leading: Icon(Icons.camera_alt),
                                                    title: Text('Take Photo'),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      final ImagePicker picker = ImagePicker();
                                                      final XFile? photo = await picker.pickImage(
                                                        source: ImageSource.camera,
                                                        imageQuality: 80,
                                                      );
                                                      if (photo != null) {
                                                        homectrl.setItemPhotoFile(File(photo.path));
                                                      }
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading: Icon(Icons.photo_library),
                                                    title: Text('Choose from Gallery'),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      final ImagePicker picker = ImagePicker();
                                                      final XFile? photo = await picker.pickImage(
                                                        source: ImageSource.gallery,
                                                        imageQuality: 80,
                                                      );
                                                      if (photo != null) {
                                                        homectrl.setItemPhotoFile(File(photo.path));
                                                      }
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading: Icon(Icons.delete, color: Colors.red),
                                                    title: Text('Remove Photo', style: TextStyle(color: Colors.red)),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      homectrl.setItemPhotoFile(null);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppColors.primaryColor),
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: TextWidget(
                                          text: 'Change Picture',
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    // Title with asterisk
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        TextWidget(
                                          text: 'Take or upload the picture of your item',
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          textAlign: TextAlign.center,
                                        ),
                                        TextWidget(
                                          text: ' *',
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20.h),
                                    
                                    // Camera and Gallery buttons
                                    Row(
                                      children: [
                                        // Camera button
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () async {
                                              final ImagePicker picker = ImagePicker();
                                              final XFile? photo = await picker.pickImage(
                                                source: ImageSource.camera,
                                                imageQuality: 80,
                                              );
                                              if (photo != null) {
                                                homectrl.setItemPhotoFile(File(photo.path));
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 30.h),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: AppColors.primaryColor,
                                                  width: 2,
                                                ),
                                                borderRadius: BorderRadius.circular(12.r),
                                              ),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.camera_alt,
                                                    size: 40.h,
                                                    color: AppColors.primaryColor,
                                                  ),
                                                  SizedBox(height: 12.h),
                                                  TextWidget(
                                                    text: 'Camera',
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.primaryColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        
                                        // Gallery button
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () async {
                                              final ImagePicker picker = ImagePicker();
                                              final XFile? photo = await picker.pickImage(
                                                source: ImageSource.gallery,
                                                imageQuality: 80,
                                              );
                                              if (photo != null) {
                                                homectrl.setItemPhotoFile(File(photo.path));
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 30.h),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: AppColors.primaryColor,
                                                  width: 2,
                                                ),
                                                borderRadius: BorderRadius.circular(12.r),
                                              ),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.photo_library,
                                                    size: 40.h,
                                                    color: AppColors.primaryColor,
                                                  ),
                                                  SizedBox(height: 12.h),
                                                  TextWidget(
                                                    text: 'Gallery',
                                                    fontSize: 13.sp,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.primaryColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                          )),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Selected service card
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Obx(
                        () => _buildCargoVanCard(
                          homectrl.carslist[ctrl.selectedindex.value],
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Note section - above continue button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.blue, size: 20.sp),
                                SizedBox(width: 8.w),
                                TextWidget(
                                  text: 'Note',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[800],
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Padding(
                              padding: EdgeInsets.only(left: 28.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text: 'Please have your item outside your door',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.blue[800],
                                  ),
                                  SizedBox(height: 4.h),
                                  TextWidget(
                                    text: 'Deliveries are from door to door',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.blue[800],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Continue button at bottom - styled like sign-in button
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: Material(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8.r),
                          child: InkWell(
                            onTap: () async {
                              print('🚀 Continue button tapped - Creating delivery...');
                              
                              // Get values from input fields
                              final itemName = itemNameController.text.trim();
                              final weightStr = itemWeightController.text.trim();
                              
                              // Validate inputs
                              if (itemName.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Please enter item name',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              
                              if (weightStr.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Please enter weight',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              
                              // Parse values
                              final weight = double.tryParse(weightStr);
                              
                              if (weight == null || weight <= 0) {
                                Get.snackbar(
                                  'Error',
                                  'Please enter valid weight',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              
                              // Validate photo is uploaded
                              if (homectrl.itemPhotoFile.value == null) {
                                Get.snackbar(
                                  'Error',
                                  'Please upload a photo of your item',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              
                              // Get dimension values
                              final heightStr = itemHeightController.text.trim();
                              final lengthStr = itemLengthController.text.trim();
                              final widthStr = itemWidthController.text.trim();
                              
                              // Validate dimensions are provided
                              if (heightStr.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Please enter the item height',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              
                              if (lengthStr.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Please enter the item length',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              
                              if (widthStr.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Please enter the item width',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              
                              // Parse and validate dimension values
                              final height = double.tryParse(heightStr);
                              if (height == null || height <= 0) {
                                Get.snackbar(
                                  'Error',
                                  'Please enter a valid height',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              
                              final length = double.tryParse(lengthStr);
                              if (length == null || length <= 0) {
                                Get.snackbar(
                                  'Error',
                                  'Please enter a valid length',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              
                              final width = double.tryParse(widthStr);
                              if (width == null || width <= 0) {
                                Get.snackbar(
                                  'Error',
                                  'Please enter a valid width',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                                return;
                              }
                              
                              // Set values in controller
                              homectrl.itemName.value = itemName;
                              homectrl.itemWeight.value = weight;
                              homectrl.height.value = height;
                              homectrl.length.value = length;
                              homectrl.width.value = width;
                              
                              print('📦 Item Name: $itemName');
                              print('⚖️ Weight: $weight lbs');
                              print('📏 Height: $height in');
                              print('📏 Length: $length in');
                              print('📏 Width: $width in');
                              
                              // Create delivery before navigating to payment
                              final error = await homectrl.createDelivery();
                              
                              if (error == null) {
                                print('✅ Delivery created successfully');
                                print('📦 Delivery ID: ${homectrl.deliveryId.value}');
                                print('📦 Tracking Number: ${homectrl.trackingNumber.value}');
                                
                                // Navigate to payment screen
                                Get.to(
                                  () => PaymentMethodScreen(),
                                  transition: Transition.cupertino,
                                );
                              } else {
                                print('❌ Delivery creation failed: $error');
                                Get.snackbar(
                                  'Error',
                                  error,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  duration: Duration(seconds: 3),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(8.r),
                            child: Center(
                              child: Obx(() => TextWidget(
                                text: homectrl.isCreatingDelivery.value 
                                  ? 'Creating Delivery...' 
                                  : 'Continue',
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              )),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCargoVanCard(CarModel model) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Container(
        width: ScreenUtil().screenWidth,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Van Icon
            Image.asset(
              model.imagesecond!,
              width: 100.w,
              height: 50.h,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 12.w),

            // Text Column - Only Vehicle Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Vehicle Name - Flexible with ellipsis
                  TextWidget(
                    text: model.name ?? '',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem(String iconPath, String title,
      void Function()? onTap, int index, CarController ctrl) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Column(
        children: [
          CustomContainer(
            onTap: onTap,
            height: 70.w,
            width: 70.w,
            color: ctrl.selectedindex.value == index
                ? AppColors.primaryColor.withValues(alpha: 0.2)
                : AppColors.tabColor,
            borderRadius: 12.r,
            child: Center(
              child: Image.asset(
                iconPath,
                width: 45.w,
                height: 45.h,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          TextWidget(
            text: title,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({required String from, required String to}) {
    final HomeController ctrl = Get.find<HomeController>();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // From location
          GestureDetector(
            onTap: () {
              Get.to(
                () => SearchScreen(
                  location: ctrl.fromlocation.value,
                  tolocation: false,
                ),
                transition: Transition.cupertino,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, 
                      color: AppColors.primaryColor, 
                      size: 20.sp),
                    SizedBox(width: 8.w),
                    TextWidget(
                      text: 'From',
                      fontSize: 16.sp,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.check_circle,
                      color: AppColors.primaryColor,
                      size: 18.sp),
                  ],
                ),
                SizedBox(height: 8.h),
                TextWidget(
                  text: from.isEmpty ? 'Select pickup location' : from,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          // Dashed divider
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: SizedBox(
              width: double.infinity,
              height: 1,
              child: CustomPaint(
                painter: _DashedLinePainter(),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // To location
          GestureDetector(
            onTap: () {
              Get.to(
                () => SearchScreen(
                  location: ctrl.tolocation.value,
                  tolocation: true,
                ),
                transition: Transition.cupertino,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, 
                      color: AppColors.primaryColor, 
                      size: 20.sp),
                    SizedBox(width: 8.w),
                    TextWidget(
                      text: 'To',
                      fontSize: 16.sp,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.check_circle,
                      color: AppColors.primaryColor,
                      size: 18.sp),
                  ],
                ),
                SizedBox(height: 8.h),
                TextWidget(
                  text: to.isEmpty ? 'Select dropoff location' : to,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => false;
}
