import 'package:bessie/common/styles/text_styles.dart';
import 'package:bessie/common/widgets/images/bess_circular_image.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../routes/routes.dart';
import '../../../constants//colors.dart';
import '../../../constants//image_strings.dart';
import '../../../constants//sizes.dart';
import '../../../utils/device/device_utility.dart';
import '../../context_switcher/context_display.dart';
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
                                route: BessRoutes.sessionRoster,
                                icon: LucideIcons.bookUser,
                                itemName: 'Session Roster'),
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
                            const BessMenuItem(
                                route: BessRoutes.console,
                                icon: LucideIcons.flameKindling,
                                itemName: 'Branch Manager'),
                            const BessMenuItem(
                                route: BessRoutes.responsiveDesignExample,
                                icon: LucideIcons.layoutPanelLeft,
                                itemName: 'Widgets'),
                            const BessMenuItem(
                                route: BessRoutes.console,
                                icon: LucideIcons.squareTerminal,
                                itemName: 'Console'),
                          ],
                        ),
                        const Spacer(),
                        ContextDisplay(top: '2025', bottom: 'Session A'),
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
