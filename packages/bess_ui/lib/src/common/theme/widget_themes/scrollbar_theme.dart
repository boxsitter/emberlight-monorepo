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
    thickness: WidgetStateProperty.all(BessSizes.scrollbarThicknessMd),
    thumbColor: WidgetStateProperty.all(BessColors.textInverted.withAlpha(BessSizes.alphaScrollbarThumb)),
    trackColor: WidgetStateProperty.all(BessColors.textInverted.withAlpha(BessSizes.alphaScrollbarTrack)),
    radius: const Radius.circular(BessSizes.scrollbarRadius),
  );
}
