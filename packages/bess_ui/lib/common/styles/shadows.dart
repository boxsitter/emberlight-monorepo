import 'package:flutter/material.dart';

import '../utils/constants/colors.dart';

class BessShadowStyle {
  static final defaultBoxShadow = BoxShadow(
    color: BessColors.grey.withValues(alpha: 0.9),
    spreadRadius: 0,
    blurRadius: 5,
    offset: const Offset(5, 5),
  );
}
