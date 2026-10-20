import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/custom_container.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class StaticCardWidget extends StatelessWidget {
  final String icon;
  final Color iconContainerColor;
  final String title;
  final String subTitle;
  final VoidCallback? ontap;

  const StaticCardWidget(
      {super.key,
      required this.icon,
      required this.iconContainerColor,
      required this.title,
      required this.subTitle,
      this.ontap});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      onTap: ontap,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 15.w,
      ),
      borderRadius: 10.r,
      boxShadow: [
        BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 4,
            color: AppColors.blackColor.withValues(alpha: .25))
      ],
      color: Color(0xffecf0f1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 10.w,
          ),
          CustomContainer(
            height: 30.h,
            width: 26.w,
            color: iconContainerColor,
            borderRadius: 4.r,
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: SvgPicture.asset(icon),
            ),
          ),
          SizedBox(
            width: 10.w,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextWidget(
                text: title,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.naveBlue,
              ),
              SizedBox(
                height: 5,
              ),
              TextWidget(
                text: subTitle,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              )
            ],
          ),
        ],
      ),
    );
  }
}
