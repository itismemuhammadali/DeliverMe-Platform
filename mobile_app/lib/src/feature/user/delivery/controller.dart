import 'package:get/get.dart';

class DeliverController extends GetxController {
  static DeliverController get to => Get.find<DeliverController>();

  var selectedDateIndex = 0.obs;
  var selectedTimeSlotIndex = 2.obs;
  var immediatePickup = false.obs;
  var scheduleDelivery = true.obs;
  var selectedPreference = 1.obs; 
  var deliveryNote = ''.obs;

  List<String> dates = [
    'Mon\n21',
    'Tues\n22',
    'Wed\n23',
    'Thur\n24',
    'Fri\n25'
  ];
  List<String> timeSlots = [
    '4:00am - 6:00am',
    '10:00am - 11:00pm',
    '1:00am - 2:00pm'
  ];

  double totalPayment = 28.0;
}
