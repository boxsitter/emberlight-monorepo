import 'package:bess_ui/src/pages/rosters/widgets/rosters_table.dart';
import 'package:bess_ui/src/pages/rosters/widgets/rosters_center_actions.dart';
import 'package:bess_ui/src/pages/rosters/widgets/rosters_menu_bar.dart';
import 'package:bess_ui/src/pages/rosters/widgets/rosters_trailing_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/constants/colors.dart';
import '../../common/widgets/layouts/templates/site_layout.dart';
import 'controllers/rosters_controller.dart';

/// A stateless widget that represents the main Rosters page.
/// It uses a [BessSiteTemplate] to provide a consistent layout
/// and displays the [RostersDesktop] widget for desktop view.
class Rosters extends StatelessWidget {
  const Rosters({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RostersController>(
      builder: (controller) {
        return BessSiteTemplate(
          desktop: RostersDesktop(
            controller: controller,
          ),
          desktopPadding: false,
          tabletPadding: false,
          menuBar: buildRostersMenuBar(controller: controller),
          centerActions: buildRostersCenterActions(controller: controller),
          trailingWidgets: buildRostersTrailingWidgets(controller: controller),
        );
      }
    );
  }
}

class RostersDesktop extends StatelessWidget {
  RostersDesktop({
    super.key,
    required this.controller,
    this.screen,
  });

  final Widget? screen;
  final RostersController controller;

  @override
  Widget build(BuildContext context) {
    // 3. Wrap ONLY the part of the UI that needs to rebuild with GetBuilder.
    return Container(
      color: BessColors.core,
      child: RostersTable(controller: controller),
    );
  }
}
