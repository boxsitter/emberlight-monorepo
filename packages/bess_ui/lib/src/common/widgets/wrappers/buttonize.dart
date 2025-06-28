import 'package:bess_ui/src/common/widgets/wrappers/radiance/radiance_effect_old.dart';
import 'package:bess_ui/src/common/widgets/wrappers/radiance_new/radiance_ripple_new.dart';
import 'package:bess_ui/src/common/widgets/wrappers/tint.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef TintState = (bool isActive, Color? tint);

class Buttonize extends StatefulWidget {
  const Buttonize({
    super.key,
    required this.child,
    required this.onTap,
    this.tint,
    this.tintStates,
    this.baseBackgroundColor,
    this.baseBorderColor,
    this.baseForegroundColor,
    this.borderRadius,
  });

  /// The widget that will be made interactive.
  final Widget child;

  /// The callback that is executed when the widget is tapped.
  final VoidCallback onTap;

  /// The default tint to apply when no other state is active.
  final Color? tint;

  /// An ordered list of custom states and their corresponding tints.
  /// The first state in the list where `isActive` is true will be used.
  final List<TintState>? tintStates;

  /// The base background color used for tint calculations.
  final Color? baseBackgroundColor;

  /// The base border color used for tint calculations.
  final Color? baseBorderColor;

  /// The base foreground color used for tint calculations.
  final Color? baseForegroundColor;

  /// The border radius to use for clipping the ripple effect.
  final BorderRadius? borderRadius;

  @override
  State<Buttonize> createState() => _ButtonizeState();
}

class _ButtonizeState extends State<Buttonize> {
  bool _isPointerDown = false;
  bool _isHeld = false;
  bool _isHovering = false;
  final ValueNotifier<Offset?> _tapPositionNotifier = ValueNotifier(null);

  @override
  void dispose() {
    _tapPositionNotifier.dispose();
    super.dispose();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (event.buttons != kPrimaryMouseButton) return;
    setState(() {
      _isPointerDown = true;
      _isHeld = true;
    });
    _tapPositionNotifier.value = event.localPosition;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (!_isPointerDown) return;

    // Only trigger the tap if the button was still "held" (i.e., inside bounds)
    if (_isHeld) {
      widget.onTap();
    }
    setState(() {
      _isPointerDown = false;
      _isHeld = false;
    });
  }

  void _handlePointerMove(PointerMoveEvent event) {
    _tapPositionNotifier.value = event.localPosition;
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    setState(() {
      _isPointerDown = false;
      _isHeld = false;
    });
    _tapPositionNotifier.value = null;
  }

  void _handleEnter(PointerEnterEvent event) {
    setState(() => _isHovering = true);
    // If pointer is down when entering, re-activate the "held" state
    if (_isPointerDown) {
      setState(() => _isHeld = true);
    }
    _tapPositionNotifier.value = event.localPosition;
  }

  void _handleExit(PointerExitEvent event) {
    setState(() => _isHovering = false);
    // If pointer is down when exiting, de-activate the "held" state
    if (_isPointerDown) {
      setState(() => _isHeld = false);
    }
    _tapPositionNotifier.value = null;
  }

  @override
  Widget build(BuildContext context) {
    TintState? activeState;
    if (widget.tintStates != null) {
      for (final state in widget.tintStates!) {
        if (state.$1) {
          activeState = state;
          break;
        }
      }
    }

    final activeTint = activeState?.$2 ?? widget.tint;

    return Listener(
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerMove: _handlePointerMove,
      onPointerCancel: _handlePointerCancel,
      child: MouseRegion(
        onEnter: _handleEnter,
        onExit: _handleExit,
        onHover: (event) => _tapPositionNotifier.value = event.localPosition,
      cursor: SystemMouseCursors.click,
        child: RadianceRipple(
          isHeld: _isHeld,
          isHovering: _isHovering,
          tapPositionNotifier: _tapPositionNotifier,
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          color: Colors.white,
        child: Tint(
          tint: activeTint,
          baseBackgroundColor: widget.baseBackgroundColor,
          baseBorderColor: widget.baseBorderColor,
          baseForegroundColor: widget.baseForegroundColor,
          child: widget.child,
        ),
      ),
      ),
    );
  }
}
