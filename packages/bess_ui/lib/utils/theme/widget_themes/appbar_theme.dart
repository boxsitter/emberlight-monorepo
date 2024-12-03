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
        IconThemeData(color: ConstColors.iconPrimary, size: ConstSizes.iconMd),
    actionsIconTheme:
        IconThemeData(color: ConstColors.iconPrimary, size: ConstSizes.iconMd),
    titleTextStyle: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: ConstColors.black,
        fontFamily: 'Urbanist'),
  );
  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: ConstColors.dark,
    surfaceTintColor: ConstColors.dark,
    iconTheme: IconThemeData(color: ConstColors.black, size: ConstSizes.iconMd),
    actionsIconTheme:
        IconThemeData(color: ConstColors.white, size: ConstSizes.iconMd),
    titleTextStyle: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color: ConstColors.white,
        fontFamily: 'Urbanist'),
  );
}
