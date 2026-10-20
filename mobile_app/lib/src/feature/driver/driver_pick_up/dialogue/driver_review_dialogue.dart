import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_button.dart';
import 'package:deliver_mee/src/common/utils/dialog.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/driver/driver_pick_up/controller/driver_pick_up_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Widget driverRatingReviewDialogue({
  required DriverPickUpController ctrl,
  required void Function() ontap,
  required void Function() receiptOnTap,
}) {
  return Center(
    child: ConfirmationDialog(
      isButtonShow: true,
      onYesBtnClick: receiptOnTap,
      subDescription: 'Review Delivery',
      aspectRatio: 0.52,
      heading: 'Review Delivery',
      centerWidget: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          children: [
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
              text: "Your feedback will help improve your\nexperience",
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Obx(() {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                    5,
                    (index) => IconButton(
                          icon: Icon(
                            Icons.star,
                            color: index < ctrl.ratingIndex.value
                                ? Color(0xff007E28)
                                : Colors.grey.shade300,
                            size: 30.sp,
                          ),
                          onPressed: () {
                            ctrl.updateRatingIndex(
                              index + 1,
                            );
                          },
                        )),
              );
            }),
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: const Color(0xFFF4F4F4),
              ),
              child: TextField(
                maxLines: 4,
                onChanged: (val) {},
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
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'View Receipt',
                    fontSize: 13.sp,
                    buttonColor: AppColors.unSelectedPrimaryColor,
                    ontap: receiptOnTap,
                  ),
                ),
                SizedBox(
                  width: 15.w,
                ),
                Expanded(
                  child: CustomButton(
                    fontSize: 13.sp,
                    text: 'Submit',
                    ontap: ontap,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    ),

    // child: CustomContainer(
    //   padding: EdgeInsets.all(15.h),
    //   margin: EdgeInsets.all(20.h),
    //   color: AppColors.whiteColor,
    //   borderRadius: 20.r,
    //   child: Material(
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: [
    //         Padding(
    //           padding: EdgeInsets.only(right: 10.w),
    //           child: Align(
    //               alignment: Alignment.topRight,
    //               child: GestureDetector(
    //                 onTap: () {
    //                   Get.back();
    //                 },
    //                 child: Icon(
    //                   Icons.close,
    //                 ),
    //               )),
    //         ),
    //         SizedBox(
    //           height: 20.h,
    //         ),
    //         Center(
    //           child: TextWidget(
    //             text: "Review Delivery",
    //             fontSize: 24.sp,
    //             fontWeight: FontWeight.w500,
    //           ),
    //         ),
    //         SizedBox(
    //           height: 20.h,
    //         ),
    //         CircleAvatar(
    //           radius: 40.r,
    //           backgroundImage: AssetImage(AppImages.driverimg),
    //         ),
    //         SizedBox(height: 12.h),
    //         TextWidget(
    //           text: "Lucas Moore",
    //           fontSize: 15.sp,
    //           fontWeight: FontWeight.w600,
    //         ),
    //         SizedBox(height: 6.h),
    //         TextWidget(
    //           text: "Your feedback will help improve your\nexperience",
    //           fontSize: 14.sp,
    //           fontWeight: FontWeight.w400,
    //           color: Colors.grey,
    //           textAlign: TextAlign.center,
    //         ),
    //         SizedBox(height: 16.h),
    //         Obx(() {
    //           return Row(
    //             mainAxisSize: MainAxisSize.min,
    //             children: List.generate(
    //                 5,
    //                 (index) => IconButton(
    //                       icon: Icon(
    //                         Icons.star,
    //                         color: index < ctrl.ratingIndex.value
    //                             ? Color(0xff007E28)
    //                             : Colors.grey.shade300,
    //                         size: 30.sp,
    //                       ),
    //                       onPressed: () {
    //                         ctrl.updateRatingIndex(
    //                           index + 1,
    //                         );
    //                       },
    //                     )),
    //           );
    //         }),
    //         SizedBox(height: 20.h),
    //         Container(
    //           padding: EdgeInsets.all(12.r),
    //           decoration: BoxDecoration(
    //             borderRadius: BorderRadius.circular(12.r),
    //             color: const Color(0xFFF4F4F4),
    //           ),
    //           child: TextField(
    //             maxLines: 4,
    //             onChanged: (val) {},
    //             decoration: InputDecoration.collapsed(
    //               hintText: "Add Comment here",
    //               hintStyle: TextStyle(
    //                 color: AppColors.hintTextColor,
    //                 fontSize: 14.sp,
    //               ),
    //             ),
    //           ),
    //         ),
    //         SizedBox(height: 20.h),
    //         SizedBox(height: 20.h),
    //         Row(
    //           children: [
    //             Expanded(
    //               child: CustomButton(
    //                 text: 'View Receipt',
    //                 buttonColor: AppColors.unSelectedPrimaryColor,
    //                 ontap: receiptOnTap,
    //               ),
    //             ),
    //             SizedBox(
    //               width: 15.w,
    //             ),
    //             Expanded(
    //               child: CustomButton(
    //                 text: 'Submit',
    //                 ontap: ontap,
    //               ),
    //             )
    //           ],
    //         ),
    //       ],
    //     ),
    //   ),
    // ),
  );
}
