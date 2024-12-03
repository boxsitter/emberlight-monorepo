import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class BessieTextFormFieldTheme {
  BessieTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: ConstColors.darkGrey,
    suffixIconColor: ConstColors.darkGrey,
    // constraints: const BoxConstraints.expand(height: TSizes.inputFieldHeight),
    labelStyle: const TextStyle().copyWith(
        fontSize: ConstSizes.fontSizeMd,
        color: ConstColors.textPrimary,
        fontFamily: 'Urbanist'),
    hintStyle: const TextStyle().copyWith(
        fontSize: ConstSizes.fontSizeSm,
        color: ConstColors.textSecondary,
        fontFamily: 'Urbanist'),
    errorStyle: const TextStyle()
        .copyWith(fontStyle: FontStyle.normal, fontFamily: 'Urbanist'),
    floatingLabelStyle: const TextStyle()
        .copyWith(color: ConstColors.textSecondary, fontFamily: 'Urbanist'),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(ConstSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: ConstColors.borderPrimary),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(ConstSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: ConstColors.borderPrimary),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(ConstSizes.inputFieldRadius),
      borderSide:
          const BorderSide(width: 1, color: ConstColors.borderSecondary),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(ConstSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: ConstColors.error),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(ConstSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 2, color: ConstColors.error),
    ),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 2,
    prefixIconColor: ConstColors.darkGrey,
    suffixIconColor: ConstColors.darkGrey,
    // constraints: const BoxConstraints.expand(height: TSizes.inputFieldHeight),
    labelStyle: const TextStyle().copyWith(
        fontSize: ConstSizes.fontSizeMd,
        color: ConstColors.white,
        fontFamily: 'Urbanist'),
    hintStyle: const TextStyle().copyWith(
        fontSize: ConstSizes.fontSizeSm,
        color: ConstColors.white,
        fontFamily: 'Urbanist'),
    floatingLabelStyle: const TextStyle().copyWith(
        color: ConstColors.white.withOpacity(0.8), fontFamily: 'Urbanist'),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(ConstSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: ConstColors.darkGrey),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(ConstSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: ConstColors.darkGrey),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(ConstSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: ConstColors.white),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(ConstSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: ConstColors.error),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(ConstSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 2, color: ConstColors.error),
    ),
  );
}
