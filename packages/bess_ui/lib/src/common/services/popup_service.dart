import 'dart:math';

import 'package:ember_core/ember_core_frontend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PopupService extends GetxService {

  Future<bool> showFullScreenDialog({
    String? title,
    String? description,
    List<Widget>? actions,
    Widget? child,
  }) async {
    return await Get.dialog<bool>(
      ShadDialog(
        title: title != null ? Text(title) : null,
        description: description != null ? Text(description) : null,
        actions: actions ?? [],
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 200),
    ) ??
    false;
  }

  Future<bool> showConfirmationDialog({
    String? title,
    String? message,
  }) async {
    return await showFullScreenDialog(
      title: title,
      description: message,
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
      child: null,
    );
  }

  void showToast({
    String? title,
    String? message,
    Widget? action,
  }){
    final sonner = ShadSonner.of(Get.context!);
    final id = Random().nextInt(1000);
    sonner.show(
      ShadToast(
        showCloseIconOnlyWhenHovered: false,
        duration: const Duration(milliseconds: 2000),
        id: id,
        title: title != null ? Text(title) : null,
        description: message != null ? Text(message) : null,
        action: action,
      ),
    );
  }

  Future<bool> showActivityInfo(PrincipalActivity activity) async {
    return await showFullScreenDialog(
      title: activity.name,
      description: activity.description,
    );
  }


}
