import 'dart:async';

import 'package:bess_ui/src/common/widgets/wrappers/tint.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';

typedef TintState = (bool isActive, Color? tint);

class Buttonize extends StatefulWidget {
  const Buttonize({
    super.key,
    required this.child,
    this.onPressed,
    this.tint,
    this.tintStates,
    this.baseBackgroundColor,
    this.baseBorderColor,
    this.baseForegroundColor,
    this.enabled = true,
  });

  /// The widget that will be made interactive.
  final Widget child;

  /// The callback that is executed when the widget is tapped.
  final VoidCallback? onPressed;

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

  final bool enabled;

  @override
  State<Buttonize> createState() => _ButtonizeState();
}

class _ButtonizeState extends State<Buttonize> {
  bool _isHovering = false;
  bool _isPressed = false;
  Timer? _pressReleaseTimer; // Added for delayed press release

  @override
  void dispose() {
    _pressReleaseTimer?.cancel(); // Cancel any active timer to prevent memory leaks
    super.dispose();
  }

  void _onPressDown(_) {
    _pressReleaseTimer?.cancel(); // Cancel any existing timer if a new press starts
    setState(() => _isPressed = true);
  }

  void _onPressUp(_) {
    // Start a timer to delay setting _isPressed back to false
    _pressReleaseTimer = Timer(const Duration(milliseconds: 30), () {
      if (mounted) { // Check if the widget is still mounted before calling setState
        setState(() => _isPressed = false);
      }
    });
  }

  void _onPressCancel() {
    // Start a timer to delay setting _isPressed back to false
    _pressReleaseTimer = Timer(const Duration(milliseconds: 30), () {
      if (mounted) { // Check if the widget is still mounted before calling setState
        setState(() => _isPressed = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the tint color based on the widget's state
    Color? finalTint;
    if (_isPressed) {
      finalTint = BessColors.primary;
    } else {
      TintState? activeState;
      if (widget.tintStates != null) {
        for (final state in widget.tintStates!) {
          if (state.$1) {
            activeState = state;
            break;
          }
        }
      }
      finalTint = activeState?.$2 ?? widget.tint;
    }

    if (widget.enabled != false) {
      return GestureDetector(
        onTap: widget.onPressed,
        onTapDown: _onPressDown, // Use the new handler for press down
        onTapUp: _onPressUp,     // Use the new handler for press up (with delay)
        onTapCancel: _onPressCancel, // Use the new handler for press cancel (with delay)
        behavior: HitTestBehavior.translucent,
        // This property helps resolve gesture conflicts with scrollables faster.
        dragStartBehavior: DragStartBehavior.down,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: Tint(
            darken: _isHovering && !_isPressed,
            tint: finalTint,
            baseBackgroundColor: widget.baseBackgroundColor,
            baseBorderColor: widget.baseBorderColor,
            baseForegroundColor: widget.baseForegroundColor,
            child: widget.child,
          ),
        ),
      );
    } else {
      return Tint(
        darken: _isHovering && !_isPressed,
        tint: finalTint,
        baseBackgroundColor: widget.baseBackgroundColor,
        baseBorderColor: widget.baseBorderColor,
        baseForegroundColor: widget.baseForegroundColor,
        child: widget.child,
      );
    }
  }
}
