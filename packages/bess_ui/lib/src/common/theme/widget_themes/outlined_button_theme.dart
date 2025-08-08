import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/* -- Light & Dark Outlined Button Themes -- */
class BessieOutlinedButtonTheme {
  BessieOutlinedButtonTheme._(); //To avoid creating instances

  /* -- Light Theme -- */
  static final outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: BessColors.high,
      side: BorderSide(color: BessColors.borderPrimary),
      padding: const EdgeInsets.symmetric(
          vertical: BessSizes.buttonHeight, horizontal: BessSizes.bg),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BessSizes.buttonRadius)),
      textStyle: TextStyle(
          fontSize: BessSizes.fontSizeMd,
          color: BessColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter'),
    ),
  );
}
