import 'package:bess_ui/src/common/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:bess_ui/src/common/constants/colors.dart';

class TintInfo {
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;

  const TintInfo({
    required this.backgroundColor,
    required this.borderColor,
    required this.foregroundColor,
  });
  //... equality and hashCode
}

class _TintData extends InheritedWidget {
  final TintInfo tintInfo;

  const _TintData({
    required this.tintInfo,
    required super.child,
  });

  @override
  bool updateShouldNotify(_TintData oldWidget) => tintInfo != oldWidget.tintInfo;
}

class Tint extends StatelessWidget {
  final Widget child;
  final Color? tint;
  final bool darken;
  final Color? baseBackgroundColor;
  final Color? baseBorderColor;
  final Color? baseForegroundColor;

  const Tint({
    super.key,
    required this.child,
    this.tint,
    this.darken = false,
    this.baseBackgroundColor,
    this.baseBorderColor,
    this.baseForegroundColor,
  });

  static TintInfo? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_TintData>()?.tintInfo;
  }

  @override
  Widget build(BuildContext context) {
    Color effectiveBackgroundColor = baseBackgroundColor ?? BessColors.core;
    if (tint != null) {
      effectiveBackgroundColor =
          BessHelperFunctions.blendColors(effectiveBackgroundColor, tint!, 60);
    }
    if (darken) {
      effectiveBackgroundColor = BessHelperFunctions.adjustHSL(
          effectiveBackgroundColor,
          luminance: -0.07,
          saturation: 0.2);
    }

    Color effectiveBorderColor;
    if (tint != null) {
      effectiveBorderColor = tint!;
    } else {
      effectiveBorderColor = baseBorderColor ?? BessColors.borderPrimary;
    }
    if (darken) {
      effectiveBorderColor = BessHelperFunctions.adjustHSL(effectiveBorderColor,
          luminance: -0.07, saturation: 0.2);
    }

    Color effectiveForegroundColor =
        baseForegroundColor ?? BessColors.textPrimary;
    if (tint != null) {
      effectiveForegroundColor = tint!;
    }
    if (darken) {
      effectiveForegroundColor = BessHelperFunctions.adjustHSL(
          effectiveForegroundColor,
          luminance: -0.07,
          saturation: 0.2);
    }
    effectiveForegroundColor = BessHelperFunctions.adjustHSL(effectiveForegroundColor, luminance: -0.2); // Darken the foreground slightly

    final tintInfo = TintInfo(
      backgroundColor: effectiveBackgroundColor,
      borderColor: effectiveBorderColor,
      foregroundColor: effectiveForegroundColor,
    );

    return _TintData(
      tintInfo: tintInfo,
      child: child,
    );
  }
}