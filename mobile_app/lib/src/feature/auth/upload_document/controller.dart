import 'package:get/get.dart';

class PaymentController extends GetxController {
  static PaymentController get to => Get.find<PaymentController>();

  RxBool ispaid = false.obs;
  RxBool ischecked = false.obs;
}
