import 'package:bessie/common/feature_utils/roster_utils.dart';
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

  void addCamper(Camper camperToAdd) {
    RosterUtils.addCamperToRoster(roster, camperToAdd);
    campers[camperToAdd.id] = camperToAdd;
    campers.refresh();
  }

  void removeCamper(String camperId) {
    RosterUtils.removeCamperById(roster, camperId);
    campers.remove(camperId);
    campers.refresh();
  }

  void updateCamper(Camper camper) {
    RosterUtils.updateCamper(roster, camper);
    campers[camper.id] = camper;
    campers.refresh();
  }
}

