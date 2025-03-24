import 'package:get/get.dart';

import '../../data/models/cabin.dart';
import '../../data/models/camper.dart';
import '../../data/repositories/firebase_repository.dart';
import '../feature_utils/roster_utils.dart';
import 'client_context_service.dart';

class CabinsService extends GetxService {
  FirebaseRepository firebaseRepo = Get.find<FirebaseRepository>();
  ClientContextService clientContextService = Get.find<ClientContextService>();

  // TODO: Error for cabin not existing
  Future<Cabin> getCabinById(String id) async {
    final doc = await firebaseRepo.getDocument("./cabins/$id");
    return Cabin.fromJson(doc!);
  }

  // TODO: This method should be replaced eventually
  // TODO: You create cabin templates for the branch and ADD them to the session
  void createCabinForSession(String name, int capacity) {
    Cabin cabinToCreate = Cabin(
      name: name,
      capacity: capacity,
    );
    firebaseRepo.pushObject(cabinToCreate);
  }

  void removeCabinFromSession(String cabinId) {
    firebaseRepo.deleteDocument("./cabins/$cabinId");
  }

  Future<void> addCamperToCabin(String cabinId, Camper camperId) async {
    Cabin cabin = await firebaseRepo.getObject("./cabins/$cabinId", Cabin.fromJson);
    Camper camperToAdd = await firebaseRepo.getObject("./campers/$camperId", Camper.fromJson);
    if((cabin.camperCount + 1) > cabin.capacity) {
      //TODO: Over capacity conflict
    } else if (camperToAdd.cabinId == null) {
      RosterUtils.addCamperToRoster(cabin.roster, camperToAdd);
      camperToAdd.cabinId = cabin.id;
      camperToAdd.updateTimestamp();
      firebaseRepo.pushObject(cabin);
      firebaseRepo.pushObject(camperToAdd);
    } else {
      removeCamperFromCabin(cabinId, camperId);
      addCamperToCabin(cabinId, camperId);
    }
  }

  Future<void> removeCamperFromCabin(String cabinId, Camper camperId) async {
    Cabin cabin = await firebaseRepo.getObject("./cabins/$cabinId", Cabin.fromJson);
    Camper camperToRemove = await firebaseRepo.getObject("./campers/$camperId", Camper.fromJson);
    RosterUtils.removeCamperFromRoster(cabin.roster, camperToRemove);
    camperToRemove.cabinId = null;
    camperToRemove.updateTimestamp();
    firebaseRepo.pushObject(cabin);
    firebaseRepo.pushObject(camperToRemove);
  }


}
