import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/utils/dialog.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget viewReceiptDialogue({
  required void Function() onTap,
  String? price,
  String? refNumber,
  String? paymentTime,
  String? paymentMethod,
  String? senderName,
}) {
  return ConfirmationDialog(
      aspectRatio: 0.9,
      onYesBtnClick: onTap,
      subDescription: '',
      centerWidget: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 30.r,
                backgroundColor: AppColors.greenColor.withValues(alpha: .15),
                child: CircleAvatar(
                  radius: 15.r,
                  backgroundColor: AppColors.greenColor,
                  child: Icon(
                    Icons.check_sharp,
                    color: AppColors.whiteColor,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            Center(
              child: TextWidget(
                text: price ?? '\$30.00',
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(
              height: 15.h,
            ),
            recipeRowTextWidget(
                leftText: 'Ref Number', rightText: refNumber ?? '000085752257'),
            SizedBox(
              height: 10.h,
            ),
            recipeRowTextWidget(
                leftText: 'Payment Time',
                rightText: paymentTime ?? '25-02-2023, 13:22:16'),
            SizedBox(
              height: 10.h,
            ),
            recipeRowTextWidget(
                leftText: 'Payment Method', rightText: paymentMethod ?? 'Stripe'),
            SizedBox(
              height: 10.h,
            ),
            recipeRowTextWidget(
                leftText: 'Sender Name', rightText: senderName ?? 'Antonio Roberto'),
            SizedBox(
              height: 10.h,
            ),
          ],
        ),
      ),
      buttontext: 'Send to email',
      heading: 'Delivery Receipt');
}

Widget recipeRowTextWidget(
    {required String leftText, required String rightText}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      TextWidget(
        text: leftText,
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: AppColors.greyTextColor,
      ),
      TextWidget(
        text: rightText,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.blackColor,
      )
    ],
  );
}
