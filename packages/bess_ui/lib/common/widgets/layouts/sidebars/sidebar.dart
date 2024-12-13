import 'package:bessie/common/widgets/images/bess_circular_image.dart';
import 'package:bessie/routes/routes.dart';
import 'package:bessie/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/device/device_utility.dart';
import 'menu/menu_item.dart';

class BessSidebar extends StatelessWidget {
  const BessSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: BessDeviceUtils.isDesktopScreen(context) ? const BeveledRectangleBorder() : null,
      child: Container(
        decoration: const BoxDecoration(
          color: BessColors.white,
          border: Border(right: BorderSide(color: BessColors.grey, width: 1)),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Image
              const BessCircularImage(width: 100, height: 100, image: BessImages.lightAppLogo, backgroundColor: Colors.transparent,),
              const SizedBox(height: BessSizes.spaceBtwSections),
              Padding(
                padding: EdgeInsets.all(BessSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('MENU', style: Theme.of(context).textTheme.bodySmall!.apply(letterSpacingDelta: 1.2),),

                    // Menu Items
                    const BessMenuItem(route: BessRoutes.firstScreen, icon: Iconsax.home, itemName: 'Home'),
                    const BessMenuItem(route: BessRoutes.secondScreen, icon: Iconsax.image, itemName: 'Media'),
                    const BessMenuItem(route: BessRoutes.responsiveDesignExample, icon: Iconsax.picture_frame, itemName: 'Banners'),
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

