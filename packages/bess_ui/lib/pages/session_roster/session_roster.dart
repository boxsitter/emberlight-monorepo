import 'package:bessie/common/widgets/data_table/controllers/data_table_controller.dart';
import 'package:bessie/common/widgets/data_table/data_table.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../common/widgets/layouts/templates/site_layout.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Button with a margin
        Container(
          margin: const EdgeInsets.only(bottom: 16.0), // Adjust the margin as needed
          child: ShadButton.secondary(
            enabled: true,

            child: const Text('Primary'),
            onPressed: () {},
          )
        ),

        // Data Table
        Expanded(
          child: BessDataTable(
            columns: columns,
            controller: Get.put(
              DataTableController(localData.session!.sessionRoster),
              tag: "MasterRosterPageTable"
            ),
          ),
        ),
      ],
    );
  }
}