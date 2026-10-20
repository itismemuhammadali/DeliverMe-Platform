import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

Widget authRightText({
  required String textOne,
  required String textTwo,
}) {
  return RichText(
      text: TextSpan(children: [
    TextSpan(
      text: textOne,
      style: GoogleFonts.roboto(
        fontSize: 14.sp,
        color: AppColors.richTextColor,
        fontWeight: FontWeight.w500,
      ),
    ),
    TextSpan(
      text: '  ${textTwo}',
      style: GoogleFonts.roboto(
        fontSize: 14.sp,
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w600,
      ),
    )
  ]));
}
