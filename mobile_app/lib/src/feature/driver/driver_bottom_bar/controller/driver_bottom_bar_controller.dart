import 'package:get/get.dart';

class DriverBottomBarController extends GetxController {
  static DriverBottomBarController get to =>
      Get.find<DriverBottomBarController>();

  RxInt selectedIndex = 0.obs;
  void setSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  RxBool isVisibility = false.obs;
  void setVisibility() {
    isVisibility.value = !isVisibility.value;
  }
}
