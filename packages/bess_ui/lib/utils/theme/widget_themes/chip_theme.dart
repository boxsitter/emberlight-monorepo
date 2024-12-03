import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class BessieChipTheme {
  BessieChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    checkmarkColor: ConstColors.white,
    selectedColor: ConstColors.primary,
    disabledColor: ConstColors.grey.withOpacity(0.4),
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    labelStyle:
        const TextStyle(color: ConstColors.black, fontFamily: 'Urbanist'),
  );

  static ChipThemeData darkChipTheme = const ChipThemeData(
    checkmarkColor: ConstColors.white,
    selectedColor: ConstColors.primary,
    disabledColor: ConstColors.darkerGrey,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    labelStyle: TextStyle(color: ConstColors.white, fontFamily: 'Urbanist'),
  );
}
