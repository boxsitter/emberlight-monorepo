import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import '../../utils/constants/sizes.dart';

class BessResponsiveWidget extends StatefulWidget {
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
  BessResponsiveWidgetState createState() => BessResponsiveWidgetState();
}

class BessResponsiveWidgetState extends State<BessResponsiveWidget> with WindowListener {
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    windowManager.removeListener(this);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (_isDesktop && event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.f11) {
      _toggleFullScreen();
      return true; // Indicate the event is handled.
    }
    return false; // Allow other handlers to process the event.
  }

  bool get _isDesktop {
    // Check if the app is running on desktop platforms
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  Future<void> _toggleFullScreen() async {
    if (isFullScreen) {
      await windowManager.setFullScreen(false);
    } else {
      await windowManager.setFullScreen(true);
    }
    setState(() {
      isFullScreen = !isFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth >= BessSizes.desktopScreenSize) {
          return widget.desktop;
        } else if (constraints.maxWidth < BessSizes.desktopScreenSize &&
            constraints.maxWidth >= BessSizes.tabletScreenSize) {
          return widget.tablet;
        } else {
          return widget.mobile;
        }
      },
    );
  }
}
