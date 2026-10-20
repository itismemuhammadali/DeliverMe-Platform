import 'dart:ui';

import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_button.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RatingController extends GetxController {
  RxInt rating = 3.obs;
  RxString comment = ''.obs;
  RxInt selectedTipIndex = (-1).obs;

  List<String> tips = [
    'Tip 10% (\$0.45)',
    'Tip 13% (\$2.99)',
    'Custom Tip',
    'No Tip'
  ];

  void setRating(int value) => rating.value = value;
  void setComment(String value) => comment.value = value;
  void selectTip(int index) => selectedTipIndex.value = index;
}

// dialog

class RatingDialog extends StatefulWidget {
  final bool? tipBool;
  final Widget? child;
  final Widget? lastButton;
  final VoidCallback onYesBtnClick;
  final String? topText;
  RatingDialog({
    Key? key,
    required this.onYesBtnClick,
    this.tipBool = true,
    this.lastButton,
    this.topText,
    this.child,
  }) : super(key: key);

  @override
  State<RatingDialog> createState() => _OrderDeliverDialogState();
}

class _OrderDeliverDialogState extends State<RatingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController animationcontroller;
  late Animation<double> scaleAnimation;
  final RatingController controller = Get.find<RatingController>();
  @override
  void initState() {
    super.initState();
    animationcontroller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    scaleAnimation = CurvedAnimation(
        parent: animationcontroller, curve: Curves.elasticInOut);
    animationcontroller.addListener(() {
      setState(() {});
    });
    animationcontroller.forward();
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
            constraints: BoxConstraints(maxHeight: Get.height * 0.8),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.child ?? Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                            text: widget.topText ?? "Review Delivery",
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        CircleAvatar(
                          radius: 40.r,
                          backgroundImage: AssetImage(AppImages.driverimg),
                        ),
                        SizedBox(height: 12.h),
                        TextWidget(
                          text: "Lucas Moore",
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 6.h),
                        TextWidget(
                          text: "Your feedback will help improve your experience",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) => _star(index)),
                        ),
                        SizedBox(height: 20.h),
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            color: const Color(0xFFF4F4F4),
                          ),
                          child: TextField(
                            maxLines: 4,
                            onChanged: controller.setComment,
                            decoration: InputDecoration.collapsed(
                              hintText: "Add Comment here",
                              hintStyle: TextStyle(
                                color: AppColors.hintTextColor,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        widget.tipBool == true
                            ? Obx(() => Wrap(
                                  spacing: 10.w,
                                  runSpacing: 10.h,
                                  alignment: WrapAlignment.center,
                                  children: List.generate(controller.tips.length,
                                      (index) {
                                    final isSelected =
                                        controller.selectedTipIndex.value ==
                                            index;
                                    final isNoTip =
                                        controller.tips[index] == 'No Tip';
                                    return GestureDetector(
                                      onTap: () => controller.selectTip(index),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.w, vertical: 10.h),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? (isNoTip
                                                  ? AppColors.redColor
                                                  : AppColors.brownColor)
                                              : Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                        ),
                                        child: TextWidget(
                                          text: controller.tips[index],
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    );
                                  }),
                                ))
                            : SizedBox(),
                      ],
                    ),
                  SizedBox(height: 20.h),
                  widget.lastButton ??
                      CustomButton(
                        text: 'Submit',
                        ontap: widget.onYesBtnClick,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationcontroller.dispose();
    super.dispose();
  }

  Widget _star(int index) {
    return Obx(() => IconButton(
          icon: Icon(
            Icons.star,
            color: index < controller.rating.value
                ? Color(0xff007E28)
                : Colors.grey.shade300,
            size: 30.sp,
          ),
          onPressed: () => controller.setRating(index + 1),
        ));
  }
}
