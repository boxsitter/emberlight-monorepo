// Defines a custom route observer that updates the currently
// active sidebar menu item whenever navigation occurs. By listening
// to route push and pop events, it ensures the sidebar's highlighted
// item always reflects the current screen.

import 'package:bessie/common/routes/routes.dart';
import 'package:bessie/pages/activity_preferences/controllers/activity_preferences_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../widgets/layouts/sidebars/sidebar_controller.dart';
import '../widgets/roster_table/controllers/roster_table_controller.dart';

class RouteObservers extends GetObserver {
  // TODO: probably do everything through didChangeTop. It should hopefully fix the selected sidebar item bug
  @override
  void didPop(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    final sidebarController = Get.find<SidebarController>();

    if (previousRoute != null) {
      for (var routeName in BessRoutes.sideMenuItems) {
        if (previousRoute.settings.name == routeName) {
          sidebarController.activeItem.value = routeName;
        }
      }
    }
  }

  @override
  void didChangeTop(Route topRoute, Route? previousTopRoute) {
    RosterTableController rosterTableController = Get.find<RosterTableController>();
    if (topRoute.settings.name == BessRoutes.sessionRoster) {
      rosterTableController.startListening();
    } else {
      rosterTableController.stopListening();
    }

    ActivityPreferencesController activityPreferencesController = Get.find<ActivityPreferencesController>();
    if (topRoute.settings.name == BessRoutes.activityPreferencesCabins && previousTopRoute?.settings.name != BessRoutes.activityPreferencesCabins) {
      activityPreferencesController.populateCabinMaps();
    }
    if (topRoute.settings.name == BessRoutes.activityPreferencesCampers && previousTopRoute?.settings.name != BessRoutes.activityPreferencesCampers) {
      activityPreferencesController.populateCamperMaps();
    }
  }

  @override
  void didPush(Route<dynamic>? route, Route<dynamic>? previousRoute) {
    final sidebarController = Get.find<SidebarController>();

    if (route != null) {
      for (var routeName in BessRoutes.sideMenuItems) {
        if (route.settings.name == routeName) {
          sidebarController.activeItem.value = routeName;
        }
      }
    }
  }
}

