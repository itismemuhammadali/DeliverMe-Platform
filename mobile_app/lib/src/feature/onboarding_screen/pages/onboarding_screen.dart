import 'package:deliver_mee/src/common/constant/app_colors.dart';
import 'package:deliver_mee/src/common/constant/app_images.dart';
import 'package:deliver_mee/src/common/utils/custom_container.dart';
import 'package:deliver_mee/src/common/utils/text_widget.dart';
import 'package:deliver_mee/src/feature/onboarding_screen/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 120,
          ),
          Expanded(
              child: PageView(
            controller: OnBoardingController.to.pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              SingleChildScrollView(
                child: Center(
                  child: CustomContainer(
                    color: AppColors.whiteColor,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                            child: Image.asset(
                              AppImages.onboardingThree,
                              height: 200.h,
                            ),
                          ),
                          SizedBox(
                            height: 30.h,
                          ),
                          Center(
                            child: TextWidget(
                              text: 'Book a delivery from anywhere, anytime.',
                              fontSize: 28.sp,
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Center(
                            child: TextWidget(
                              text:
                                  'Request a delivery in just a few taps, no matter\nwhere you are.',
                              fontSize: 14.sp,
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Center(
                  child: CustomContainer(
                    color: AppColors.whiteColor,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            AppImages.onboardingTwo,
                            height: 239.h,
                          ),
                          SizedBox(
                            height: 30.h,
                          ),
                          Center(
                            child: TextWidget(
                              text: 'Seamless tracking for a smoother delivery.',
                              fontSize: 28.sp,
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Center(
                            child: TextWidget(
                              text:
                                  'Accurate location services ensure a hassle-free\npickup and drop-off.',
                              fontSize: 14.sp,
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(2, (index) {
              return Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Obx(() {
                  return Container(
                    height: 6.h,
                    width: 6.w,
                    decoration: BoxDecoration(
                        color: OnBoardingController.to.tapCount.value == index
                            ? AppColors.primaryColor
                            : AppColors.unSelectedPrimaryColor,
                        borderRadius: BorderRadius.circular(100)),
                  );
                }),
              );
            }),
          ),
          SizedBox(
            height: 40,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scaleX: 2,
                scaleY: 2,
                child: CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 3,
                  color: AppColors.unSelectedPrimaryColor,
                ),
              ),
              Obx(() {
                return Transform.scale(
                  scaleX: 2,
                  scaleY: 2,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.primaryColor,
                    value: OnBoardingController.to.currentProgress.value,
                  ),
                );
              }),
              Transform.scale(
                  scaleX: 1.3,
                  scaleY: 1.3,
                  child: CustomContainer(
                    onTap: () {
                      OnBoardingController.to.handleTap(context);
                    },
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppColors.whiteColor,
                    ),
                    height: 40,
                    width: 40,
                    color: AppColors.primaryColor,
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(0, 2),
                          blurRadius: 8,
                          color: AppColors.blackColor.withValues(alpha: .1))
                    ],
                    borderColor: AppColors.primaryColor,
                    borderRadius: 100000,
                  ))
            ],
          ),
          SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }
}
