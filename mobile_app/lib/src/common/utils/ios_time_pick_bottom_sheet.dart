import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void iosTimePickerBottomSheet(
  BuildContext context, {
  required TimeOfDay initialTime,
  required Function(TimeOfDay pickedTime) onTimePicked,
}) {
  DateTime now = DateTime.now();
  DateTime initialDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    initialTime.hour,
    initialTime.minute,
  );

  DateTime tempPickedTime = initialDateTime;

  showModalBottomSheet(
    backgroundColor: const Color(0xff1c1c1e),
    context: context,
    builder: (_) {
      return SizedBox(
        height: 250,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.amber)),
                  ),
                  TextButton(
                    onPressed: () {
                      // Convert DateTime to TimeOfDay and return it
                      onTimePicked(TimeOfDay(
                        hour: tempPickedTime.hour,
                        minute: tempPickedTime.minute,
                      ));
                      Navigator.pop(context);
                    },
                    child: const Text('Save',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  brightness: Brightness.dark,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  primaryColor: Colors.amber,
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  backgroundColor: const Color(0xff1c1c1e),
                  initialDateTime: initialDateTime,
                  use24hFormat: false,
                  onDateTimeChanged: (DateTime newTime) {
                    tempPickedTime = newTime;
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

String formatTimeOfDay(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final period = time.period == DayPeriod.am ? "AM" : "PM";
  return "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period";
}

void iosDatePickerBottomSheet(
  BuildContext context, {
  required DateTime initialDate,
  required Function(DateTime pickedDate) onTimePicked,
}) {
  DateTime tempPickedDate = initialDate;

  showModalBottomSheet(
    backgroundColor: const Color(0xff1c1c1e),
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return Container(
        height: 300,
        padding: const EdgeInsets.only(top: 12),
        decoration: const BoxDecoration(
          color: Color(0xff1c1c1e),
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.amber)),
                  ),
                  TextButton(
                    onPressed: () {
                      onTimePicked(tempPickedDate);
                      Navigator.pop(context);
                    },
                    child: const Text('Save',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  brightness: Brightness.dark,
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  primaryColor: Colors.amber,
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  onDateTimeChanged: (DateTime newDate) {
                    tempPickedDate = newDate;
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
