
import 'dart:ui';

import 'package:ember_cli_utils/ember_cli_utils.dart';
import 'package:ember_core/ember_core_debug.dart';

import '../models/enums/log_type.dart';

abstract class CoreFrontend {
  String get frontendName;
  String get frontendDescription;

  void init();
  void onLogin();
  void onNewContext();

  Future<bool> getConfirmation({
    required final String title,
    final String? message,
    final Map<String, List<String>>? foldedSubcontent,
  });

  void showToast({String? title, String? message, LogType logType});

  UserOutput getUserOutputImplementation();
  UserInput getUserInputImplementation();
}
