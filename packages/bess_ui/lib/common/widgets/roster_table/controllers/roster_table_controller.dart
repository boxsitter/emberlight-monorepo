import 'package:get/get.dart';

import '../../../../data/models/camper.dart';
import '../../../../data/models/roster.dart';

class RosterTableController extends GetxController {
  final Roster roster;
  var campers = <String, Camper>{}.obs;

  RosterTableController(this.roster);

  @override
  void onInit() {
    super.onInit();
    campers.assignAll(roster.campers);
  }
}

