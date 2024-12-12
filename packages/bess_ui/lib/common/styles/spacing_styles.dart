import 'package:flutter/material.dart';

import '../../utils/constants/sizes.dart';

class TSpacingStyle {
  static const EdgeInsetsGeometry paddingWithAppBarHeight = EdgeInsets.only(
    top: BessSizes.appBarHeight,
    left: BessSizes.defaultSpace,
    bottom: BessSizes.defaultSpace,
    right: BessSizes.defaultSpace,
  );
}
