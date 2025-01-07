import '../../data/models/camper.dart';
import '../../data/models/roster.dart';

class RosterUtils {
  static Camper? getCamperByNameFromRoster(Roster roster, String fullName) {
    for (Camper camper in roster.campers.values) {
      if (camper.fullName == fullName) {
        return camper;
      }
    }
    return null; // TODO: Error checking, throw camper not found
  }

  static void addCamperToRoster(Roster roster, Camper camperToAdd) {
    roster.campers[camperToAdd.id] = camperToAdd;
    roster.updateTimestamp();
  }

  static void removeCamperFromRoster(Roster roster, Camper camperToRemove) {
    roster.campers.remove(camperToRemove.id);
    roster.updateTimestamp();
  }
}