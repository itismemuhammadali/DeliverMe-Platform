import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/common/widgets/live_map_widget.dart';
import 'package:deliver_mee/src/feature/user/car_selection/car_selection.dart';
import 'package:deliver_mee/src/feature/user/home/controller/controller.dart';
import 'package:deliver_mee/src/feature/user/search/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserHomeScreen extends StatelessWidget {
  UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController ctrl = Get.find<HomeController>();
    return Scaffold(
      body: Stack(
        children: [
          // Live Map Section
          Container(
            height: 450.h,
            width: double.infinity,
            child: Stack(
              children: [
                // Live Map Widget
                LiveMapWidget(
                  height: 450.h,
                  showSearchButton: false,
                  onLocationSelected: (LatLng location) {
                    // Handle location selection
                    print(
                        'Selected location: ${location.latitude}, ${location.longitude}');
                  },
                ),
              ],
            ),
          ),

          // Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: FloatingActionButton(
                    backgroundColor: AppColors.whiteColor,
                    shape: CircleBorder(),
                    onPressed: () {},
                    child: SvgPicture.asset(
                      AppIcons.currentlocationIcon,
                      width: 30.w,
                      height: 30.h,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  width: double.infinity,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                    minHeight: 400.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: Offset(0, -4),
                        blurRadius: 10.r,
                        spreadRadius: 2.r,
                      ),
                    ],
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16.r)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 57.w,
                            height: 5.h,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        TextWidget(
                          text: 'Start the Delivery',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: 8.h),
                        TextWidget(
                          text:
                              'Select pickup and dropoff locations to continue',
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                        SizedBox(height: 16.h),
                        locationCard(ctrl: ctrl),
                        SizedBox(height: 20.h),
                        // Select a Service button
                        SizedBox(
                          width: double.infinity,
                          height: 48.h,
                          child: Material(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(8.r),
                            child: InkWell(
                              onTap: () {
                                // Validate locations before navigating
                                if (ctrl.fromlocation.value.isEmpty ||
                                    ctrl.tolocation.value.isEmpty) {
                                  String missingLocation = '';
                                  if (ctrl.fromlocation.value.isEmpty &&
                                      ctrl.tolocation.value.isEmpty) {
                                    missingLocation =
                                        'both pickup and dropoff locations';
                                  } else if (ctrl.fromlocation.value.isEmpty) {
                                    missingLocation = 'pickup location';
                                  } else {
                                    missingLocation = 'dropoff location';
                                  }

                                  Get.snackbar(
                                    'Location Required',
                                    'Please select $missingLocation to continue',
                                    backgroundColor: Colors.orange,
                                    colorText: Colors.white,
                                    duration: Duration(seconds: 4),
                                    icon: Icon(Icons.location_on,
                                        color: Colors.white),
                                    snackPosition: SnackPosition.TOP,
                                  );
                                  return;
                                }

                                // Navigate to car selection screen
                                Get.to(
                                  () => CarSelectionScreen(
                                    model: ctrl.carslist[0],
                                  ),
                                  transition: Transition.cupertino,
                                );
                              },
                              borderRadius: BorderRadius.circular(8.r),
                              child: Center(
                                child: TextWidget(
                                  text: 'Select a Service',
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget locationCard({required HomeController ctrl}) {
    return Obx(() => Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: (ctrl.fromlocation.value.isNotEmpty &&
                      ctrl.tolocation.value.isNotEmpty)
                  ? AppColors.primaryColor.withValues(alpha: 0.3)
                  : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // From location
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.to(
                        () => SearchScreen(
                              location: ctrl.fromlocation.value,
                              tolocation: false,
                            ),
                        transition: Transition.cupertino);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: ctrl.fromlocation.value.isNotEmpty
                                  ? AppColors.primaryColor
                                  : Colors.grey,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            TextWidget(
                              text: 'From',
                              fontSize: 12.sp,
                              color: ctrl.fromlocation.value.isNotEmpty
                                  ? AppColors.primaryColor
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                            if (ctrl.fromlocation.value.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(left: 4.w),
                                child: Icon(
                                  Icons.check_circle,
                                  color: AppColors.primaryColor,
                                  size: 14.sp,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        TextWidget(
                          text: ctrl.fromlocation.value.isNotEmpty
                              ? ctrl.fromlocation.value
                              : 'Select pickup location',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: ctrl.fromlocation.value.isNotEmpty
                              ? Colors.black
                              : Colors.grey,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              // Swap button in the middle with dotted divider
              Stack(
                alignment: Alignment.center,
                children: [
                  // Dotted divider line
                  Row(
                    children: [
                      Expanded(
                        child: CustomPaint(
                          painter: DottedLinePainter(
                            color: (ctrl.fromlocation.value.isNotEmpty &&
                                    ctrl.tolocation.value.isNotEmpty)
                                ? AppColors.primaryColor.withValues(alpha: 0.3)
                                : Colors.grey.shade300,
                            strokeWidth: 1.5,
                          ),
                          size: Size(double.infinity, 1.h),
                        ),
                      ),
                    ],
                  ),
                  // Swap button
                  Material(
                    color: const Color(0xFFF8F8F8),
                    shape: CircleBorder(),
                    child: InkWell(
                      onTap: () {
                        // Swap the locations
                        final temp = ctrl.fromlocation.value;
                        ctrl.fromlocation.value = ctrl.tolocation.value;
                        ctrl.tolocation.value = temp;
                      },
                      customBorder: CircleBorder(),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.swap_vert,
                          color: AppColors.primaryColor,
                          size: 16.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              // To location
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Get.to(
                        () => SearchScreen(
                              location: ctrl.tolocation.value,
                              tolocation: true,
                            ),
                        transition: Transition.cupertino);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: ctrl.tolocation.value.isNotEmpty
                                  ? AppColors.primaryColor
                                  : Colors.grey,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            TextWidget(
                              text: 'To',
                              fontSize: 12.sp,
                              color: ctrl.tolocation.value.isNotEmpty
                                  ? AppColors.primaryColor
                                  : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                            if (ctrl.tolocation.value.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(left: 4.w),
                                child: Icon(
                                  Icons.check_circle,
                                  color: AppColors.primaryColor,
                                  size: 14.sp,
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        TextWidget(
                          text: ctrl.tolocation.value.isNotEmpty
                              ? ctrl.tolocation.value
                              : 'Select dropoff location',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: ctrl.tolocation.value.isNotEmpty
                              ? Colors.black
                              : Colors.grey,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

/// Custom painter for drawing dotted lines
class DottedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DottedLinePainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 4.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DottedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}

