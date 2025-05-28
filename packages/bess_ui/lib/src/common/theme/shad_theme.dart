import 'package:bess_ui/src/common/styles/text_styles.dart';
import 'package:bess_ui/src/common/theme/widget_themes/text_theme.dart';
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

    selectTheme: ShadSelectTheme(
        decoration: ShadDecoration(),
    ),

    optionTheme: ShadOptionTheme(
      hoveredBackgroundColor: BessColors.element1,
    ),

    textTheme: ShadTextTheme(
      family: 'Inter',
      p: BessTextTheme.textTheme.bodyMedium,
    ),

    outlineButtonTheme: ShadButtonTheme(
      hoverBackgroundColor: BessColors.red,
      foregroundColor: BessColors.red,
    ),


  );

  static ShadColorScheme bessShadColorScheme = ShadColorScheme(
    background: BessColors.core,
    foreground: BessColors.textPrimary,
    card: Colors.red,
    cardForeground: Colors.red,
    popover: BessColors.core,
    popoverForeground: BessColors.textPrimary,
    primary: BessColors.primary,
    primaryForeground: BessColors.textInverted,
    secondary: BessColors.background,
    secondaryForeground: BessColors.textPrimary,
    muted: BessColors.textSubtle,
    mutedForeground: BessColors.textSubtle,
    accent: BessColors.secondary,
    accentForeground: BessColors.textInverted,
    destructive: Colors.red,
    destructiveForeground: Colors.red,
    border: BessColors.borderPrimary,
    input: BessColors.borderPrimary,
    ring: BessColors.primary,
    selection: BessColors.primary,

  );
}