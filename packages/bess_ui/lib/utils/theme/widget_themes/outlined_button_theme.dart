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
      foregroundColor: ConstColors.dark,
      side: const BorderSide(color: ConstColors.borderPrimary),
      padding: const EdgeInsets.symmetric(
          vertical: ConstSizes.buttonHeight, horizontal: 20),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ConstSizes.buttonRadius)),
      textStyle: const TextStyle(
          fontSize: 16,
          color: ConstColors.black,
          fontWeight: FontWeight.w600,
          fontFamily: 'Urbanist'),
    ),
  );

  /* -- Dark Theme -- */
  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: ConstColors.light,
      side: const BorderSide(color: ConstColors.borderPrimary),
      padding: const EdgeInsets.symmetric(
          vertical: ConstSizes.buttonHeight, horizontal: 20),
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
