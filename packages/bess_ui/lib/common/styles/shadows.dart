import 'package:flutter/material.dart';

import '../../utils/constants/colors.dart';

class BessShadowStyle {
  static final defaultBoxShadow = BoxShadow(
    color: BessColors.grey.withValues(alpha: 0.9),
    spreadRadius: 3,
    blurRadius: 8,
    offset: const Offset(3, 3),
  );
}
