import 'package:bessie/utils/device/device_utility.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class BessHeader extends StatelessWidget implements PreferredSizeWidget{
  const BessHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: BessColors.white,
        border: Border(bottom: BorderSide(color: BessColors.grey, width: 1))
      ),
      padding: const EdgeInsets.symmetric(horizontal: BessSizes.md, vertical: BessSizes.sm),
      child: AppBar(
        leading: !BessDeviceUtils.isDesktopScreen(context) ? IconButton(onPressed: (){}, icon: const Icon(Iconsax.menu)) : null,
      ),
    );
  }
  
  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(BessDeviceUtils.getAppBarHeight() + 15);
}
