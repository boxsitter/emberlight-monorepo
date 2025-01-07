import 'package:bessie/common/utils/model_utils/roster_utils.dart';

import '../../../features/console/controller/console_controller.dart';
import '../../data/models/cabin.dart';
import '../../data/models/camper.dart';

class SessionRosterUtils {
  static void addCamperToCabin(Cabin cabin, Camper camperToAdd) {
    if((cabin.length + 1) > cabin.capacity) {
      //TODO: Over capacity conflict
      ConsoleController().error('${cabin.name} is already at capacity');
    } else if (camperToAdd.cabin == null) {
      RosterUtils.addCamperToRoster(cabin.roster, camperToAdd);
      camperToAdd.cabin = cabin;
      camperToAdd.updateTimestamp();
    } else {
      removeCamperFromCabin(camperToAdd.cabin!, camperToAdd);
      addCamperToCabin(cabin, camperToAdd);
    }
  }

  static void removeCamperFromCabin(Cabin cabin, Camper camperToRemove) {
    RosterUtils.removeCamperFromRoster(cabin.roster, camperToRemove);
    camperToRemove.cabin = null;
    camperToRemove.updateTimestamp();
  }
}