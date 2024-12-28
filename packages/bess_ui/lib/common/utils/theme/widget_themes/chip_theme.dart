import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class BessieChipTheme {
  BessieChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    checkmarkColor: BessColors.white,
    selectedColor: BessColors.primary,
    disabledColor: BessColors.grey.withValues(alpha: 0.4),
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    labelStyle:
        const TextStyle(color: BessColors.black, fontFamily: 'Urbanist'),
  );

  static ChipThemeData darkChipTheme = const ChipThemeData(
    checkmarkColor: BessColors.white,
    selectedColor: BessColors.primary,
    disabledColor: BessColors.darkerGrey,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    labelStyle: TextStyle(color: BessColors.white, fontFamily: 'Urbanist'),
  );
}
