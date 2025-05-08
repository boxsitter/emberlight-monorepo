import 'dart:math';

import 'package:bess_ui/src/common/constants/sizes.dart';
import 'package:bess_ui/src/common/utils/helpers/helper_functions.dart';
import 'package:ember_core/ember_core_debug.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../constants/colors.dart';
import '../styles/text_styles.dart';

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
    LogType? logType
  }){
    final sonner = ShadSonner.of(Get.context!);
    final id = Random().nextInt(1000);
    final Color? color;
    switch(logType) {
      case LogType.success:
        color = BessColors.success;
        break;
      case LogType.error:
        color = BessColors.error;
        break;
      case LogType.warning:
        color = BessColors.warning;
        break;
      case LogType.critical:
        color = BessColors.error;
        break;
      case LogType.unknownError:
        color = BessColors.error;
        break;
      case LogType.failure:
        color = BessColors.warning;
        break;
      default:
        color = null;
    }

    sonner.show(
      ShadToast(
        showCloseIconOnlyWhenHovered: false,
        duration: logType?.toastDuration ?? const Duration(milliseconds: 2500),
        id: id,
        title: title != null ? Text(title) : null,
        description: message != null ?
          Column(
            children: [
              SizedBox(height: 6),

              Text(message),
            ],
          )
            : null,
        action: action,
        padding: EdgeInsets.fromLTRB(24, 24, 32, 24),
        radius: BorderRadius.circular(BessSizes.cardRadiusMd),
        backgroundColor: color != null ? BessHelperFunctions.blendColors(color, BessColors.core, 225) : BessColors.core,
        border: Border.all(width: 2, color: color != null ? color : BessColors.borderPrimary),
        titleStyle: BessTextStyles.tableHeader.copyWith(fontSize: 16),
        descriptionStyle:  BessTextStyles.standard,
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
