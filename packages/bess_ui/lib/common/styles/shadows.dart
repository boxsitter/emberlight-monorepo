import 'package:flutter/material.dart';

class BessShadowStyle {
  static BoxShadow defaultBoxShadow = BoxShadow(
    color: Colors.black.withAlpha(100),
    spreadRadius: 1,
    blurRadius: 10,
    offset: Offset(0, -10),
  );
}
