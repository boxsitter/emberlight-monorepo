import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:get/get.dart';

class CabinService extends GetxService {
  BackendInterface backend = BackendManager.instance;
  RequestService requestService = Get.find<RequestService>();

  Future<Set<CabinDependent>> get cabinsInUse async => await backend.getObjectsInCollection('cabin_dependent', 'ses',);
  Future<Set<PrincipalCabin>> get branchCabins async => await backend.getObjectsInCollection('branch_cabin', 'brn');

  Future<String?> getCabinDependentIdByName(String name) async {
    return await backend.queryField('cabin_dependent', 'ses', 'name', name);
  }

  Future<Set<Camper>> getCampersInCabin(String id) async {
    Set<String> camperIds = await backend.getSetFieldValue(id, 'camperRefs');
    return await backend.getObjects(camperIds);
  }

  Future<Map<String, String>> getPrincipalCabinNames() async {
    final rawData = await backend.getFieldFromCollection('principal_cabin', 'brn', 'name');
    Map<String, String> valuesToString = rawData.map((key, value) => MapEntry(key, value as String));
    return valuesToString;
  }

  Future<Map<String, String>> getCabinDependentIdsToPrincipalIds() async {
    final rawData = await backend.getFieldFromCollection('cabin_dependent', 'ses', 'principalPar');
    Map<String, String> valuesToString = rawData.map((key, value) => MapEntry(key, value as String));
    return valuesToString;
  }

  Future<Set<String>> getRegisteredPrincipalCabinIds() async {
    final rawData = await backend.getFieldFromCollection('cabin_dependent', 'ses', 'principalPar');
    Set<dynamic> dynamicSet = rawData.values.toSet();
    Set<String> stringSet = {};
    for (var item in dynamicSet) {
      stringSet.add(item as String);
    }
    return stringSet;
  }

  void createPrincipalCabin(PushRequest pushRequest, String name, int capacity) {
    PrincipalCabin cabinToCreate = PrincipalCabin(
      name: name,
      capacity: capacity,
    );
    pushRequest.addObject(cabinToCreate);
  }

  // Future<DeleteRequest> deleteBranchCabin() {
  //   // TODO: implement this
  // }

  Future<void> registerCabinToSession(PushRequest pushRequest, PrincipalCabin principalCabin) async {
    if ((await getRegisteredPrincipalCabinIds()).contains(principalCabin.id)) {
      print('This cabin is already registered to this session');
      return;
    }
    CabinDependent cabinToRegister = CabinDependent(principalPar: principalCabin.id, name: principalCabin.name, capacity: principalCabin.capacity);
    pushRequest.addObject(cabinToRegister);
  }

  Future<void> registerCabinToSessionFromId(PushRequest pushRequest, String principalCabinId) async {
    PrincipalCabin principalCabin = await backend.getObject(principalCabinId);
    await registerCabinToSession(pushRequest, principalCabin);
  }

  // Future<DeleteRequest> unregisterCabinDependent() {
  //   // TODO: implement this
  // }

  Future<void> addCamperToCabin(PushRequest pushRequest, CabinDependent cabinDependent, PrincipalCabin principalCabin, Camper camperToAdd) async {
    CabinDependent cabinDependent = pushRequest.getObject(id: cabinDependent.id) ?? await backend.getObject(cabinDependentId);
    if((cabinDependent.camperRefs.length + 1) > cabinDependent.capacity) {
      //TODO: Over capacity conflict
      throw StateError('Can\'t add camper: ${camperToAdd.fullName} to cabin ${cabinDependent.name} because it will put it over capacity');
    } else if (camperToAdd.cabinRef == null) {
      cabinDependent.camperRefs.add(camperToAdd.id);
      camperToAdd.cabinRef = cabinDependent.id;
      camperToAdd.cabinName = cabinDependent.name;
      pushRequest.addObject(cabinDependent);
      pushRequest.addObject(camperToAdd);
    } else {
      removeCamperFromCabin(pushRequest, cabinDependent, camperToAdd);
      addCamperToCabin(pushRequest, cabinDependentId, camperToAdd);
    }
  }

  void removeCamperFromCabin(PushRequest pushRequest, CabinDependent cabinDependent, Camper camperToRemove) {
    cabinDependent.camperRefs.remove(camperToRemove.id);
    camperToRemove.cabinRef = null;
    camperToRemove.cabinName = null;
    pushRequest.addObject(cabinDependent);
    pushRequest.addObject(camperToRemove);
  }


}
