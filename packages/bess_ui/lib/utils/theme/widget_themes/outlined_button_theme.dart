import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/* -- Light & Dark Outlined Button Themes -- */
class BessieOutlinedButtonTheme {
  BessieOutlinedButtonTheme._(); //To avoid creating instances

  /* -- Light Theme -- */
  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: BessColors.dark,
      side: const BorderSide(color: BessColors.borderPrimary),
      padding: const EdgeInsets.symmetric(
          vertical: BessSizes.buttonHeight, horizontal: 20),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BessSizes.buttonRadius)),
      textStyle: const TextStyle(
          fontSize: 16,
          color: BessColors.black,
          fontWeight: FontWeight.w600,
          fontFamily: 'Urbanist'),
    ),
  );

  /* -- Dark Theme -- */
  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: BessColors.light,
      side: const BorderSide(color: BessColors.borderPrimary),
      padding: const EdgeInsets.symmetric(
          vertical: BessSizes.buttonHeight, horizontal: 20),
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
