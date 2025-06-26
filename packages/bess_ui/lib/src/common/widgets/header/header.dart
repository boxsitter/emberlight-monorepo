import 'package:bess_ui/src/common/constants/colors.dart';
import 'package:bess_ui/src/common/widgets/header/menu_bar.dart';
import 'package:flutter/material.dart';

import '../../constants/sizes.dart';
import '../../utils/device/device_utility.dart';

class BessHeader extends StatelessWidget implements PreferredSizeWidget {
  const BessHeader({super.key, required this.menuBar, this.scaffoldKey, this.centerActions = const [], this.trailingWidgets = const []});

  final GlobalKey<ScaffoldState>? scaffoldKey;
  final BessMenuBar menuBar;
  final List<Widget> centerActions;
  final List<Widget> trailingWidgets;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: BessColors.core,
        border: Border(bottom: BorderSide(color: BessColors.semiLow, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Menu Bar
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: BessColors.core,
              border: Border(right: BorderSide(color: BessColors.semiLow, width: 1)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                ),
                menuBar,
              ],
            ),
          ),

          ...centerActions,

          Spacer(),

          ...trailingWidgets,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40);
}

// onPressed: () => scaffoldKey?.currentState?.openDrawer(),
