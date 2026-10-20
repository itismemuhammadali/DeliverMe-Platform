import 'dart:developer';

import 'package:get/get.dart';

class BottomBarController extends GetxController {
  static BottomBarController get to => Get.find<BottomBarController>();

  RxInt selectedIndex = 0.obs;
  void setSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  RxBool isVisibility = false.obs;
  void setVisibility() {
    isVisibility.value = !isVisibility.value;
  }

  RxString copyText = ''.obs;
  RxString selectedText = ''.obs;

  void saveWeightText(String text) {
    selectedText.value = text;
  }

  RxInt textIndex = 3.obs;
  void selectSpecificText(String car, int index) {
    textIndex.value = index;
    copyText.value = car;

    log('--------${copyText.value}');

    update(['index']);
  }
}
