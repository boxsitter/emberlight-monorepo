import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:ember_fire/ember_fire.dart';
import 'package:get/get.dart';

class CabinService extends GetxService {
  PullRepository pullRepo= Get.find<PullRepository>();
  ClientContextService clientContextService = Get.find<ClientContextService>();
  RequestService requestService = Get.find<RequestService>();

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

  PushRequest registerCabinToSession(BranchCabin branchCabin) {
    CabinInUse cabinToRegister = CabinInUse(name: branchCabin.name, capacity: branchCabin.capacity);
    return PushRequest(disarmRequirementsLevel: 0, objectsToPush: {cabinToRegister});
  }

  // Future<DeleteRequest> unregisterCabinInUse() {
  //   // TODO: implement this
  // }

  PushRequest addCamperToCabin(CabinInUse cabinInUse, Camper camperToAdd) {
    if((cabinInUse.camperRefs.length + 1) > cabinInUse.capacity) {
      //TODO: Over capacity conflict
      throw StateError('Can\'t add camper: ${camperToAdd.fullName} to cabin ${cabinInUse.name} because it will put it over capacity');
    } else if (camperToAdd.cabinRef == null) {
      cabinInUse.camperRefs.add(BessIdFunctions.objIdToRef(camperToAdd.objId));
      camperToAdd.cabinRef = BessIdFunctions.objIdToRef(cabinInUse.objId);
      camperToAdd.cabinName = cabinInUse.name;
      return PushRequest(disarmRequirementsLevel: 0, objectsToPush: {cabinInUse, camperToAdd});
    } else {
      PushRequest removeRequest = removeCamperFromCabin(cabinInUse, camperToAdd);
      PushRequest addRequest = addCamperToCabin(cabinInUse, camperToAdd);
      return requestService.mergeRequests(removeRequest, addRequest, 2);
    }
  }

  PushRequest removeCamperFromCabin(CabinInUse cabinInUse, Camper camperToRemove) {
    cabinInUse.camperRefs.remove(BessIdFunctions.objIdToRef(camperToRemove.objId));
    camperToRemove.cabinRef = null;
    camperToRemove.cabinName = null;
    return PushRequest(disarmRequirementsLevel: 0, objectsToPush: {cabinInUse, camperToRemove});
  }


}
