import 'package:bess_ui/src/common/routes/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../pages/activity_preferences/controllers/activity_preferences_controller.dart';
import '../../pages/rosters/controllers/rosters_controller.dart';
import '../../pages/session_manager/session_manager_controller.dart';
import '../mixins/route_aware_controller_mixin.dart';
import '../widgets/layouts/sidebars/sidebar_controller.dart';

// Change the superclass from GetObserver to NavigatorObserver
class BessNavigationObserver extends NavigatorObserver {

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _handleNavigation(route.settings.name, previousRoute?.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _handleNavigation(previousRoute?.settings.name, route.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _handleNavigation(newRoute?.settings.name, oldRoute?.settings.name);
  }

  void _handleNavigation(String? to, String? from) {
    if (to == null) return;

    // Notify the controller of the page we are LEAVING
    final fromController = BessRoutes.getControllerForRoute(from);
    if (fromController != null) {
      fromController.onNavigateFrom(from!, to);
    }

    // Notify the controller of the page we are ENTERING
    final toController = BessRoutes.getControllerForRoute(to);
    if (toController != null) {
      toController.onNavigateTo(to, from);
  }

    // Update the sidebar's active item
    if (Get.isRegistered<SidebarController>()) {
      Get.find<SidebarController>().changeActiveItem(to);
    }
  }
}