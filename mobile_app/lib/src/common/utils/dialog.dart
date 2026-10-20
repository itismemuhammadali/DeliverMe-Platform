import 'dart:ui';

import 'package:deliver_mee/src/common/utils/custom_button.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ConfirmationDialog extends StatefulWidget {
  final VoidCallback onYesBtnClick;
  final String subDescription;
  final double aspectRatio;
  final Widget? centerWidget;
  final String heading;
  final String? buttontext;
  final bool? isButtonShow;

  ConfirmationDialog(
      {Key? key,
      required this.onYesBtnClick,
      required this.subDescription,
      required this.aspectRatio,
      this.buttontext,
      required this.heading,
      this.centerWidget,
      this.isButtonShow = false})
      : super(key: key);

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog>
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
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: AspectRatio(
            aspectRatio: widget.aspectRatio,
            child: Column(
              children: [
                const Spacer(
                  flex: 1,
                ),
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
                TextWidget(
                  text: widget.heading,
                  color: ColorRes.darkGrey10,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                ),
                const Spacer(),
                widget.centerWidget ??
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      child: TextWidget(
                        text: widget.subDescription,
                        color: ColorRes.grey15,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        textAlign: TextAlign.center,
                      ),
                    ),
                const Spacer(),
                widget.isButtonShow == true
                    ? SizedBox()
                    : Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: CustomButton(
                            height: 45.h,
                            text: widget.buttontext ?? "OK",
                            ontap: widget.onYesBtnClick),
                      ),
                widget.isButtonShow == true
                    ? SizedBox()
                    : Spacer(
                        flex: 1,
                      ),
              ],
            ),
          ),
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

class ColorRes {
  static const Color darkGrey10 = Color(0xFF404040);
  static const Color grey15 = Color(0xFF737373);
}
