import 'package:get/get.dart';

import '../../../../data/models/camper.dart';
import '../../../../data/models/roster.dart';
import '../../../services/roster_service.dart';

class DataTableController extends GetxController {
  final RosterService _rosterService;
  final Roster roster;

  late RxMap<String, Camper> campers;

  DataTableController(this._rosterService, this.roster);

  @override
  void onInit() {
    super.onInit();
    campers = _rosterService.getCampers(roster);
  }

  void addCamper(Camper camper) {
    _rosterService.addCamper(roster, camper);
  }

  void removeCamper(String camperId) {
    _rosterService.removeCamper(roster, camperId);
  }

  void updateCamper(Camper camper) {
    _rosterService.updateCamper(roster, camper);
  }
}
