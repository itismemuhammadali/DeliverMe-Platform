

import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ChatController extends GetxController {
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final TextEditingController messageController = TextEditingController();

  void sendMessage(String text) {
    if (text.trim().isNotEmpty) {
      messages.add({"isMe": true, "text": text.trim()});
      messageController.clear();

      // Simulate reply
      Future.delayed(Duration(seconds: 1), () {
        messages.add({"isMe": false, "text": "Okay I'm waiting 👍"});
      });
    }
  }
}