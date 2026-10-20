import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

void showSnackbar(String message) {
  Get.snackbar(
    "",
    "",
    titleText: const SizedBox.shrink(), // Removes extra space at the top
    messageText: Row(
      children: [
        const Icon(Icons.check_circle, color: Colors.white),
        SizedBox(
            width: 10
                .w), // Keep if using screenutil, otherwise replace with fixed width
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    ),
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.black87.withValues(alpha: .7),
    borderRadius: 8,
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    duration: const Duration(seconds: 3),
    isDismissible: true,
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeInBack,
  );
}
