import 'package:ember_core/ember_core_frontend.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../styles/text_styles.dart';

Future<bool> showConfirmationDialog(CoreInquiry inquiry) async {
  if (inquiry.type != InquiryType.confirmation) {
    throw ArgumentError('Inquiry must be of type "confirmation"');
  }

  return await Get.dialog<bool>(
    AlertDialog(
      title: Text(inquiry.title),
      content: inquiry.content != null ? Text(inquiry.content!) : null,
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false), // Return false on cancel
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Get.back(result: true), // Return true on confirm
          child: Text('Confirm'),
        ),
      ],
    ),
  ) ?? false; // Return false if dialog is dismissed without an action
}