import 'package:flutter/material.dart';

import '../../utils/constants/sizes.dart';

class BessResponsiveWidget extends StatelessWidget {
  const BessResponsiveWidget(
      {super.key,
      required this.desktop,
      required this.tablet,
      required this.mobile});

  /// Widget for desktop layout
  final Widget desktop;

  /// Widget for tablet layout
  final Widget tablet;

  /// Widget for mobile layout
  final Widget mobile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth >= BessSizes.desktopScreenSize) {
          return desktop;
        } else if (constraints.maxWidth < BessSizes.desktopScreenSize &&
            constraints.maxWidth >= BessSizes.tabletScreenSize) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}
