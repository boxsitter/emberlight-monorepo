import 'package:bessie/common/widgets/responsive/responsive_design.dart';
import 'package:bessie/common/widgets/responsive/screens/mobile_layout.dart';
import 'package:bessie/common/widgets/responsive/screens/tablet_layout.dart';
import 'package:flutter/material.dart';

import '../../responsive/screens/desktop_layout.dart';

/// Template for overall site layout, responsive to different screen sizes
class BessSiteTemplate extends StatelessWidget {
  const BessSiteTemplate({super.key, this.desktop, this.tablet, this.mobile, this.useLayout = true, this.desktopPadding = true});

  /// Widget for desktop layout
  final Widget? desktop;
  final bool desktopPadding;

  /// Widget for tablet layout
  final Widget? tablet;

  /// Widget for mobile layout
  final Widget? mobile;

  /// Flag to determine whether to use layout
  final bool useLayout;
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BessResponsiveWidget(
          desktop: useLayout ? DesktopLayout(body: desktop, usePadding: desktopPadding) : desktop ?? Container(),
          tablet: useLayout ? TabletLayout(body: tablet ?? desktop) : tablet ?? desktop ?? Container(),
          mobile: useLayout ? MobileLayout(body: mobile ?? desktop) : mobile ?? desktop ?? Container(),
      ),
    );
  }
}
