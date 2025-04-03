import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:get/get.dart';

class CabinService extends GetxService {
  static BackendInterface backend = BackendManager.instance;
  RequestService requestService = Get.find<RequestService>();

  Future<Set<CabinInUse>> get cabinsInUse async => await backend.getObjectsInCollection('cabin_in_use', 'ses', CabinInUse.fromJson);
  Future<Set<BranchCabin>> get branchCabins async => await backend.getObjectsInCollection('branch_cabin', 'brn', BranchCabin.fromJson);

  Future<String?> getCabinRefByName(String name) async {
    return await backend.queryField('cabin_in_use', 'ses', 'name', name);
  }

  Future<Set<Camper>> getCampersInCabin(String id) async {
    Set<String> camperIds = await backend.getSetFieldValue(id, 'camperRefs');
    return await backend.getObjects(camperIds, Camper.fromJson);
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
      cabinInUse.camperRefs.add(IdFunctions.objIdToRef(camperToAdd.objId));
      camperToAdd.cabinRef = IdFunctions.objIdToRef(cabinInUse.objId);
      camperToAdd.cabinName = cabinInUse.name;
      return PushRequest(disarmRequirementsLevel: 0, objectsToPush: {cabinInUse, camperToAdd});
    } else {
      PushRequest removeRequest = removeCamperFromCabin(cabinInUse, camperToAdd);
      PushRequest addRequest = addCamperToCabin(cabinInUse, camperToAdd);
      return requestService.mergeRequests(removeRequest, addRequest, 2);
    }
  }

  PushRequest removeCamperFromCabin(CabinInUse cabinInUse, Camper camperToRemove) {
    cabinInUse.camperRefs.remove(IdFunctions.objIdToRef(camperToRemove.objId));
    camperToRemove.cabinRef = null;
    camperToRemove.cabinName = null;
    return PushRequest(disarmRequirementsLevel: 0, objectsToPush: {cabinInUse, camperToRemove});
  }


}
