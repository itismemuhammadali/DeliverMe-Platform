import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_button.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class DriverRequestCardWidget extends StatelessWidget {
  final String userInitials;
  final String? customerName;
  final String addressOne;
  final String addressTwo;
  final String? requestedAt;
  final String? scheduledDate;
  final String? timeSlot;
  final String price;
  final String itemName;
  final String lbCount;
  final String boxImagae;

  final void Function()? rejectOnTap;
  final void Function()? acceptOnTap;
  final void Function(BuildContext)? viewPhotoOnTap;

  const DriverRequestCardWidget(
      {super.key,
      required this.userInitials,
      this.customerName,
      required this.addressOne,
      required this.addressTwo,
      this.requestedAt,
      this.scheduledDate,
      this.timeSlot,
      required this.price,
      required this.itemName,
      required this.lbCount,
      required this.boxImagae,
      this.rejectOnTap,
      this.acceptOnTap,
      this.viewPhotoOnTap});

  bool get _isConfirmedBooking => scheduledDate != null && scheduledDate!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: Color(0xffecf0f1),
      child: Padding(
        padding: EdgeInsets.all(12.h),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryColor,
                  radius: 24,
                  child: Text(
                    userInitials,
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(AppIcons.markerIcon),
                          SizedBox(width: 4),
                          Expanded(
                            child: TextWidget(
                              text: addressOne,
                              fontSize: 10.sp,
                              color: AppColors.greyTextColor,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 22.w),
                          child: DottedLine(
                            dashColor: AppColors.greyTextColor,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(AppIcons.locationIcon),
                          SizedBox(width: 4),
                          Expanded(
                            child: TextWidget(
                              text: addressTwo,
                              fontSize: 10.sp,
                              color: AppColors.greyTextColor,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Show scheduled date and time slot only for confirmed bookings
                      if (_isConfirmedBooking) ...[
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14.sp,
                              color: AppColors.primaryColor,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: TextWidget(
                                text: 'Scheduled: $scheduledDate',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (timeSlot != null && timeSlot!.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14.sp,
                                color: AppColors.primaryColor,
                              ),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: TextWidget(
                                  text: 'Slot: $timeSlot',
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],

                    ],
                  ),
                ),
                SizedBox(width: 8),
                TextWidget(
                  text: '\$${price}',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyTextColor,
                ),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: TextWidget(
                    text: 'Name: $itemName',
                    fontSize: 12.sp,
                    color: AppColors.greyTextColor,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextWidget(
                  text: 'Weight: $lbCount LB',
                  fontSize: 12.sp,
                  color: AppColors.blackColor,
                ),
                GestureDetector(
                  onTap: () => viewPhotoOnTap?.call(context),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                    ),
                    child: TextWidget(
                      text: 'View Image',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor,
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Reject',
                    height: 40.h,
                    ontap: rejectOnTap ?? () {},
                    borderRadius: 8.r,
                    buttonColor: AppColors.redColor,
                  ),
                ),
                SizedBox(
                  width: 10.w,
                ),
                Expanded(
                  child: CustomButton(
                    borderRadius: 8.r,
                    height: 40.h,
                    text: 'Accept',
                    ontap: acceptOnTap ?? () {},
                  ),
                )
              ],
            ),
            SizedBox(
              height: 5.h,
            )
          ],
        ),
      ),
    );
  }
}
