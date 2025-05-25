import 'package:ember_core/ember_core_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/layouts/templates/site_layout.dart';
import '../../common/widgets/roster_table/controllers/roster_table_controller.dart';
import '../../common/widgets/roster_table/roster_table.dart';

class SessionRoster extends StatelessWidget {
  const SessionRoster({super.key});

  @override
  Widget build(BuildContext context) {
    return BessSiteTemplate(desktop: SessionRosterDesktop());
  }
}

class SessionRosterDesktop extends StatelessWidget {
  SessionRosterDesktop({super.key});

  final List<RosterField> fields = [RosterField.fullName, RosterField.preferredName, RosterField.gender, RosterField.age, RosterField.cabinName];

  @override
  Widget build(BuildContext context) {
    RosterTableController controller = Get.find<RosterTableController>();
    controller.initializeColumns(fields);

    return BessRosterTable(
      tableTitle: 'Session Master Roster',
      fields: fields,
      controller: controller,
    );
  }
}