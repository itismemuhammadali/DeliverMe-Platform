import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String text;
  final VoidCallback? leadingOnTap;
  final VoidCallback? actionOnTap;
  final FontWeight? fontweight;
  final double? fontsize;
  final bool leading;

  final Widget? action;
  const CustomAppBar({
    super.key,
    required this.text,
    required this.leading,
    this.action,
    this.leadingOnTap,
    this.actionOnTap,
    this.fontweight,
    this.fontsize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 10.h,
        left: 16.w,
        right: 16.w,
      ),
      child: Row(
        children: [
          leading
              ? GestureDetector(
                  onTap: leadingOnTap ??
                      () {
                        Navigator.pop(context);
                      },
                  child: Container(
                    height: 40.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xffC9C9C9),
                      ),
                    ),
                    child: Icon(Icons.arrow_back_rounded, color: Colors.black),
                  ),
                )
              : SizedBox(
                  width: 30.w,
                ),
          const Spacer(),
          Center(
            child: TextWidget(
              text: text,
              fontSize: fontsize ?? 18.sp,
              fontWeight: fontweight ?? FontWeight.w400,
            ),
          ),
          const Spacer(),
          action ??
              SizedBox(
                width: 30.w,
              )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
