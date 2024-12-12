import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class BessieTextFormFieldTheme {
  BessieTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: BessColors.darkGrey,
    suffixIconColor: BessColors.darkGrey,
    // constraints: const BoxConstraints.expand(height: TSizes.inputFieldHeight),
    labelStyle: const TextStyle().copyWith(
        fontSize: BessSizes.fontSizeMd,
        color: BessColors.textPrimary,
        fontFamily: 'Urbanist'),
    hintStyle: const TextStyle().copyWith(
        fontSize: BessSizes.fontSizeSm,
        color: BessColors.textSecondary,
        fontFamily: 'Urbanist'),
    errorStyle: const TextStyle()
        .copyWith(fontStyle: FontStyle.normal, fontFamily: 'Urbanist'),
    floatingLabelStyle: const TextStyle()
        .copyWith(color: BessColors.textSecondary, fontFamily: 'Urbanist'),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(BessSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: BessColors.borderPrimary),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(BessSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: BessColors.borderPrimary),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(BessSizes.inputFieldRadius),
      borderSide:
          const BorderSide(width: 1, color: BessColors.borderSecondary),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(BessSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: BessColors.error),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(BessSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 2, color: BessColors.error),
    ),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 2,
    prefixIconColor: BessColors.darkGrey,
    suffixIconColor: BessColors.darkGrey,
    // constraints: const BoxConstraints.expand(height: TSizes.inputFieldHeight),
    labelStyle: const TextStyle().copyWith(
        fontSize: BessSizes.fontSizeMd,
        color: BessColors.white,
        fontFamily: 'Urbanist'),
    hintStyle: const TextStyle().copyWith(
        fontSize: BessSizes.fontSizeSm,
        color: BessColors.white,
        fontFamily: 'Urbanist'),
    floatingLabelStyle: const TextStyle().copyWith(
        color: BessColors.white.withOpacity(0.8), fontFamily: 'Urbanist'),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(BessSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: BessColors.darkGrey),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(BessSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: BessColors.darkGrey),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(BessSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: BessColors.white),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(BessSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: BessColors.error),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(BessSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 2, color: BessColors.error),
    ),
  );
}
