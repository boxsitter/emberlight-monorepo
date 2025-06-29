import 'package:bess_ui/src/common/widgets/wrappers/radiance_new/radiance_ripple_new.dart';
import 'package:bess_ui/src/common/widgets/wrappers/tint.dart';
import 'package:flutter/material.dart';

import '../../utils/helpers/helper_functions.dart';
import 'local_pointer_data.dart';

typedef TintState = (bool isActive, Color? tint);

class Buttonize extends StatelessWidget {
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

  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    TintState? activeState;
    if (tintStates != null) {
      for (final state in tintStates!) {
        if (state.$1) {
          activeState = state;
          break;
        }
      }
    }

    final activeTint = activeState?.$2 ?? tint;

    return LocalPointerData(
      builder: (
        context,
        isHovering,
        isDown,
        localPosition,
        lastKnownClickState,
        lastKnownPosition,
      ) {
        final Offset? effectivePosition = localPosition ?? lastKnownPosition;
        final bool effectiveIsHeld = isDown ?? lastKnownClickState ?? false;

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.translucent,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: RadianceRipple(
              isHeld: effectiveIsHeld,
              isHovering: isHovering,
              tapPosition: effectivePosition,
              borderRadius: borderRadius ?? BorderRadius.zero,
              color: activeTint != null
                  ? BessHelperFunctions.blendColors(
                      activeTint,
                      Colors.white,
                      150,
                    )
                  : Colors.white,
              child: Tint(
                tint: activeTint,
                baseBackgroundColor: baseBackgroundColor,
                baseBorderColor: baseBorderColor,
                baseForegroundColor: baseForegroundColor,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
