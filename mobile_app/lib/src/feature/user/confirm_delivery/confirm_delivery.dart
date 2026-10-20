import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_button.dart';
import 'package:deliver_mee/src/common/utils/dialog.dart';
import 'package:deliver_mee/src/common/utils/order_deliver_dialog.dart';
import 'package:deliver_mee/src/common/utils/rating_dialog.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/driver/driver_pick_up/dialogue/view_recepie_dialogue.dart';
import 'package:deliver_mee/src/feature/user/bottom_bar/pages/bottom_bar_page.dart';
import 'package:deliver_mee/src/feature/user/chat/chat.dart';
import 'package:deliver_mee/src/feature/user/confirm_delivery/controller.dart';
import 'package:deliver_mee/src/feature/user/view_on_map/view_on_map.dart';
import 'package:deliver_mee/src/common/services/pricing_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ConfirmDeliveryScreen extends StatelessWidget {
  ConfirmDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Section (fake map for demo)
          SafeArea(
            child: Container(
              height: 450.h,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AppImages.confirmdeliverymapimg),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              width: double.infinity,
              height: 450.h,
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
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
                    Row(
                      children: [
                        TextWidget(
                          text: 'Arrives in 20 mins',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        Spacer(),
                        TextWidget(
                          text: '\$28',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    buildPickupDetails(),
                    SizedBox(height: 10.h),
                    // First Row: Cancel & See on Map
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            buttonColor: AppColors.unSelectedPrimaryColor,
                            text: 'Cancel Delivery',
                            ontap: () {
                              Get.dialog(
                                ConfirmationDialog(
                                  buttontext: "Confirm",
                                  aspectRatio: 1 / 0.6,
                                  onYesBtnClick: () {
                                    Get.back();
                                    Get.offAll(UserBottomBarPage(),
                                        transition: Transition.cupertino);
                                  },
                                  subDescription:
                                      "Once you cancel delivery you won't be able to redo it.",
                                  heading: "Are You Sure?",
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: CustomButton(
                            text: 'See on Map',
                            ontap: () {
                              Get.to(ViewOnMapScreen(),
                                  transition: Transition.cupertino);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    // Second Row: Complete Delivery (full width)
                    CustomButton(
                      text: 'Complete Delivery',
                      ontap: () {
                        Get.dialog(
                          OrderDeliverDialog(
                            onYesBtnClick: () {
                              Get.back();
                              Get.dialog(
                                RatingDialog(
                                  onYesBtnClick: () {
                                    Get.back();
                                    final pricingService = Get.find<PricingService>();
                                    Get.dialog(viewReceiptDialogue(
                                      price: '\$${pricingService.totalFare.value.toStringAsFixed(2)}',
                                      onTap: () {
                                        Get.back();
                                        Get.offAll(UserBottomBarPage(),
                                            transition: Transition.cupertino);
                                      },
                                    ));
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 35.h,
                        width: 35.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xffC9C9C9),
                          ),
                        ),
                        child:
                            const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _summaryBox(String label, String value) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            TextWidget(
                text: "${label} ${value}",
                fontWeight: FontWeight.w400,
                fontSize: 14.sp),
          ],
        ),
      ),
    );
  }

  Widget buildPickupDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10.h),
        StepProgressBar(),
        SizedBox(height: 10.h),
        Row(
          children: [
            _summaryBox("Total Item", "2"),
            _summaryBox("Small", "12"),
            _summaryBox("5.5", "LB"),
          ],
        ),
        SizedBox(height: 15.h),

        // Driver Card
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Row(
            children: [
              // Driver Image
              CircleAvatar(
                radius: 24.r,
                backgroundImage: AssetImage(AppImages.driverimg),
              ),
              SizedBox(width: 12.w),
              // Driver Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: "David Moore",
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  TextWidget(
                    text: "Maxus T60\nPickup Truck",
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ],
              ),
              Spacer(),
              // Chat & Call Icons
              GestureDetector(
                onTap: () {
                  Get.to(ChatScreen(), transition: Transition.cupertino);
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: SvgPicture.asset(AppIcons.messageIcon),
                ),
              ),
              SizedBox(width: 10.w),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: SvgPicture.asset(AppIcons.callIcon),
              ),
            ],
          ),
        ),

        SizedBox(height: 15.h),

        // Pickup Notes Input
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Any pickup notes",
              hintStyle: TextStyle(
                color: AppColors.hintTextColor,
                fontSize: 14.sp,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class StepProgressBar extends StatelessWidget {
  final controller = Get.find<ConfirmDeliveryController>();

  final List<String> assets = [
    AppIcons.oneIcon,
    AppIcons.twoIcon,
    AppIcons.threeIcon,
    AppIcons.fourIcon,
  ];

  StepProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.h,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // BASE LINE
          Positioned(
            left: 40.w,
            right: 40.w,
            child: Container(
              height: 2.h,
              color: Colors.grey.shade300,
            ),
          ),
          // ANIMATED BLACK LINE
          Positioned(
            left: 40.w,
            right: 40.w,
            child: AnimatedBuilder(
              animation: controller.animationController,
              builder: (_, __) {
                return FractionallySizedBox(
                  widthFactor: controller.progressAnimation.value,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 2.h,
                    color: Colors.black,
                  ),
                );
              },
            ),
          ),
          // STEP ICONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              return Obx(() {
                bool isActive = controller.currentStep.value >= index;
                return GestureDetector(
                  onTap: () {
                    controller.currentStep.value = index;
                    controller.animateToStep(index);
                    if (index == 3) {
                      Get.dialog(
                        OrderDeliverDialog(
                          onYesBtnClick: () {
                            Get.back();
                            Get.dialog(
                              RatingDialog(
                                onYesBtnClick: () {
                                  Get.back();
                                  final pricingService = Get.find<PricingService>();
                                  Get.dialog(viewReceiptDialogue(
                                    price: '\$${pricingService.totalFare.value.toStringAsFixed(2)}',
                                    onTap: () {
                                      Get.back();
                                    },
                                  ));
                                },
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 35.h,
                    width: 35.w,
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? Colors.black : Colors.white,
                      border: Border.all(
                        color: isActive ? Colors.black : Colors.grey.shade400,
                        width: 1,
                      ),
                    ),
                    child: SvgPicture.asset(
                      assets[index],
                      colorFilter: ColorFilter.mode(
                        isActive ? Colors.white : Colors.grey,
                        BlendMode.srcIn,
                      ),
                      height: 25.h,
                      width: 25.w,
                    ),
                  ),
                );
              });
            }),
          ),
        ],
      ),
    );
  }
}
