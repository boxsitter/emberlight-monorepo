

import 'package:flutter/material.dart';

import '../../../utils/constants/sizes.dart';

class BessResponsiveWidget extends StatelessWidget {
  const BessResponsiveWidget({super.key, required this.desktop, required this.tablet, required this.mobile});

  final Widget desktop;

  final Widget tablet;

  final Widget mobile;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if(constraints.maxWidth >= BessSizes.desktopScreenSize){
          return desktop;
        } else if (constraints.maxWidth < BessSizes.desktopScreenSize && constraints.maxWidth >= BessSizes.tabletScreenSize) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}