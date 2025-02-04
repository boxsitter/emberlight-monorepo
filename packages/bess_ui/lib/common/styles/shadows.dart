import 'package:flutter/material.dart';

import '../constants//colors.dart';

class BessShadowStyle {
  static final defaultBoxShadow = BoxShadow(
    color: BessColors.shadow,
    spreadRadius: 0,
    blurRadius: 5,
    offset: const Offset(5, 5),
  );
}
