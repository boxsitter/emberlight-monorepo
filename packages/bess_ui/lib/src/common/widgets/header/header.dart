import 'package:bess_ui/src/common/constants/colors.dart';
import 'package:bess_ui/src/common/widgets/header/menu_bar.dart';
import 'package:bess_ui/src/common/widgets/images/bess_circular_image.dart';
import 'package:flutter/material.dart';

import '../../constants/image_strings.dart';

class BessHeader extends StatelessWidget implements PreferredSizeWidget {
  const BessHeader({super.key, required this.menuBar, this.scaffoldKey, this.centerActions = const [], this.trailingWidgets = const []});

  final GlobalKey<ScaffoldState>? scaffoldKey;
  final BessMenuBar menuBar;
  final List<Widget> centerActions;
  final List<Widget> trailingWidgets;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
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
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: BessColors.semiLow, width: 1)),
            ),
            child: menuBar,
          ),

          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  ...centerActions,

                  Spacer(),

                  ...trailingWidgets,
                ],
              ),
            ),
          )


        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(40);
}

// onPressed: () => scaffoldKey?.currentState?.openDrawer(),
