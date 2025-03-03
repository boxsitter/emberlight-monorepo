import 'package:bessie/common/theme/widget_themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../constants/animation_curves.dart';
import '../constants/colors.dart';

class BessShadTheme {
  static ShadThemeData shadThemeData = ShadThemeData(
    colorScheme: bessShadColorScheme,
    brightness: Brightness.light,

    tooltipTheme: const ShadTooltipTheme(
      effects: [

        SlideEffect(
          duration: Duration(milliseconds: 200),
          curve: BessAnimationCurves.easeOut,
          begin: Offset(0, 0.8),
        ),

        FadeEffect(
          duration: Duration(milliseconds: 200),
          begin: 0.0,
          end: 1.0,
          curve: Curves.easeOut,
        ),

      ]
    ),

    textTheme: ShadTextTheme(
      family: 'Inter',
      p: BessTextTheme.textTheme.bodyMedium,
    )
  );

  static ShadColorScheme bessShadColorScheme = ShadColorScheme(
      background: BessColors.core,
      foreground: Colors.red,
      card: Colors.orange,
      cardForeground: Colors.yellow,
      popover: BessColors.core,
      popoverForeground: BessColors.textPrimary,
      primary: BessColors.primary,
      primaryForeground: BessColors.textInverted,
      secondary: BessColors.background,
      secondaryForeground: BessColors.textPrimary,
      muted: Colors.greenAccent,
      mutedForeground: Colors.lime,
      accent: BessColors.secondary,
      accentForeground: Colors.brown,
      destructive: Colors.black,
      destructiveForeground: Colors.grey,
      border: BessColors.borderPrimary,
      input: Colors.amberAccent,
      ring: Colors.teal,
      selection: Colors.lightGreenAccent,
  );
}