import 'dart:math';

import 'package:ember_core/ember_core_frontend.dart';
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
        title: title != null ? Text(title ?? '') : null,
        description: description != null ? Text(description) : null,
        actions: actions ?? [],
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 200),
    ) ??
    false;
  }

  void showToast({
    String? title,
    String? description,
    Widget? action,
  }){
    final sonner = ShadSonner.of(Get.context!);
    final id = Random().nextInt(1000);
    sonner.show(
      ShadToast(
        showCloseIconOnlyWhenHovered: false,
        duration: const Duration(milliseconds: 2000),
        id: id,
        title: title != null ? Text(title ?? '') : null,
        description: description != null ? Text(description) : null,
        action: action,
      ),
    );
  }

  // Future<bool> showGetToast({
  //   String? title,
  //   String? description,
  //   List<Widget>? actions,
  //   Widget? child,
  // }) async {
  //   return await Get.toa
  // }


}
