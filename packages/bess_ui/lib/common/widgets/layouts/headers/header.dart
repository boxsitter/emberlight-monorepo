import 'package:bessie/common/widgets/images/bess_rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../constants//colors.dart';
import '../../../constants//enums.dart';
import '../../../constants//image_strings.dart';
import '../../../constants//sizes.dart';
import '../../../utils/device/device_utility.dart';

class BessHeader extends StatelessWidget implements PreferredSizeWidget {
  const BessHeader({super.key, this.scaffoldKey});

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: BessColors.core,
          border: Border(bottom: BorderSide(color: BessColors.semiLow, width: 1))),
      padding: const EdgeInsets.symmetric(
          horizontal: BessSizes.md, vertical: BessSizes.sm),
      child: AppBar(
        backgroundColor: Colors.transparent,
        // Mobile menu button
        leading: !BessDeviceUtils.isDesktopScreen(context)
            ? IconButton(
                onPressed: () => scaffoldKey?.currentState?.openDrawer(),
                icon: const Icon(LucideIcons.menu))
            : null,

        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BessRoundedImage(
                  width: 40,
                  padding: 2,
                  height: 40,
                  imageType: ImageType.asset,
                  image: BessImages.user),

              const SizedBox(width: BessSizes.sm),

              // Name and role
              if (!BessDeviceUtils.isMobileScreen(context))
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ice Pop',
                        style: Theme.of(context).textTheme.titleLarge),
                    Text('Village Leader',
                        style: Theme.of(context).textTheme.labelMedium),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize =>
      Size.fromHeight(BessDeviceUtils.getAppBarHeight() + 17);
}
