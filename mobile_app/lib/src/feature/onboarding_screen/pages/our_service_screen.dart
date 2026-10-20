import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/auth/role_selected/role_selected_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OurServiceScreen extends StatelessWidget {
  const OurServiceScreen({super.key});

  IconData _getIconForService(int index) {
    final icons = [
      Icons.home_outlined,
      Icons.school_outlined,
      Icons.storage_outlined,
      Icons.business_outlined,
      Icons.chair_outlined,
      Icons.shopping_bag_outlined,
      Icons.local_offer_outlined,
      Icons.kitchen_outlined,
      Icons.delete_outline,
      Icons.volunteer_activism_outlined,
    ];
    return icons[index];
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colorsList = [
      const Color(0xffDBFFF6),
      const Color(0xffECE5FF),
      const Color(0xffFFF5DC),
      const Color(0xffF6FFE0),
      const Color(0xffFFF3E5),
      const Color(0xffE0E5FF),
      const Color(0xffF5E5FF),
      const Color(0xffFFFBD3),
      const Color(0xffE8FFE5),
      const Color(0xffFFEEE5),
    ];

    final List<String> textList = [
      'Home Delivery',
      'College Moving',
      'Storage Moving',
      'Office Moving',
      'Furniture Delivery',
      'Marketplace Delivery',
      'Kijiji Delivery',
      'Appliance Delivery',
      'Junk Removal',
      'Donation Pick Up'
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: 'Book a delivery for any moment',
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      TextWidget(
                        text: 'with ',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                      Image.asset(
                        AppImages.logoText,
                        height: 24.h,
                      )
                    ],
                  ),
                ],
              ),
            ),
            // Services Grid
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 10,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 1.2,
                  ),
                  itemBuilder: (context, index) => Container(
                    decoration: BoxDecoration(
                      color: colorsList[index],
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12.r,
                          spreadRadius: 1.r,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(16.r),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getIconForService(index),
                                size: 28.sp,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              child: TextWidget(
                                text: textList[index],
                                color: Colors.black87,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Continue Button
            Padding(
              padding: EdgeInsets.all(20.w),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: Material(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                  child: InkWell(
                    onTap: () {
                      Get.offAll(() => const RoleSelectedPage(),
                          transition: Transition.cupertino);
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Center(
                      child: TextWidget(
                        text: 'Continue',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
