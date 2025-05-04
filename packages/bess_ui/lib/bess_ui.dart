library;

import 'package:bess_ui/src/bessie_flutter_app.dart';
import 'package:bess_ui/src/common/services/popup_service.dart';
import 'package:bess_ui/src/common/widgets/layouts/sidebars/sidebar_controller.dart';
import 'package:bess_ui/src/common/widgets/roster_table/controllers/roster_table_controller.dart';
import 'package:bess_ui/src/pages/activity_preferences/controllers/activity_preferences_controller.dart';
import 'package:bess_ui/src/pages/console/controller/console_controller.dart';
import 'package:bess_ui/src/pages/schedule/schedule_page_controller.dart';
import 'package:bess_ui/src/pages/session_manager/session_manager_controller.dart';
import 'package:ember_core/ember_core_frontend.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

const _frontendName = 'Bessie';
const _frontendDescription = 'Cross-platform app interface for managing summer camp logistics with EmberCore';

class BessUi implements CoreFrontend{
  static void initEarly() {
    Get.put(PopupService(), permanent: true);
  }

  static void init() {
    Get.put(ConsoleController(), permanent: true);
    Get.put(SidebarController(), permanent: true);
    Get.put(RosterTableController(), permanent: true);
    Get.put(SessionManagerController(), permanent: true);
    Get.put(ActivityPreferencesController(), permanent: true);
    Get.put(SchedulePageController(), permanent: true);
  }

  static void launchFlutterApp() {
    runApp(const BessieFlutterApp());
  }

  @override
  String get frontendName => _frontendName;

  @override
  String get frontendDescription => _frontendDescription;

  @override
  void displayError({String? title, String? message}) {
    final PopupService popupService = Get.find<PopupService>();
    popupService.showToast(title: title, message: message); // TODO: Make a separate toast design for errors
  }

  @override
  void displayInfo({String? title, String? message}) {
    final PopupService popupService = Get.find<PopupService>();
    popupService.showToast(title: title, message: message);
  }

  @override
  Future<bool> getConfirmation({required String title, String? message, Map<String, List<String>>? foldedSubcontent}) {
    final PopupService popupService = Get.find<PopupService>();
    return popupService.showConfirmationDialog(title: title, message: message);
  }
}
