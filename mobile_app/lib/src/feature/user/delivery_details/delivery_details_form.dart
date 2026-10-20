import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/common/utils/custom_button.dart';
import 'package:deliver_mee/src/feature/user/home/controller/controller.dart';
import 'package:deliver_mee/src/feature/user/payment/payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DeliveryDetailsForm extends StatefulWidget {
  const DeliveryDetailsForm({super.key});

  @override
  State<DeliveryDetailsForm> createState() => _DeliveryDetailsFormState();
}

class _DeliveryDetailsFormState extends State<DeliveryDetailsForm> {
  final HomeController ctrl = Get.find<HomeController>();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemDescriptionController =
      TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _specialInstructionsController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _weightController.text = ctrl.itemWeight.value.toString();
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemDescriptionController.dispose();
    _weightController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: AppColors.blackColor),
        ),
        title: TextWidget(
          text: 'Delivery Details',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.blackColor,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Summary
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.tabColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'Delivery Route',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextWidget(
                            text: ctrl.fromlocation.value,
                            fontSize: 14.sp,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.only(left: 6.w),
                      child: Container(
                        width: 2.w,
                        height: 20.h,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: TextWidget(
                            text: ctrl.tolocation.value,
                            fontSize: 14.sp,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Item Name
              TextWidget(
                text: 'Item Name *',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _itemNameController,
                decoration: InputDecoration(
                  hintText: 'Enter item name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Item name is required';
                  }
                  return null;
                },
                onChanged: (value) => ctrl.itemName.value = value,
              ),

              SizedBox(height: 20.h),

              // Item Description
              TextWidget(
                text: 'Item Description',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _itemDescriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe the item (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                onChanged: (value) => ctrl.itemDescription.value = value,
              ),

              SizedBox(height: 20.h),

              // Weight
              TextWidget(
                text: 'Weight (lbs) *',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter weight in pounds',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Weight is required';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
                onChanged: (value) {
                  final weight = double.tryParse(value);
                  if (weight != null) ctrl.itemWeight.value = weight;
                },
              ),

              SizedBox(height: 20.h),

              // Special Instructions
              TextWidget(
                text: 'Special Instructions',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _specialInstructionsController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Any special delivery instructions (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                onChanged: (value) => ctrl.specialInstructions.value = value,
              ),

              SizedBox(height: 32.h),

              // Create Delivery Button
              Obx(() => CustomButton(
                    text: ctrl.isCreatingDelivery.value
                        ? 'Creating Delivery...'
                        : 'Create Delivery',
                    ontap: ctrl.isCreatingDelivery.value
                        ? () {} // Empty function when creating
                        : _createDelivery,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _createDelivery() async {
    if (_formKey.currentState!.validate()) {
      final error = await ctrl.createDelivery();
      if (error == null) {
        // Navigate to payment page after successful delivery creation
        Get.to(() => PaymentMethodScreen(), transition: Transition.cupertino);
      }
      // If error is not null, it's shown by the controller
    }
  }
}
