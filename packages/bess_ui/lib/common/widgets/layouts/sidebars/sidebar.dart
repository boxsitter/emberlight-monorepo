import 'package:bessie/common/styles/text_styles.dart';
import 'package:bessie/common/widgets/images/bess_circular_image.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../routes/routes.dart';
import '../../../constants//colors.dart';
import '../../../constants//image_strings.dart';
import '../../../constants//sizes.dart';
import '../../../utils/device/device_utility.dart';
import 'menu/menu_item.dart';

class BessSidebar extends StatelessWidget {
  const BessSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      shape: BessDeviceUtils.isDesktopScreen(context)
          ? const BeveledRectangleBorder()
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: BessColors.core,
          border: Border(right: BorderSide(color: BessColors.semiLow, width: 1)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const BessCircularImage(
                width: 150,
                height: 150,
                image: BessImages.lightAppLogo,
                backgroundColor: Colors.transparent,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: BessSizes.md, left: BessSizes.md, right: BessSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Text(
                    'MENU',
                    style: BessTextStyles.lightHeader,
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                  ),
                    // Menu Items
                    const BessMenuItem(
                        route: BessRoutes.home,
                        icon: LucideIcons.house,
                        itemName: 'Home'),
                    const BessMenuItem(
                        route: BessRoutes.sessionRoster,
                        icon: LucideIcons.bookUser,
                        itemName: 'Session Roster'),
                    const BessMenuItem(
                        route: BessRoutes.console,
                        icon: LucideIcons.squareTerminal,
                        itemName: 'Console'),
                    const BessMenuItem(
                        route: BessRoutes.responsiveDesignExample,
                        icon: LucideIcons.layoutPanelLeft,
                        itemName: 'Widgets'),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
