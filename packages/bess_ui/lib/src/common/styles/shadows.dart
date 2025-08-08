import 'package:bess_ui/src/common/constants/sizes.dart';
import 'package:flutter/material.dart';

class BessShadowStyle {
  static BoxShadow defaultBoxShadow = BoxShadow(
    color: Colors.black.withAlpha(BessSizes.alphaShadowWeak),
    blurRadius: BessSizes.shadowBlurDefault,
    offset: Offset(0, BessSizes.shadowOffsetYDefault),
    spreadRadius: 0,
  );
}
