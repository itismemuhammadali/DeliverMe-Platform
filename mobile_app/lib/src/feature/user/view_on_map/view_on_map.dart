import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ViewOnMapScreen extends StatelessWidget {
  const ViewOnMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background map image
          SizedBox(
            height: 1.sh,
            width: 1.sw,
            child: Image.asset(
              AppImages.viewonmapimg,
              fit: BoxFit.cover,
            ),
          ),

          // Location top bar
          Positioned(
            top: 30.h,
            left: 20.w,
            right: 20.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else {
                      Get.back();
                    }
                  },
                  child: Container(
                    width: 45.w,
                    height: 45.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(child: Icon(Icons.arrow_back)),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.pinIcon,
                        height: 22.h,
                        width: 22.w,
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: TextWidget(
                          text: 'Building 8, 77 N Washington ST, Boston...',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
