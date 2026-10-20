import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfirmDeliveryController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var currentStep = 0.obs;
   late AnimationController animationController;
  late Animation<double> progressAnimation;

  void initializeStep(int step) {
    currentStep.value = step;
    animateToStep(step);
  }

  @override
  void onInit() {
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController);
    super.onInit();
  }

  void nextStep() {
    if (currentStep.value < 5) {
      currentStep.value++;
      animateToStep(currentStep.value);
    }
  }

  void animateToStep(int step) {
    // 5 icons = 4 segments (0.0, 0.25, 0.5, 0.75, 1.0)
    // Step 0: All inactive (0.0)
    // Step 1: Arriving active (0.0)
    // Step 2: Arrived active (0.25)
    // Step 3: Picked Up active (0.50)
    // Step 4: Going to Deliver active (0.75)
    // Step 5: Completed active (1.0)
    
    double target = 0.0;
    if (step <= 1) {
      target = 0.0;
    } else if (step == 2) {
      target = 0.25;
    } else if (step == 3) {
      target = 0.50;
    } else if (step == 4) {
      target = 0.75;
    } else if (step >= 5) {
      target = 1.0;
    }
    
    animationController.animateTo(target);
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
