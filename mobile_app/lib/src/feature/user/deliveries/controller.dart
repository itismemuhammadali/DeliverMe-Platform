import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DeliveresController extends GetxController {
  static DeliveresController get to => Get.find<DeliveresController>();
  TextEditingController timeController = TextEditingController();
  RxString date = ''.obs;

  Future<void> pickDateTime(BuildContext context) async {
    // Pick Date
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        String formattedDate =
            DateFormat('dd  MMMM, yyyy').format(selectedDate);
        date.value = formattedDate;

        String formattedTime = selectedTime.format(context);
        timeController.text = formattedTime;
      }

      date.value = '${date.value} ${timeController.text} ';
    }
  }

  Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);

  void setTime(TimeOfDay time) {
    selectedTime.value = time;
  }

  Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  void setDate(DateTime date) {
    selectedDate.value = date;
  }
}
