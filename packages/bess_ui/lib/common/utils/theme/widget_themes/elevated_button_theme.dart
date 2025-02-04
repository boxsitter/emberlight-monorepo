import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

/* -- Light & Dark Elevated Button Themes -- */
class BessieElevatedButtonTheme {
  BessieElevatedButtonTheme._(); //To avoid creating instances

  /* -- Light Theme -- */
  static final elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: BessColors.element1,
      backgroundColor: BessColors.primary,
      disabledForegroundColor: BessColors.semiHigh,
      disabledBackgroundColor: BessColors.disabled,
      side: BorderSide(color: BessColors.primary),
      padding: const EdgeInsets.symmetric(vertical: BessSizes.buttonHeight),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BessSizes.buttonRadius)),
      textStyle: TextStyle(
          fontSize: 16,
          color: BessColors.textInverted,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter'),
    ),
  );
}
