import 'package:bessie/common/feature_utils/roster_utils.dart';
import 'package:get/get.dart';

import '../../../../data/models/camper.dart';
import '../../../../data/models/roster.dart';

class DataTableController extends GetxController {
  final Roster roster;

  late RxMap<String, Camper> campers;

  DataTableController(this.roster);

  @override
  void onInit() {
    super.onInit();
    campers = RosterUtils.getCampers(roster);
  }

  void addCamper(Camper camperToAdd) {
    RosterUtils.addCamperToRoster(roster, camperToAdd);
  }

  void removeCamper(String camperId) {
    RosterUtils.removeCamperById(roster, camperId);
  }

  void updateCamper(Camper camper) {
    RosterUtils.updateCamper(roster, camper);
  }
}
