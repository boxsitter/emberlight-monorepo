import 'package:bessie/common/widgets/data_table/data_table.dart';
import 'package:flutter/material.dart';

import '../../common/widgets/layouts/templates/site_layout.dart';

class SessionRoster extends StatelessWidget {
  const SessionRoster({super.key});

  @override
  Widget build(BuildContext context) {
    return BessSiteTemplate(desktop: SessionRosterDesktop());
  }
}

class SessionRosterDesktop extends StatelessWidget {
  SessionRosterDesktop({
    super.key,
  });

  // TODO: remove temp data
  final List<Map<String, dynamic>> data = [
    {"Name": "John Doe", "Age": 25, "Cabin": "Henderson"},
    {"Name": "Jane Smith", "Age": 30, "Cabin": "Leckenby"},
  ];

  final List<String> columns = ["Name", "Age", "Cabin"];

  @override
  Widget build(BuildContext context) {
    return BessDataTable(data: data, columns: columns);
  }
}