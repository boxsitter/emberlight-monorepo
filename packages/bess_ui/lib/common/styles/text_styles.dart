import 'package:bessie/common/theme/widget_themes/text_theme.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';

class BessTextStyles {
  static final TextStyle standard = BessTextTheme.textTheme.bodyMedium!.apply(
      color: BessColors.textPrimary
  );

  static final TextStyle standardInverted = BessTextTheme.textTheme.bodyMedium!.apply(
      color: BessColors.textInverted
  );

  static final TextStyle standardLink = BessTextTheme.textTheme.bodyMedium!.apply(
      color: BessColors.textLink,
      decoration: TextDecoration.underline
  );

  static final TextStyle label = BessTextTheme.textTheme.labelMedium!.apply(
      color: BessColors.textSecondary
  );

  static final TextStyle subtle = BessTextTheme.textTheme.labelMedium!.apply(
      color: BessColors.textSubtle
  );

  static final TextStyle lightHeader = BessTextTheme.textTheme.labelMedium!.copyWith(
      color: BessColors.textSubtle,
      fontSize: 14,
      letterSpacing: 2.0
  );

  static final TextStyle boldHeader = BessTextTheme.textTheme.labelMedium!.copyWith(
      color: BessColors.textPrimary,
      fontSize: 14,
      letterSpacing: 2.0
  );

  static final TextStyle lightTitle = BessTextTheme.textTheme.labelMedium!.copyWith(
      color: BessColors.textSubtle,
      fontSize: 36,
      letterSpacing: 2.0
  );

  static final TextStyle tableHeader = BessTextTheme.textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.w600,
  );

  static final TextStyle columnHeader = BessTextTheme.textTheme.labelMedium!.copyWith(
      color: BessColors.textSubtle,
      fontSize: 12,
      fontWeight: FontWeight.w600,
  );
}