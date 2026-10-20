import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({
    super.key,
    this.onTap,
    required this.text,
    this.color,
    this.fontFamily,
    this.fontSize,
    this.letterSpacing,
    this.fontWeight,
    this.underline,
    this.overflow,
    this.textShadow,
    this.textAlign,
    this.maxLines,
    this.decorationColor,
  });
  final String text;
  final Color? decorationColor;
  final VoidCallback? onTap;
  final Color? color;
  final String? fontFamily;
  final double? fontSize;
  final double? letterSpacing;
  final FontWeight? fontWeight;
  final TextDecoration? underline;
  final TextOverflow? overflow;
  final List<Shadow>? textShadow;
  final TextAlign? textAlign;
  final int? maxLines;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        style: GoogleFonts.roboto(
          decorationColor: decorationColor,
          color: color ?? AppColors.greyTextColor,
          fontWeight: fontWeight ?? FontWeight.w400,
          letterSpacing: letterSpacing ?? 0.1,
          fontSize: fontSize ?? 16.sp,
          decoration: underline ?? TextDecoration.none,
          shadows: textShadow,
        ),
        overflow: overflow,
      ),
    );
  }
}
