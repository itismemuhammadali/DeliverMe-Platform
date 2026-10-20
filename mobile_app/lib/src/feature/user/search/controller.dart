
import 'package:get/get.dart';

class ZoomController extends GetxController {
  double scale = 1.0;

  void zoomIn() {
    scale += 0.1;
    update();
  }

  void zoomOut() {
    if (scale > 1) {
      scale -= 0.1;
      update();
    }
  }
}