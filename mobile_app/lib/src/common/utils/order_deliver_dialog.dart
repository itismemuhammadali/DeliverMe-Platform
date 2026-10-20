import 'dart:ui';

import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_button.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OrderDeliverDialog extends StatefulWidget {
  final VoidCallback onYesBtnClick;

  OrderDeliverDialog({
    Key? key,
    required this.onYesBtnClick,
  }) : super(key: key);

  @override
  State<OrderDeliverDialog> createState() => _OrderDeliverDialogState();
}

class _OrderDeliverDialogState extends State<OrderDeliverDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);
    controller.addListener(() {
      setState(() {});
    });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaY: 2, sigmaX: 2),
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
            width: ScreenUtil().screenWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Icon(
                          Icons.close,
                        ),
                      )),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Center(
                  child: TextWidget(
                    text: "Order Delivered",
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                TextWidget(
                  text: "Preference",
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 6.h),
                TextWidget(
                  text:
                      "Leave At Residence/Location: Permission is granted for the driver to leave the item at the residence/location.",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
                SizedBox(height: 20.h),
                TextWidget(
                  text: "Extra Delivery Notes",
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 6.h),
                TextWidget(
                  text: "Call upon arrival.",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    _summaryBox("Total Item", "2"),
                    _summaryBox("Small", "12"),
                    _summaryBox("5.5", "LB"),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    _imageBox(AppImages.boxone),
                    SizedBox(width: 10.w),
                    _imageBox(AppImages.boxtwo),
                  ],
                ),
                SizedBox(height: 20.h),
                CustomButton(
                  text: 'Continue',
                  ontap: widget.onYesBtnClick,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageBox(String path) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: Image.asset(
          path,
          height: 160.h,
          fit: BoxFit.cover,
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
                text: "${label} ${value}",
                fontWeight: FontWeight.w400,
                fontSize: 14.sp),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
