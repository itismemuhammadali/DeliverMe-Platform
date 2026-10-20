import 'package:deliver_mee/src/feature/onboarding_screen/pages/our_service_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingController extends GetxController {
  static OnBoardingController get to => Get.find<OnBoardingController>();

  RxDouble currentProgress = 0.5.obs;
  RxInt tapCount = 0.obs;
  PageController pageController = PageController();

  void handleTap(BuildContext context) {
    tapCount.value = (tapCount.value + 1) % 3;

    // log(tapCount.value);

    if (tapCount.value == 0) {
      currentProgress.value = 0.5;
    } else if (tapCount.value == 1) {
      currentProgress.value = 1.0;
      pageController.animateToPage(1,
          duration: Duration(milliseconds: 300), curve: Curves.linear);
    } else if (tapCount.value == 2) {
      Get.offAll(OurServiceScreen(), transition: Transition.cupertino);
      tapCount.value = 1;
    }
    update(['updateIndicator']);
  }

  RxBool chechBoxBool = false.obs;
}
