import 'package:bessie/common/widgets/layouts/headers/header.dart';
import 'package:bessie/common/widgets/layouts/sidebars/sidebar.dart';
import 'package:flutter/material.dart';
import '../../../../utils/constants/sizes.dart';

class DesktopLayout extends StatelessWidget {
  DesktopLayout({super.key, this.body});

  final Widget? body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Expanded(child: BessSidebar()),
          Expanded(
            flex: 6,
            child: Column(
              children: [
                //HEADER
                const BessHeader(),
                // BODY
                Padding(
                  padding: const EdgeInsets.all(BessSizes.lg),
                  child: body ?? const SizedBox(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}