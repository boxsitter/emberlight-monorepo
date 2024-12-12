// // Defines a custom route observer that updates the currently
// // active sidebar menu item whenever navigation occurs. By listening
// // to route push and pop events, it ensures the sidebar's highlighted
// // item always reflects the current screen.
//
// import 'package:bessie/routes/routes.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/src/routes/observers/route_observer.dart';
//
// class RouteObservers extends GetObserver {
//
//   @override
//   void didPop(Route<dynamic>? route, Route<dynamic>? previousRoute) {
//     final sidebarController = Get.put(SidebarController());
//
//     if (previousRoute != null) {
//       // Check the route name and update the active item in the sidebar accordingly
//       for (var routeName in BessRoutes.sideMenuItems) {
//         if (previousRoute.settings.name == routeName) {
//           sidebarController.activeItem.value = routeName;
//         }
//       }
//     }
//   }
//
//   @override
//   void didPush(Route<dynamic>? route, Route<dynamic>? previousRoute) {
//     final sidebarController = Get.put(SidebarController());
//
//     if (route != null) {
//       // Check the route name and update the active item in the sidebar accordingly
//       for (var routeName in BessRoutes.sideMenuItems) {
//         if (route.settings.name == routeName) {
//           sidebarController.activeItem.value = routeName;
//         }
//       }
//     }
//
//   }
// }
//
