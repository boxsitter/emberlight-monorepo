import 'package:bess_ui/src/common/mixins/route_aware_controller_mixin.dart';
import 'package:bess_ui/src/common/routes/navigation_observer.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// A reusable wrapper that combines RouteAware logic with a GetBuilder.
/// It listens for navigation events for the provided [controller] and
/// automatically rebuilds its [builder] when the controller's `update()` method is called.
@immutable
class ControllerDependantWrapper<T extends RouteAwareControllerMixin> extends StatefulWidget {
  const ControllerDependantWrapper({
    required this.controller,
    required this.tag,
    required this.builder,
    super.key,
  });

  /// The controller instance. This is used to enable the route-aware mixin.
  final T controller;

  /// The tag used by GetBuilder to find the correct controller instance.
  final String tag;

  /// A builder function that receives the controller instance from GetBuilder
  /// and returns the widget tree to be built.
  final Widget Function(T controller) builder;

  @override
  State<ControllerDependantWrapper<T>> createState() => _ControllerDependantWrapperState<T>();
}

class _ControllerDependantWrapperState<T extends RouteAwareControllerMixin> extends State<ControllerDependantWrapper<T>>
    implements BessNavigationSubscriber {
  final BessNavigationObserver _navObserver = Get.find<BessNavigationObserver>();
  ModalRoute<dynamic>? _route;

  @override
  Route<dynamic> get route => _route!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final newRoute = ModalRoute.of(context);
      if (newRoute != null && _route == null) {
        _route = newRoute;
        _navObserver.subscribe(this);
      }
    });
  }

  @override
  void dispose() {
    if (_route != null) {
      _navObserver.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      tag: widget.tag,
      builder: (controller) => widget.builder(controller),
    );
  }

  @override
  void onNavigateTo(String to, String? from) {
    widget.controller.onNavigateTo(to, from);
  }

  @override
  void onNavigateFrom(String from, String to) {
    widget.controller.onNavigateFrom(from, to);
  }
}
