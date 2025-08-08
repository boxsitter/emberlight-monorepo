import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/sizes.dart';

class BessTextStyles {
  static final TextStyle standard = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeSm,
    color: BessColors.textPrimary,
    fontWeight: FontWeight.w400,
    height: BessSizes.lineHeightTight,
  );

  static final TextStyle standardSecondary = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeSm,
    color: BessColors.textSecondary,
    fontWeight: FontWeight.w400,
    height: BessSizes.lineHeightTight,
  );

  static final TextStyle standardBold = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeSm,
    color: BessColors.textPrimary,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle standardInverted = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeSm,
    color: BessColors.textInverted,
    fontWeight: FontWeight.w400,
    height: BessSizes.lineHeightTight,
  );

  static final TextStyle standardLink = TextStyle(
      fontFamily: 'Inter',
      fontSize: BessSizes.fontSizeSm,
      color: BessColors.textLink,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.underline
  );

  static final TextStyle label = TextStyle(
      fontFamily: 'Inter',
      fontSize: BessSizes.fontSizeXs,
      color: BessColors.textSecondary,
      fontWeight: FontWeight.w300,
  );

  static final TextStyle largerLabel = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeSm,
    color: BessColors.textSecondary,
    fontWeight: FontWeight.w300,
  );

  static final TextStyle subtle = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeXs,
    color: BessColors.textSubtle,
    fontWeight: FontWeight.w300,
  );
  static final TextStyle tiny = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeTiny,
    color: BessColors.textSubtle,
    fontWeight: FontWeight.w300,
  );

  static final TextStyle secondarySmall = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeSsm,
    color: BessColors.textSecondary,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle lightHeader = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeSm,
    color: BessColors.textSubtle,
    fontWeight: FontWeight.w300,
    letterSpacing: BessSizes.letterSpacingWide,
  );

  static final TextStyle darkHeader = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeSm,
    color: BessColors.textPrimary,
    fontWeight: FontWeight.w300,
    letterSpacing: BessSizes.letterSpacingWide,
  );

  static final TextStyle lightTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeDisplay,
    color: BessColors.textSubtle,
    fontWeight: FontWeight.w300,
    letterSpacing: BessSizes.letterSpacingWide,
  );

  static final TextStyle darkTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeDisplay,
    color: BessColors.textPrimary,
    fontWeight: FontWeight.w300,
    letterSpacing: BessSizes.letterSpacingWide,
  );

  static final TextStyle largeCardHeader = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeXxl,
    color: BessColors.textPrimary,
    fontWeight: FontWeight.w600,
    letterSpacing: BessSizes.letterSpacingNarrow,
  );

  static final TextStyle tableHeader = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeXl,
    color: BessColors.textPrimary,
    fontWeight: FontWeight.w600,
    letterSpacing: BessSizes.letterSpacingNarrow,
  );

  static final TextStyle tableHeaderSecondary = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeLg,
    color: BessColors.textSecondary,
    fontWeight: FontWeight.w600,
    letterSpacing: BessSizes.letterSpacingNarrow,
  );

  static final TextStyle columnHeader = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeXs,
    color: BessColors.textSubtle,
    fontWeight: FontWeight.w600,
    letterSpacing: BessSizes.letterSpacingWide,
  );

  static final TextStyle boldCardTitle = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeLg,
    color: BessColors.textPrimary,
    fontWeight: FontWeight.w600,
    letterSpacing: BessSizes.letterSpacingWide,
  );

  static final TextStyle textIcon = TextStyle(
    fontFamily: 'Inter',
    fontSize: BessSizes.fontSizeXs,
    color: BessColors.textPrimary,
    fontWeight: FontWeight.w600,
    letterSpacing: BessSizes.letterSpacingNarrow,
  );
}