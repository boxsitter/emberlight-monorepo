import 'package:bess_ui/src/common/routes/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../widgets/layouts/sidebars/sidebar_controller.dart';

abstract class BessNavigationSubscriber {
  Route get route;
  void onNavigateTo(String to, String? from);
  void onNavigateFrom(String from, String to);
}

class BessNavigationObserver extends NavigatorObserver {
  final _subscribers = <BessNavigationSubscriber>{};

  void subscribe(BessNavigationSubscriber subscriber) {
    _subscribers.add(subscriber);

    // When a widget subscribes, if its route is already the current, top-most
    // route, it should be notified. This typically happens for the very first
    // page of the app.
    if (subscriber.route.isCurrent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_subscribers.contains(subscriber)) {
          subscriber.onNavigateTo(subscriber.route.settings.name!, null);
        }
      });
    }
  }

  void unsubscribe(BessNavigationSubscriber subscriber) {
    _subscribers.remove(subscriber);
  }

  /// Determines if a route is a "real" page that should trigger navigation events.
  /// This is used to filter out popups, dialogs, and other transient routes.
  bool _isRealPageRoute(Route? route) {
    return route is PageRoute &&
        route.settings.name != null &&
        route.settings.name!.isNotEmpty;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final sidebarController = Get.find<SidebarController>();
    super.didPush(route, previousRoute);
      for (var routeName in BessRoutes.sideMenuItems) {
        if (route.settings.name == routeName) {
          sidebarController.activeItem.value = routeName;
        }
      }

    // Only trigger notifications if we are navigating between two "real" pages.
    // This correctly ignores showing a popup.
    if (_isRealPageRoute(route) && _isRealPageRoute(previousRoute)) {
      _notifyOnNavigateFrom(
          previousRoute!.settings.name!, route.settings.name!);
      _notifyOnNavigateTo(route.settings.name!, previousRoute.settings.name);
        }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final sidebarController = Get.find<SidebarController>();
    super.didPop(route, previousRoute);

    if (previousRoute != null) {
      for (var routeName in BessRoutes.sideMenuItems) {
        if (previousRoute.settings.name == routeName) {
          sidebarController.activeItem.value = routeName;
        }
      }
    }

    // Only trigger notifications if we are navigating between two "real" pages.
    // This correctly ignores dismissing a popup.
    if (_isRealPageRoute(route) && _isRealPageRoute(previousRoute)) {
      _notifyOnNavigateFrom(
          route.settings.name!, previousRoute!.settings.name!);
      _notifyOnNavigateTo(previousRoute.settings.name!, route.settings.name);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    // Only trigger notifications if we are replacing a "real" page with another.
    if (_isRealPageRoute(newRoute) && _isRealPageRoute(oldRoute)) {
      _notifyOnNavigateFrom(
          oldRoute!.settings.name!, newRoute!.settings.name!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifyOnNavigateTo(newRoute.settings.name!, oldRoute.settings.name);
      });
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);

    // didRemove is called for a variety of reasons, only some of which we care
    // about. For now, we are not using this, but it might be useful in the future.
  }

  void _notifyOnNavigateTo(String to, String? from) {
    for (var subscriber in _subscribers) {
      if (subscriber.route.settings.name == to) {
        subscriber.onNavigateTo(to, from);
    }
  }
}

  void _notifyOnNavigateFrom(String from, String to) {
    for (var subscriber in _subscribers) {
      if (subscriber.route.settings.name == from) {
        subscriber.onNavigateFrom(from, to);
      }
    }
  }
}