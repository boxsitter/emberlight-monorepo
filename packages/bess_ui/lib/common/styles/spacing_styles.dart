import 'package:flutter/material.dart';

import '../../utils/constants/sizes.dart';

class TSpacingStyle {
  static const EdgeInsetsGeometry paddingWithAppBarHeight = EdgeInsets.only(
    top: ConstSizes.appBarHeight,
    left: ConstSizes.defaultSpace,
    bottom: ConstSizes.defaultSpace,
    right: ConstSizes.defaultSpace,
  );
}
