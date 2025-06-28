import 'package:bess_ui/src/pages/rosters/widgets/activity_switcher.dart';
import 'package:bess_ui/src/pages/rosters/widgets/column_config.dart';
import 'package:bess_ui/src/pages/rosters/widgets/header_builders.dart';
import 'package:bess_ui/src/pages/rosters/widgets/roster_importer.dart';
import 'package:bess_ui/src/pages/rosters/widgets/rosters_table.dart';
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
    return GetBuilder<RostersController>(builder: (controller) {
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
    });
  }
}

class RostersDesktop extends StatelessWidget {
  RostersDesktop({
    super.key,
    required this.controller,
  });

  final RostersController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BessColors.core,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (controller.columnConfigOpened)
            ColumnConfig(controller: controller),

          if (controller.activitySwitcherOpened)
            ActivitySwitcher(controller: controller),

          Expanded(child: RostersTable(controller: controller)),
        ],
      ),
    );
  }
}
