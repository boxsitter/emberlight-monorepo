import 'package:bess_ui/src/common/widgets/layouts/headers/header.dart';
import 'package:bess_ui/src/common/widgets/layouts/sidebars/sidebar.dart';
import 'package:flutter/material.dart';

import '../../../constants/sizes.dart';

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key, this.body, this.usePadding = true});

  final Widget? body;
  final bool usePadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const BessSidebar(),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                // HEADER
                const BessHeader(),
                // BODY
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: usePadding ? const EdgeInsets.all(BessSizes.lg) : const EdgeInsets.all(0),
                      child: body ?? const SizedBox(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
