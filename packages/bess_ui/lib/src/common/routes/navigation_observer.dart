import 'package:bess_ui/src/common/routes/routes.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../widgets/layouts/sidebars/sidebar_controller.dart';

abstract class BessNavigationSubscriber {
  Route get route;
  void onNavigateTo();
  void onNavigateFrom();
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
          subscriber.onNavigateTo();
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

  void _notifyOnNavigateTo(Route route) {
    final List<BessNavigationSubscriber> subscribers = _subscribers.toList();
    for (final sub in subscribers) {
      if (sub.route == route) {
        sub.onNavigateTo();
      }
    }
  }

  void _notifyOnNavigateFrom(Route route) {
    final List<BessNavigationSubscriber> subscribers = _subscribers.toList();
    for (final sub in subscribers) {
      if (sub.route == route) {
        sub.onNavigateFrom();
      }
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    // Only trigger onNavigateFrom if we are navigating away from a real page
    // to another real page. This is the key to ignoring popups.
    if (_isRealPageRoute(route) && _isRealPageRoute(previousRoute)) {
      _notifyOnNavigateFrom(previousRoute!);
    }

    // For the new page, if it's a real page, we wait until the end of the frame
    // to call onNavigateTo. By then, its widget will have been built and subscribed.
    if (_isRealPageRoute(route)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifyOnNavigateTo(route);
      });
    }

    if (Get.find<UserService>().isAuthenticated) {
      final sidebarController = Get.find<SidebarController>();

      for (var routeName in BessRoutes.sideMenuItems) {
        if (route.settings.name == routeName) {
          sidebarController.activeItem.value = routeName;
        }
      }
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
      _notifyOnNavigateFrom(route);
      _notifyOnNavigateTo(previousRoute!);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    // Only trigger notifications if we are replacing a "real" page with another.
    if (_isRealPageRoute(newRoute) && _isRealPageRoute(oldRoute)) {
      _notifyOnNavigateFrom(oldRoute!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifyOnNavigateTo(newRoute!);
      });
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);

    // didRemove is called for a route that is removed from the history.
    // We should notify its subscribers that they are being navigated from.
    if (_isRealPageRoute(route)) {
      _notifyOnNavigateFrom(route);
    }
  }
}
