import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../common/widgets/layouts/templates/site_layout.dart';
import '../../common/widgets/roster_table/controllers/roster_table_controller.dart';
import '../../common/widgets/roster_table/roster_table.dart';
import '../../data/models/local_data.dart';

class SessionRoster extends StatelessWidget {
  const SessionRoster({super.key});

  @override
  Widget build(BuildContext context) {
    return BessSiteTemplate(desktop: SessionRosterDesktop());
  }
}

class SessionRosterDesktop extends StatelessWidget {
  final LocalData localData = Get.find<LocalData>();

  SessionRosterDesktop({super.key});
  
  final List<String> columns = ["Name", "Preferred Name", "Gender", "Age", "Cabin"];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BessRosterTable(
        tableTitle: 'Session Master Roster',
        columns: columns,
        controller: Get.put(
            RosterTableController(localData.session!.sessionRoster),
            tag: "MasterRosterPageTable"
        ),
      ),
    );
  }
}