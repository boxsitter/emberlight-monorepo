library;

import 'package:bess_ui/src/bessie_flutter_app.dart';
import 'package:bess_ui/src/common/routes/navigation_observer.dart';
import 'package:bess_ui/src/common/services/popup_service.dart';
import 'package:bess_ui/src/common/widgets/layouts/sidebars/sidebar_controller.dart';
import 'package:bess_ui/src/pages/activity_preferences/controllers/activity_preferences_controller.dart';
import 'package:bess_ui/src/pages/authentication/authentication_controller.dart';
import 'package:bess_ui/src/pages/console/controller/console_controller.dart';
import 'package:bess_ui/src/pages/rosters/controllers/roster_table_controller.dart';
import 'package:bess_ui/src/pages/schedule/schedule_page_controller.dart';
import 'package:bess_ui/src/pages/session_manager/session_manager_controller.dart';
import 'package:ember_cli_utils/src/io/io_interfaces.dart';
import 'package:ember_core/ember_core_frontend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

const _frontendName = 'Bessie';
const _frontendDescription = 'Cross-platform app interface for managing summer camp logistics with EmberCore';

class BessUi implements CoreFrontend{
  @override
  void init() {
    Get.put(PopupService(), permanent: true);
    Get.put(AuthenticationController(), permanent: true);
  }

  @override
  void onLogin() {
    Get.lazyPut(() => ConsoleController(), fenix: true);
    Get.lazyPut(() => SidebarController(), fenix: true);
    Get.lazyPut(() => SessionManagerController(), fenix: true);
    Get.lazyPut(() => ActivityPreferencesController(), fenix: true);
    Get.lazyPut(() => SchedulePageController(), fenix: true);
  }

  @override
  void onNewContext() {
    Get.delete<ConsoleController>();
    Get.delete<SidebarController>();
    Get.delete<RosterTableController>();
    Get.delete<SessionManagerController>();
    Get.delete<ActivityPreferencesController>();
    Get.delete<SchedulePageController>();
  }

  static void launchFlutterApp() {
    Get.put(BessNavigationObserver(), permanent: true);
    runApp(const BessieFlutterApp());
  }

  @override
  String get frontendName => _frontendName;

  @override
  String get frontendDescription => _frontendDescription;

  @override
  void showToast({String? title, String? message, LogType? logType}) {
    final PopupService popupService = Get.find<PopupService>();
    popupService.showToast(title: title, message: message, logType: logType);
  }

  @override
  Future<bool> getConfirmation({required String title, String? message, Map<String, List<String>>? foldedSubcontent}) {
    final PopupService popupService = Get.find<PopupService>();
    return popupService.showConfirmationDialog(title: title, message: message);
  }

  @override
  UserInput getUserInputImplementation() {
    return Get.find<ConsoleController>();
  }

  @override
  UserOutput getUserOutputImplementation() {
    return Get.find<ConsoleController>();
  }


}
