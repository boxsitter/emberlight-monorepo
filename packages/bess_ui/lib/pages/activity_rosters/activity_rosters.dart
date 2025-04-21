import 'package:flutter/material.dart';

import '../../common/widgets/layouts/templates/site_layout.dart';

class ActivityRosters extends StatelessWidget {
  const ActivityRosters({super.key});

  @override
  Widget build(BuildContext context) {
    return BessSiteTemplate(desktop: ActivityRostersDesktop());
  }
}

class ActivityRostersDesktop extends StatelessWidget {
  ActivityRostersDesktop({super.key});

  final List<String> columns = ["Name", "Preferred Name", "Gender", "Age", "Cabin"];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

      ]
    );
  }
}
