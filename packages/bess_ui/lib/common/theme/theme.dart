import 'package:flutter/material.dart';

import '../constants/colors.dart';
import 'widget_themes/appbar_theme.dart';
import 'widget_themes/bottom_sheet_theme.dart';
import 'widget_themes/checkbox_theme.dart';
import 'widget_themes/chip_theme.dart';
import 'widget_themes/elevated_button_theme.dart';
import 'widget_themes/outlined_button_theme.dart';
import 'widget_themes/text_field_theme.dart';
import 'widget_themes/text_theme.dart';

class BessieAppTheme {
  BessieAppTheme._();

  static ThemeData theme = ThemeData(

    useMaterial3: true,
    fontFamily: 'Inter',
    disabledColor: BessColors.disabled,
    brightness: Brightness.light,
    primaryColor: BessColors.primary,
    textTheme: BessieTextTheme.textTheme,
    chipTheme: BessieChipTheme.chipTheme,
    appBarTheme: BessieAppBarTheme.appBarTheme,
    checkboxTheme: BessieCheckboxTheme.checkboxTheme,
    scaffoldBackgroundColor: BessColors.background,
    bottomSheetTheme: BessieBottomSheetTheme.bottomSheetTheme,
    elevatedButtonTheme: BessieElevatedButtonTheme.elevatedButtonTheme,
    outlinedButtonTheme: BessieOutlinedButtonTheme.outlinedButtonTheme,
    inputDecorationTheme: BessieTextFormFieldTheme.inputDecorationTheme,
  );

  // static ThemeData darkTheme = ThemeData(
  //   useMaterial3: true,
  //   fontFamily: 'Inter',
  //   disabledColor: BessColors.grey,
  //   brightness: Brightness.dark,
  //   primaryColor: BessColors.primary,
  //   textTheme: BessieTextTheme.darkTextTheme,
  //   chipTheme: BessieChipTheme.darkChipTheme,
  //   appBarTheme: BessieAppBarTheme.darkAppBarTheme,
  //   checkboxTheme: BessieCheckboxTheme.darkCheckboxTheme,
  //   scaffoldBackgroundColor: BessColors.primary.withValues(alpha: (0.1)),
  //   bottomSheetTheme: BessieBottomSheetTheme.darkBottomSheetTheme,
  //   elevatedButtonTheme: BessieElevatedButtonTheme.darkElevatedButtonTheme,
  //   outlinedButtonTheme: BessieOutlinedButtonTheme.darkOutlinedButtonTheme,
  //   inputDecorationTheme: BessieTextFormFieldTheme.darkInputDecorationTheme,
  // );
}
