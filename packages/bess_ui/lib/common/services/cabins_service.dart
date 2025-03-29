import 'package:bessie/data/models/session.dart';
import 'package:get/get.dart';

import '../../data/models/cabin.dart';
import '../../data/models/camper.dart';
import '../../data/repositories/bess_object_repository.dart';
import 'client_context_service.dart';

class CabinsService extends GetxService {
  BessObjectRepository bessObjectRepo= Get.find<BessObjectRepository>();
  ClientContextService clientContextService = Get.find<ClientContextService>();

  Future<Set<CabinId>> get cabinsInUseIds async => await (bessObjectRepo.getSetField(clientContextService.sessionId, 'cabinsInUseIds'));
  Future<Set<Cabin>> get cabins async => await bessObjectRepo.getObjects(await cabinsInUseIds, Cabin.fromJson);

  Future<String?> getCabinIdByName(String name) async {
    Session session = await bessObjectRepo.getObject(clientContextService.sessionId, Session.fromJson);
    return await bessObjectRepo.getFirstMatchingId(session.cabinsInUseIds, 'name', name);
  }

  Future<Set<Camper>> getCampersInCabin(String id) async {
    Set<String> camperIds = await bessObjectRepo.getSetField(id, 'camperIds');
    return await bessObjectRepo.getObjects(camperIds, Camper.fromJson);
  }

  // TODO: This method should be replaced eventually
  // TODO: You create cabin templates for the branch and ADD them to the session
  void createCabinForSession(String name, int capacity) {
    Cabin cabinToCreate = Cabin(
      name: name,
      capacity: capacity,
    );
    bessObjectRepo.pushObject(cabinToCreate);
  }

  Future<void> removeCabinFromSession(String cabinToRemoveId, String? alternativeCabinId) async {
    Set<String> campersInCabinToRemove = (await bessObjectRepo.getFieldValue(cabinToRemoveId, 'camperIds') as List<String>).toSet();
    for (String camperId in campersInCabinToRemove) {
      if (alternativeCabinId != null) {
        addCamperToCabin(alternativeCabinId, camperId);
      } else {
        removeCamperFromCabin(cabinToRemoveId, camperId);
      }
    }
    Session session = await bessObjectRepo.getObject(clientContextService.sessionId, Session.fromJson);
    session.cabinsInUseIds.remove(cabinToRemoveId);

    bessObjectRepo.pushObject(session);
    bessObjectRepo.deleteDocument(cabinToRemoveId);
  }

  Future<void> addCamperToCabin(String cabinId, String camperId) async {
    // TODO: Needs to check if that cabin is in use for the current session
    Cabin cabin = await bessObjectRepo.getObject(cabinId, Cabin.fromJson);
    Camper camperToAdd = await bessObjectRepo.getObject(camperId, Camper.fromJson);
    if((cabin.camperIds.length + 1) > cabin.capacity) {
      //TODO: Over capacity conflict
    } else if (camperToAdd.cabinId == null) {
      cabin.camperIds.add(camperToAdd.id);
      camperToAdd.cabinId = cabin.id;
      camperToAdd.cabinName = cabin.name;
      bessObjectRepo.pushObject(cabin);
      bessObjectRepo.pushObject(camperToAdd);
    } else {
      removeCamperFromCabin(cabinId, camperId);
      addCamperToCabin(cabinId, camperId);
    }
  }

  Future<void> removeCamperFromCabin(String cabinId, String camperId) async {
    // TODO: Needs to check if that cabin is in use for the current session
    Cabin cabin = await bessObjectRepo.getObject(cabinId, Cabin.fromJson);
    Camper camperToRemove = await bessObjectRepo.getObject(camperId, Camper.fromJson);
    cabin.camperIds.remove(camperToRemove.id);
    camperToRemove.cabinId = null;
    camperToRemove.cabinName = null;
    bessObjectRepo.pushObject(cabin);
    bessObjectRepo.pushObject(camperToRemove);
  }


}
