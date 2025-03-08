import 'package:get/get.dart';

import '../../../../data/models/camper.dart';
import '../../../../data/models/roster.dart';

class RosterTableController extends GetxController {
  final Roster roster;
  var campers = <String, Camper>{}.obs;
  var count = 0.obs;

  RosterTableController(this.roster);

  @override
  void onInit() {
    super.onInit();
    campers.assignAll(roster.campers);
    count.value = campers.length;
    // Listen for changes on myMap and update count in real time
    ever(campers, (_) {
      count.value = campers.length;
    });
  }
}

