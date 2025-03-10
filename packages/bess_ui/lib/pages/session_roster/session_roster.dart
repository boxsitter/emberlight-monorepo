import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/layouts/templates/site_layout.dart';
import '../../common/widgets/roster_table/controllers/roster_table_controller.dart';
import '../../common/widgets/roster_table/roster_table.dart';
import '../../data/models/delete_this_old_localdata.dart';
import '../../data/models/roster.dart';

class SessionRoster extends StatelessWidget {
  const SessionRoster({super.key});

  @override
  Widget build(BuildContext context) {
    return BessSiteTemplate(desktop: SessionRosterDesktop());
  }
}

class SessionRosterDesktop extends StatelessWidget {

  SessionRosterDesktop({super.key});
  
  final List<String> columns = ["Name", "Preferred Name", "Gender", "Age", "Cabin"];

  @override
  Widget build(BuildContext context) {
    return BessRosterTable(
      tableTitle: 'Session Master Roster',
      columns: columns,
      controller: Get.put(
          RosterTableController(Roster(title: 'DELETE THIS DUMMY ROSTER')),
          tag: "MasterRosterPageTable"
      ),
    );
  }
}