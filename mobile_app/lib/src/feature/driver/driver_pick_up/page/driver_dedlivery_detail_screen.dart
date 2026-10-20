import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_app_bar.dart';
import 'package:deliver_mee/src/common/utils/custom_button.dart';
import 'package:deliver_mee/src/common/utils/custom_container.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/driver/driver_bottom_bar/pages/driver_bottom_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class DriverDedliveryDetailScreen extends StatefulWidget {
  const DriverDedliveryDetailScreen({super.key});

  @override
  State<DriverDedliveryDetailScreen> createState() =>
      _DriverDedliveryDetailScreenState();
}

class _DriverDedliveryDetailScreenState
    extends State<DriverDedliveryDetailScreen> {
  // Get delivery data from arguments
  Map<String, dynamic>? get deliveryData =>
      Get.arguments as Map<String, dynamic>?;
  Map<String, dynamic>? get delivery => deliveryData?['delivery'] ?? deliveryData;

  @override
  Widget build(BuildContext context) {
    final d = delivery;
    
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBar(text: "Delivery Details", leading: true),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address info
              _buildLocationSelectorRow(d),
              SizedBox(height: 16.h),

              Row(
                children: [
                  _summaryBox("Item", d?['item_name'] ?? "N/A"),
                  _summaryBox("Weight", "${d?['weight']?.toStringAsFixed(1) ?? '0'} LB"),
                  _summaryBox("Distance", "${d?['estimated_distance_km']?.toStringAsFixed(1) ?? '0'} km"),
                ],
              ),

              if (d?['item_photo_url'] != null) ...[
                SizedBox(height: 15.h),
                TextWidget(
                  text: 'Delivery Item Photo',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.greyTextColor,
                ),
                SizedBox(height: 15.h),
                Container(
                  height: 180.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      d!['item_photo_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported, size: 50.sp),
                    ),
                  ),
                ),
              ],

              SizedBox(height: 16.h),
              TextWidget(
                text: 'Preference',
                fontSize: 16.sp,
                color: AppColors.greyTextColor,
                fontWeight: FontWeight.w500,
              ),
              SizedBox(
                height: 10.h,
              ),
              TextWidget(
                text: d?['delivery_preference'] == 'attended' 
                    ? 'Attended Delivery: Driver must meet the customer.' 
                    : 'Leave at Residence/Location: Permission is granted for the driver to leave the item at the residence/location.',
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.greyTextColor,
              ),

              SizedBox(height: 15.h),

              TextWidget(
                text: "Extra Delivery Notes",
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.greyTextColor,
              ),
              SizedBox(height: 6.h),
              TextWidget(
                text: d?['special_instructions'] ?? 'No special instructions provided.',
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.greyTextColor,
              ),

              SizedBox(height: 20.h),
              CustomContainer(
                color: AppColors.containerColor,
                borderRadius: 12.r,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 4),
                      blurRadius: 4,
                      color: AppColors.blackColor.withValues(alpha: .16))
                ],
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: "Total Payment",
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                    TextWidget(
                      text: "\$ ${(d?['estimated_fare'] ?? d?['estimated_cost'] ?? 0.0).toStringAsFixed(2)}",
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),

              CustomButton(
                  text: "Back to Home",
                  ontap: () {
                    Get.back();
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryBox(String label, String value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            TextWidget(
                text: label,
                fontWeight: FontWeight.w400,
                fontSize: 10.sp,
                color: AppColors.greyTextColor),
            SizedBox(height: 4.h),
            TextWidget(
                text: value,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelectorRow(Map<String, dynamic>? d) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.radio_button_checked,
                        color: AppColors.primaryColor, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextWidget(
                        text: d?['pickup_address'] ?? "Pickup Address",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 15.w,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12.r)),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.locationIcon,
                      height: 15.h,
                      width: 15.w,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextWidget(
                        text: d?['dropoff_address'] ?? "Dropoff Address",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Container(
          height: 36.w,
          width: 36.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Center(
            child: SvgPicture.asset(
              AppIcons.arrowleftrightIcon,
              height: 15.h,
              width: 15.w,
            ),
          ),
        ),
      ],
    );
  }
}
