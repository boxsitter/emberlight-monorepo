import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:get/get.dart';

class CabinService extends GetxService {
  static BackendInterface backend = BackendManager.instance;
  RequestService requestService = Get.find<RequestService>();

  Future<Set<CabinDependant>> get cabinsInUse async => await backend.getObjectsInCollection('cabin_dependant', 'ses',);
  Future<Set<PrincipalCabin>> get branchCabins async => await backend.getObjectsInCollection('branch_cabin', 'brn');

  Future<String?> getCabinRefByName(String name) async {
    return await backend.queryField('cabin_dependant', 'ses', 'name', name);
  }

  Future<Set<Camper>> getCampersInCabin(String id) async {
    Set<String> camperIds = await backend.getSetFieldValue(id, 'camperRefs');
    return await backend.getObjects(camperIds);
  }

  PushRequest createBranchCabin(String name, int capacity) {
    PrincipalCabin cabinToCreate = PrincipalCabin(
      name: name,
      capacity: capacity,
    );

    return PushRequest(disarmRequirementsLevel: 0, objectsToPush: {cabinToCreate});
  }

  // Future<DeleteRequest> deleteBranchCabin() {
  //   // TODO: implement this
  // }

  PushRequest registerCabinToSession(PrincipalCabin branchCabin) {
    CabinDependant cabinToRegister = CabinDependant(principalPar: branchCabin.id, name: branchCabin.name, capacity: branchCabin.capacity);
    return PushRequest(disarmRequirementsLevel: 0, objectsToPush: {cabinToRegister});
  }

  // Future<DeleteRequest> unregisterCabinDependant() {
  //   // TODO: implement this
  // }

  PushRequest addCamperToCabin(CabinDependant cabinDependant, Camper camperToAdd) {
    if((cabinDependant.camperRefs.length + 1) > cabinDependant.capacity) {
      //TODO: Over capacity conflict
      throw StateError('Can\'t add camper: ${camperToAdd.fullName} to cabin ${cabinDependant.name} because it will put it over capacity');
    } else if (camperToAdd.cabinRef == null) {
      cabinDependant.camperRefs.add(camperToAdd.id);
      camperToAdd.cabinRef = cabinDependant.id;
      camperToAdd.cabinName = cabinDependant.name;
      return PushRequest(disarmRequirementsLevel: 0, objectsToPush: {cabinDependant, camperToAdd});
    } else {
      PushRequest removeRequest = removeCamperFromCabin(cabinDependant, camperToAdd);
      PushRequest addRequest = addCamperToCabin(cabinDependant, camperToAdd);
      return RequestUtils.mergeRequests(removeRequest, addRequest, 2);
    }
  }

  PushRequest removeCamperFromCabin(CabinDependant cabinDependant, Camper camperToRemove) {
    cabinDependant.camperRefs.remove(camperToRemove.id);
    camperToRemove.cabinRef = null;
    camperToRemove.cabinName = null;
    return PushRequest(disarmRequirementsLevel: 0, objectsToPush: {cabinDependant, camperToRemove});
  }


}
