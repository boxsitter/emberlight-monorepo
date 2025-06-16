import 'package:ember_core/ember_core_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/layouts/templates/site_layout.dart';
import 'roster_table.dart';

class Rosters extends StatelessWidget {
  const Rosters({
    super.key,
    required this.rosterTableController,
  });

  final String rosterTableController;

  @override
  Widget build(BuildContext context) {
    return BessSiteTemplate(desktop: RostersDesktop());
  }
}

class RostersDesktop extends StatelessWidget {
  RostersDesktop({super.key});

  final List<RosterField> fields = [RosterField.fullName, RosterField.preferredName, RosterField.gender, RosterField.age, RosterField.cabinName];

  @override
  Widget build(BuildContext context) {
    return BessRosterTable(
      fields: fields,
      defaultTitle: 'Campers',
      controllerTag: 'session-roster-controller',
    );
  }
}