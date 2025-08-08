import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class BessieChipTheme {
  BessieChipTheme._();

  static ChipThemeData chipTheme = ChipThemeData(
    checkmarkColor: BessColors.low,
    selectedColor: BessColors.primary,
    disabledColor: BessColors.middle.withValues(alpha: 0.4),
    padding: EdgeInsets.symmetric(horizontal: BessSizes.ms, vertical: BessSizes.ms),
    labelStyle:
        TextStyle(color: BessColors.high, fontFamily: 'Inter'),
  );
}
