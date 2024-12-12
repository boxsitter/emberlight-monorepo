import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class BessieAppBarTheme {
  BessieAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    iconTheme:
        IconThemeData(color: BessColors.iconPrimary, size: BessSizes.iconMd),
    actionsIconTheme:
        IconThemeData(color: BessColors.iconPrimary, size: BessSizes.iconMd),
    titleTextStyle: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: BessColors.black,
        fontFamily: 'Urbanist'),
  );
  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: BessColors.dark,
    surfaceTintColor: BessColors.dark,
    iconTheme: IconThemeData(color: BessColors.black, size: BessSizes.iconMd),
    actionsIconTheme:
        IconThemeData(color: BessColors.white, size: BessSizes.iconMd),
    titleTextStyle: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: BessColors.white,
        fontFamily: 'Urbanist'),
  );
}
