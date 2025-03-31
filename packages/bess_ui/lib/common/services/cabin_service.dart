import 'package:bessie/common/utils/validators/bess_id_validation.dart';
import 'package:bessie/data/bess_objects/cabin_in_use.dart';
import 'package:bessie/data/bess_objects/session.dart';
import 'package:bessie/data/repositories/pull_repository.dart';
import 'package:get/get.dart';

import '../../data/bess_objects/branch_cabin.dart';
import '../../data/bess_objects/camper.dart';
import '../../data/helper_objects/push_request.dart';
import '../../data/repositories/push_repository.dart';
import 'client_context_service.dart';

class CabinService extends GetxService {
  PullRepository pullRepo= Get.find<PullRepository>();
  ClientContextService clientContextService = Get.find<ClientContextService>();

  Future<Set<CabinInUse>> get cabinsInUse async => await pullRepo.getObjectsInCollection('cabin_in_use', 'ses', CabinInUse.fromJson);
  Future<Set<BranchCabin>> get branchCabins async => await pullRepo.getObjectsInCollection('branch_cabin', 'brn', BranchCabin.fromJson);

  Future<String?> getCabinRefByName(String name) async {
    return await pullRepo.queryField('cabin_in_use', 'ses', 'name', name);
  }

  Future<Set<Camper>> getCampersInCabin(String id) async {
    Set<String> camperIds = await pullRepo.getSetFieldValue(id, 'camperRefs');
    return await pullRepo.getObjects(camperIds, Camper.fromJson);
  }

  PushRequest createBranchCabin(String name, int capacity) {
    BranchCabin cabinToCreate = BranchCabin(
      name: name,
      capacity: capacity,
    );

    return PushRequest(disarmRequirementsLevel: 0, objectsToPush: {cabinToCreate});
  }

  // Future<DeleteRequest> deleteBranchCabin() {
  //   // TODO: implement this
  // }

  Future<PushRequest> registerCabinToSession(String branchCabinObj) async {
    if (!BessIdValidation.validateObjectType(branchCabinObj, 'branch_cabin')) {
      throw ArgumentError('branchCabinObj needs to be an obj id of type branch_cabin');
    }
    BranchCabin cabinTemplate = await pullRepo.getObject(branchCabinObj, BranchCabin.fromJson);
    CabinInUse cabinToRegister = CabinInUse(name: cabinTemplate.name, capacity: cabinTemplate.capacity);
    return PushRequest(disarmRequirementsLevel: 0, objectsToPush: {cabinToRegister});
  }

  // Future<DeleteRequest> unregisterCabinInUse() {
  //   // TODO: implement this
  // }

  Future<void> addCamperToCabin(String cabinInUseObj, String camperId) async {
    CabinInUse cabin = await pullRepo.getObject(cabinInUseObj, BranchCabin.fromJson);
    Camper camperToAdd = await pullRepo.getObject(camperId, Camper.fromJson);
    if((cabin.camperIds.length + 1) > cabin.capacity) {
      //TODO: Over capacity conflict
    } else if (camperToAdd.cabinId == null) {
      cabin.camperIds.add(camperToAdd.id);
      camperToAdd.cabinId = cabin.id;
      camperToAdd.cabinName = cabin.name;
      pushRequest.objectsToPush.add(cabin);
      pushRequest.objectsToPush.add(camperToAdd);
    } else {
      removeCamperFromCabin(cabinInUseObj, camperId);
      addCamperToCabin(cabinInUseObj, camperId);
    }
  }

  Future<void> removeCamperFromCabin(String cabinId, String camperId) async {
    // TODO: Needs to check if that cabin is in use for the current session
    BranchCabin cabin = await pullRepo.getObject(cabinId, BranchCabin.fromJson);
    Camper camperToRemove = await pullRepo.getObject(camperId, Camper.fromJson);
    cabin.camperIds.remove(camperToRemove.id);
    camperToRemove.cabinId = null;
    camperToRemove.cabinName = null;
    pushRequest.objectsToPush.add(cabin);
    pushRequest.objectsToPush.add(camperToRemove);
  }


}
