import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/* -- Light & Dark Elevated Button Themes -- */
class BessieElevatedButtonTheme {
  BessieElevatedButtonTheme._(); //To avoid creating instances

  /* -- Light Theme -- */
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: ConstColors.light,
      backgroundColor: ConstColors.primary,
      disabledForegroundColor: ConstColors.darkGrey,
      disabledBackgroundColor: ConstColors.buttonDisabled,
      side: const BorderSide(color: ConstColors.primary),
      padding: const EdgeInsets.symmetric(vertical: ConstSizes.buttonHeight),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ConstSizes.buttonRadius)),
      textStyle: const TextStyle(
          fontSize: 16,
          color: ConstColors.textWhite,
          fontWeight: FontWeight.w500,
          fontFamily: 'Urbanist'),
    ),
  );

  /* -- Dark Theme -- */
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: ConstColors.light,
      backgroundColor: ConstColors.primary,
      disabledForegroundColor: ConstColors.darkGrey,
      disabledBackgroundColor: ConstColors.darkerGrey,
      side: const BorderSide(color: ConstColors.primary),
      padding: const EdgeInsets.symmetric(vertical: ConstSizes.buttonHeight),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ConstSizes.buttonRadius)),
      textStyle: const TextStyle(
          fontSize: 16,
          color: ConstColors.textWhite,
          fontWeight: FontWeight.w600,
          fontFamily: 'Urbanist'),
    ),
  );
}
