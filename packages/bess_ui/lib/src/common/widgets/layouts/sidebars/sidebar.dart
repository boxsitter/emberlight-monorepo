import 'package:bess_ui/src/common/styles/text_styles.dart';
import 'package:bess_ui/src/common/widgets/buttons/inkwell_button.dart';
import 'package:bess_ui/src/common/widgets/layouts/sidebars/sidebar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../routes/routes.dart';
import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../utils/device/device_utility.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../containers/rounded_container.dart';
import '../../context_switcher/context_display.dart';
import 'menu/menu_item.dart';

class BessSidebar extends StatelessWidget {
  const BessSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final menuController = Get.put(SidebarController());
    return Drawer(
      width: 300,
      shape: BessDeviceUtils.isDesktopScreen(context)
          ? const BeveledRectangleBorder()
          : null,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: BessColors.core,
            border: Border(right: BorderSide(color: BessColors.semiLow, width: 1)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(BessSizes.md),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - (BessSizes.md * 2)),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: BessSizes.xl),
                            Text(
                              'MENU',
                              style: BessTextStyles.lightHeader,
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                            ),
                            const SizedBox(height: BessSizes.sm),
                            const BessMenuItem(
                                route: BessRoutes.home,
                                icon: LucideIcons.house,
                                itemName: 'Home'),
                            const BessMenuItem(
                                route: BessRoutes.rosters,
                                icon: LucideIcons.bookUser,
                                itemName: 'Rosters'),
                            const BessMenuItem(
                                route: BessRoutes.activityPreferencesCabins,
                                icon: LucideIcons.listOrdered,
                                itemName: 'Activity Preferences'),
                            const BessMenuItem(
                                route: BessRoutes.schedulePage,
                                icon: LucideIcons.columns3,
                                itemName: 'Schedule'),
                            const BessMenuItem(
                                route: BessRoutes.sessionManager,
                                icon: LucideIcons.calendarCog,
                                itemName: 'Session Manager'),
                            // const BessMenuItem(
                            //     route: BessRoutes.console,
                            //     icon: LucideIcons.flameKindling,
                            //     itemName: 'Branch Manager'),
                            const BessMenuItem(
                                route: BessRoutes.console,
                                icon: LucideIcons.squareTerminal,
                                itemName: 'Console'),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BessRoundedContainer(
                              backgroundColor: BessHelperFunctions.blendColors(BessColors.crust, BessColors.red, 100),
                              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              height: 55,
                              width: 55,
                              onTap: () => menuController.logOut(),
                              child: Icon(LucideIcons.logOut, color: BessHelperFunctions.blendColors(BessColors.textPrimary, BessColors.red, 150)),
                            ),

                            SizedBox(width: BessSizes.md),

                            Expanded(child: ContextDisplay()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
