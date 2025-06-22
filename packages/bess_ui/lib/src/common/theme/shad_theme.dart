import 'package:bess_ui/src/common/theme/widget_themes/text_theme.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../constants/animation_curves.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';

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

    menubarTheme: ShadMenubarTheme(
      buttonForegroundColor: BessColors.textPrimary,
      backgroundColor: BessColors.core,
      buttonHoverBackgroundColor: BessColors.crust,
      buttonHoverForegroundColor: BessColors.textPrimary,
      buttonSelectedBackgroundColor: BessColors.crust,
      buttonPressedBackgroundColor: BessColors.primary,
      buttonPressedForegroundColor: BessColors.textInverted,
      buttonBackgroundColor: BessColors.core,
      buttonSize: ShadButtonSize.sm,
      buttonHeight: 30,
      radius: BorderRadius.all(Radius.circular(BessSizes.cardRadiusMd)),
    ),

    contextMenuTheme: ShadContextMenuTheme(
      selectedBackgroundColor: BessColors.primary,
      backgroundColor: BessColors.core,
    ),

    primaryButtonTheme: ShadButtonTheme(
      hoverBackgroundColor: BessColors.crust,
      hoverForegroundColor: BessColors.textPrimary,
    ),

    secondaryButtonTheme: ShadButtonTheme(
      hoverBackgroundColor: BessColors.crust,
      hoverForegroundColor: BessColors.textPrimary,
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
    accent: BessColors.crust,
    accentForeground: BessColors.textPrimary,
    destructive: Colors.red,
    destructiveForeground: Colors.red,
    border: BessColors.borderPrimary,
    input: BessColors.borderPrimary,
    ring: BessColors.primary,
    selection: BessColors.primary,

  );
}