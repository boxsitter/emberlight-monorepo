import 'package:bess_ui/src/common/styles/text_styles.dart';
import 'package:bess_ui/src/common/utils/helpers/helper_functions.dart';
import 'package:bess_ui/src/common/widgets/layouts/headers/header_controller.dart';
import 'package:bess_ui/src/common/widgets/loaders/circular_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart'; // For LucideIcons

import '../../../constants/colors.dart';
// import '../../../constants/enums.dart'; // ImageType was here, but BessRoundedImage is removed
import '../../../constants/sizes.dart';
import '../../../utils/device/device_utility.dart';

class BessHeader extends StatelessWidget implements PreferredSizeWidget {
  const BessHeader({super.key, this.scaffoldKey});

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    // Get.put will create the controller if it doesn't exist,
    // or find it if it already does.
    // For a shared controller like this, ensure it's put higher in the widget tree
    // if other widgets also need to access it, or manage its lifecycle appropriately.
    // If it's only for this header, Get.put here is fine.
    final HeaderController controller = Get.put(HeaderController());

    return Container(
      decoration: BoxDecoration(
          color: BessColors.core,
          border: Border(bottom: BorderSide(color: BessColors.semiLow, width: 1))),
      padding: const EdgeInsets.symmetric(horizontal: BessSizes.md, vertical: BessSizes.sm),
      child: AppBar(
        backgroundColor: Colors.transparent,
        leading: !BessDeviceUtils.isDesktopScreen(context)
            ? IconButton(
            onPressed: () => scaffoldKey?.currentState?.openDrawer(),
            icon: const Icon(LucideIcons.menu))
            : null,
        actions: [
          // Use Obx to reactively build the UI based on controller's state
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: BessSizes.md),
                child: CircularProgressIndicator(), // Keep loader compact
              );
            }

            if (controller.error.value.isNotEmpty) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.triangleAlert, color: BessColors.red, size: 24),
                  const SizedBox(width: BessSizes.sm),
                  if (!BessDeviceUtils.isMobileScreen(context))
                    Text('Error', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: BessColors.error)),
                  const SizedBox(width: BessSizes.md), // Ensure some spacing
                ],
              );
            }

            // currentUser.value could still be null if no error but user not found
            if (controller.currentUser.value == null) {
              return Row( // Fallback if user is null but not an error/loading state
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container( // Placeholder avatar
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: BessColors.primary.withAlpha(50),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('?', style: TextStyle(color: BessColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: BessSizes.sm),
                  if (!BessDeviceUtils.isMobileScreen(context))
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Guest', style: Theme.of(context).textTheme.titleLarge),
                        Text('User', style: Theme.of(context).textTheme.labelMedium),
                      ],
                    ),
                  const SizedBox(width: BessSizes.md),
                ],
              );
            }

            // If data is available and no error
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: BessColors.primary.withOpacity(0.2), // Example color
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      controller.userInitial, // Use reactive getter
                      style: BessTextStyles.tableHeader?.copyWith(color: BessColors.primary) ??
                          TextStyle(color: BessColors.primary, fontSize: 18, fontWeight: FontWeight.bold), // Fallback style
                    ),
                  ),
                ),
                const SizedBox(width: BessSizes.sm),
                if (!BessDeviceUtils.isMobileScreen(context))
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(controller.userFullName, // Use reactive getter
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(BessHelperFunctions.toTitleCase(controller.userRoleName), // Use reactive getter
                          style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                const SizedBox(width: BessSizes.md), // Consistent spacing
              ],
            );
          }),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(BessDeviceUtils.getAppBarHeight() + 17);
}