import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> showConfirmationDialog({
  required String title,
  required String message,
}) async {
  return await Get.dialog<bool>(
    AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false), // Return false on cancel
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true), // Return true on confirm
          child: const Text('Confirm'),
        ),
      ],
    ),
  ) ?? false; // Return false if dialog is dismissed without an action
}