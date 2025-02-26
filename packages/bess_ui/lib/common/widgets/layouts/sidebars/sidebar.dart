import 'package:bessie/common/styles/text_styles.dart';
import 'package:bessie/common/widgets/images/bess_circular_image.dart';
import 'package:bessie/common/widgets/text/light_header.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
        child: const SingleChildScrollView(
          child: Column(
            children: [
              BessCircularImage(
                width: 100,
                height: 100,
                image: BessImages.lightAppLogo,
                backgroundColor: Colors.transparent,
              ),
              SizedBox(height: BessSizes.spaceBtwItems),
              Padding(
                padding: EdgeInsets.all(BessSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LightHeader(text: 'MENU'),
                    // Menu Items
                    BessMenuItem(
                        route: BessRoutes.home,
                        icon: Iconsax.home,
                        itemName: 'Home'),
                    BessMenuItem(
                        route: BessRoutes.sessionRoster,
                        icon: Iconsax.note_21,
                        itemName: 'Session Roster'),
                    BessMenuItem(
                        route: BessRoutes.console,
                        icon: Iconsax.code,
                        itemName: 'Console'),
                    BessMenuItem(
                        route: BessRoutes.responsiveDesignExample,
                        icon: Iconsax.picture_frame,
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
