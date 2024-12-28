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
      foregroundColor: BessColors.light,
      backgroundColor: BessColors.primary,
      disabledForegroundColor: BessColors.darkGrey,
      disabledBackgroundColor: BessColors.buttonDisabled,
      side: const BorderSide(color: BessColors.primary),
      padding: const EdgeInsets.symmetric(vertical: BessSizes.buttonHeight),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BessSizes.buttonRadius)),
      textStyle: const TextStyle(
          fontSize: 16,
          color: BessColors.textWhite,
          fontWeight: FontWeight.w500,
          fontFamily: 'Urbanist'),
    ),
  );

  /* -- Dark Theme -- */
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: BessColors.light,
      backgroundColor: BessColors.primary,
      disabledForegroundColor: BessColors.darkGrey,
      disabledBackgroundColor: BessColors.darkerGrey,
      side: const BorderSide(color: BessColors.primary),
      padding: const EdgeInsets.symmetric(vertical: BessSizes.buttonHeight),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BessSizes.buttonRadius)),
      textStyle: const TextStyle(
          fontSize: 16,
          color: BessColors.textWhite,
          fontWeight: FontWeight.w600,
          fontFamily: 'Urbanist'),
    ),
  );
}
