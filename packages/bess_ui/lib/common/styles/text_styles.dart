import 'package:bessie/common/theme/widget_themes/text_theme.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';

class BessTextStyles {
  static final TextStyle standard = BessieTextTheme.textTheme.bodyMedium!.apply(
      color: BessColors.textPrimary
  );

  static final TextStyle standardInverted = BessieTextTheme.textTheme.bodyMedium!.apply(
      color: BessColors.textInverted
  );

  static final TextStyle standardLink = BessieTextTheme.textTheme.bodyMedium!.apply(
      color: BessColors.textLink,
      decoration: TextDecoration.underline
  );

  static final TextStyle label = BessieTextTheme.textTheme.labelMedium!.apply(
      color: BessColors.textSecondary
  );

  static final TextStyle subtle = BessieTextTheme.textTheme.labelMedium!.apply(
      color: BessColors.textSubtle
  );

  static final TextStyle lightHeader = BessieTextTheme.textTheme.labelMedium!.copyWith(
      color: BessColors.textSubtle,
      fontSize: 14,
      letterSpacing: 2.0
  );
}