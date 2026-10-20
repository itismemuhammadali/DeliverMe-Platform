import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_container.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/user/bottom_bar/controller/bottom_bar_controller.dart';
import 'package:deliver_mee/src/feature/user/deliveries/deliveries.dart';
import 'package:deliver_mee/src/feature/user/home/page/home.dart';
import 'package:deliver_mee/src/feature/user/profile/profile/profile.dart';
import 'package:deliver_mee/src/feature/user/schedule/schedule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class UserBottomBarPage extends StatelessWidget {
  final List<String> inActiveIcon = [
    AppIcons.homeIcon,
    AppIcons.diliveriesIcon,
    AppIcons.clockIcon,
    AppIcons.profileIcon
  ];

  final List<Widget> pages = [
    UserHomeScreen(),
    DeliveriesScreen(),
    ScheduleScreen(),
    UserProfileScreen(),
  ];

  final List<String> activeIcon = [
    AppIcons.homeFill,
    AppIcons.diliveriesFillIcon,
    AppIcons.clockFillIcon,
    AppIcons.profileFillIcon
  ];
  final List<String> textList = ['Home', 'Deliveries', 'Scheduled', 'Profile'];

  UserBottomBarPage({super.key});

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: CustomContainer(
        height: 72.h,
        width: double.infinity,
        color: AppColors.primaryColor,
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (index) {
              return GestureDetector(
                onTap: () {
                  BottomBarController.to.setSelectedIndex(index);
                },
                child: bottombarWidget(
                  index: index,
                ),
              );
            }),
          ),
        ),
      ),
      body: Obx(() {
        return pages[BottomBarController.to.selectedIndex.value];
      }),
    );
  }

  Widget bottombarWidget({
    required int index,
  }) {
    bool isSelected = BottomBarController.to.selectedIndex == index;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          isSelected ? activeIcon[index] : inActiveIcon[index],
          height: 27.h,
        ),
        SizedBox(
          height: 5.h,
        ),
        TextWidget(
          text: textList[index],
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: isSelected
              ? AppColors.whiteColor
              : AppColors.unSelectedPrimaryColor,
        )
      ],
    );
  }
}
