import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/custom_button.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

Widget loginButton({
  required void Function() ontap,
  required String text,
  required String image,
}) {
  return CustomButton(
    text: 'text',
    ontap: ontap,
    buttonColor: AppColors.whiteColor,
    height: 55.h,
    borderColor: AppColors.primaryColor.withValues(alpha: .16),
    centerWidget: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          image,
          height: text.contains('Google') ? 25.h : 22.h,
        ),
        SizedBox(
          width: 10.w,
        ),
        TextWidget(
          text: text,
          fontSize: 15.sp,
          color: Color(0xff555555),
        )
      ],
    ),
  );
}
