
import 'dart:ui';

import 'package:ember_core/ember_core_debug.dart';

abstract class CoreFrontend {
  String get frontendName;
  String get frontendDescription;

  Future<bool> getConfirmation({
    required final String title,
    final String? message,
    final Map<String, List<String>>? foldedSubcontent,
  });

  void showToast({String? title, String? message, LogType logType});
}
