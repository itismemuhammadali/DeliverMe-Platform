import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DriverMapPage extends StatelessWidget {
  const DriverMapPage({super.key});

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
                    Get.back();
                  },
                  child: Image.asset(
                    AppImages.logo,
                    height: 50.h,
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
