import 'package:get/get.dart';

import '../../../../data/models/camper.dart';
import '../../../../data/models/roster.dart';

class DataTableController extends GetxController {
  final Roster roster;
  var campers = <String, Camper>{}.obs;

  DataTableController(this.roster);

  @override
  void onInit() {
    super.onInit();
    campers.assignAll(roster.campers);
  }
}

