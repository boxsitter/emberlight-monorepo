import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/// Custom Class for Light & Dark Text Themes
class BessTextTheme {
  BessTextTheme._(); // To avoid creating instances

  static TextTheme textTheme = TextTheme(
    headlineLarge: const TextStyle().copyWith(
      fontSize: BessSizes.fontSizeXxl,
      fontWeight: FontWeight.w900, // Black weight
      color: BessColors.textPrimary,
      letterSpacing: BessSizes.letterSpacingNarrow,
      fontFamily: 'Inter',
    ),
    headlineMedium: const TextStyle().copyWith(
      fontSize: BessSizes.fontSizeXl,
      fontWeight: FontWeight.w600, // SemiBold
      color: BessColors.textPrimary,
      letterSpacing: BessSizes.letterSpacingNarrow,
      fontFamily: 'Inter',
    ),
    headlineSmall: const TextStyle().copyWith(
      fontSize: BessSizes.fontSizeLg,
      fontWeight: FontWeight.w500, // Medium
      color: BessColors.textPrimary,
      letterSpacing: BessSizes.letterSpacingNarrow,
      fontFamily: 'Inter',
    ),
    titleLarge: const TextStyle().copyWith(
      fontSize: BessSizes.fontSizeMd,
      fontWeight: FontWeight.w600, // SemiBold
      color: BessColors.textPrimary,
      letterSpacing: BessSizes.letterSpacingNarrow,
      fontFamily: 'Inter',
    ),
    titleMedium: const TextStyle().copyWith(
      fontSize: BessSizes.fontSizeMd,
      fontWeight: FontWeight.w400, // Regular
      fontStyle: FontStyle.italic, // Uses Inter_24pt-Italic.ttf
      color: BessColors.textSecondary,
      letterSpacing: BessSizes.letterSpacingNarrow,
      fontFamily: 'Inter',
    ),
    titleSmall: const TextStyle().copyWith(
      fontSize: BessSizes.fontSizeMd,
      fontWeight: FontWeight.w400, // Regular
      color: BessColors.textSecondary,
      letterSpacing: BessSizes.letterSpacingNarrow,
      fontFamily: 'Inter',
    ),
    bodyLarge: const TextStyle().copyWith(
      fontSize: BessSizes.fontSizeSm,
      fontWeight: FontWeight.w500, // Medium
      color: BessColors.textPrimary,
      letterSpacing: BessSizes.letterSpacingNarrow,
      fontFamily: 'Inter',
    ),
    bodyMedium: const TextStyle().copyWith(
      fontSize: BessSizes.fontSizeSm,
      fontWeight: FontWeight.w400, // Regular
      color: BessColors.textPrimary,
      letterSpacing: BessSizes.letterSpacingNarrow,
      fontFamily: 'Inter',

    ),
    bodySmall: const TextStyle().copyWith(
      fontSize: BessSizes.fontSizeSm,
      fontWeight: FontWeight.w400, // Regular
      fontStyle: FontStyle.italic, // Uses Inter_24pt-Italic.ttf
      color: BessColors.textSecondary,
      letterSpacing: BessSizes.letterSpacingNarrow,
      fontFamily: 'Inter',
    ),
    labelLarge: const TextStyle().copyWith(
      fontSize: BessSizes.fontSizeSm,
      fontWeight: FontWeight.w400, // Regular
      color: BessColors.textPrimary,
      letterSpacing: BessSizes.letterSpacingNarrow,
      fontFamily: 'Inter',
    ),
    labelMedium: const TextStyle().copyWith(
      fontSize: BessSizes.fontSizeXs,
      fontWeight: FontWeight.w300, // Light
      color: BessColors.textSecondary,
      letterSpacing: BessSizes.letterSpacingNarrow,
      fontFamily: 'Inter',
    ),
  );
}
