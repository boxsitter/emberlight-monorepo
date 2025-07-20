import 'package:bess_ui/src/common/styles/text_styles.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/* -- Light & Dark Elevated Button Themes -- */
class BessieScrollbarTheme {
  BessieScrollbarTheme._(); //To avoid creating instances

  /* -- Light Theme -- */
  static final scrollbarTheme = ScrollbarThemeData(
    thumbVisibility: WidgetStateProperty.all(true),
    interactive: true,
    thickness: WidgetStateProperty.all(8),
    thumbColor: WidgetStateProperty.all(BessColors.textInverted.withAlpha(160)),
    trackColor: WidgetStateProperty.all(BessColors.textInverted.withAlpha(50)),
    radius: const Radius.circular(4),
  );
}
