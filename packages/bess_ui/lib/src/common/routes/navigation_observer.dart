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
  String? _pendingNavToRouteName;
  String? _pendingNavFromRouteName;

  void subscribe(BessNavigationSubscriber subscriber) {
    _subscribers.add(subscriber);

    // Only trigger onNavigateTo if there is a PENDING navigation to this route.
    // This distinguishes a true navigation event from a simple layout-change rebuild.
    if (subscriber.route.settings.name == _pendingNavToRouteName) {
      final to = _pendingNavToRouteName!;
      final from = _pendingNavFromRouteName;

      // Consume the pending navigation flag so it's only used once.
      _pendingNavToRouteName = null;
      _pendingNavFromRouteName = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_subscribers.contains(subscriber)) {
          subscriber.onNavigateTo(to, from);
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
    return route is PageRoute && route.settings.name != null && route.settings.name != BessRoutes.unknown;
  }

  void _notifyOnNavigateFrom(String from, String to) {
    // Notify the sidebar controller that the selected item may have changed
    if (Get.isRegistered<SidebarController>()) {
      Get.find<SidebarController>().changeActiveItem(to);
    }

    for (var subscriber in Set.of(_subscribers)) {
      if (subscriber.route.settings.name == from) {
        subscriber.onNavigateFrom(from, to);
      }
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (_isRealPageRoute(route)) {
      _pendingNavToRouteName = route.settings.name;
      _pendingNavFromRouteName = previousRoute?.settings.name;
      if (_isRealPageRoute(previousRoute)) {
        _notifyOnNavigateFrom(previousRoute!.settings.name!, route.settings.name!);
      }
    }
  }

  void _notifyOnNavigateTo(String to, String? from) {
    // Make a copy to avoid concurrent modification issues
    for (var subscriber in Set.of(_subscribers)) {
      if (subscriber.route.settings.name == to) {
        subscriber.onNavigateTo(to, from);
      }
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    if (_isRealPageRoute(route) && _isRealPageRoute(previousRoute)) {
      _notifyOnNavigateFrom(route.settings.name!, previousRoute!.settings.name!);
      // For pop, the subscriber already exists, so we notify it directly.
      _notifyOnNavigateTo(previousRoute.settings.name!, route.settings.name);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    if (_isRealPageRoute(newRoute) && _isRealPageRoute(oldRoute)) {
      _notifyOnNavigateFrom(oldRoute!.settings.name!, newRoute!.settings.name!);
      // Replace is like a push; set the pending flag for the new subscriber.
      _pendingNavToRouteName = newRoute.settings.name;
      _pendingNavFromRouteName = oldRoute.settings.name;
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
  }
}
