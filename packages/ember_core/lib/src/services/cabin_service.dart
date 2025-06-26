import 'package:get/get.dart';

import '../../ember_core.dart';
import '../repositories/pull_repository.dart';

class CabinService extends GetxService {
  CommitService requestService = Get.find<CommitService>();
  PullRepository pullRepo = Get.find<PullRepository>();

  Future<Set<CabinDependent>> get cabinDependents async => await pullRepo.getObjectsInCollection('cabin_dependent', 'ses',);
  Future<Set<PrincipalCabin>> get principalCabins async => await pullRepo.getObjectsInCollection('principal_cabin', 'brn');

  Future<String?> getCabinDependentIdByName(String name, Commit commit) async {
    String? principalId = commit.queryFieldByType(PrincipalCabin, 'name', name);
    if (principalId != null) {
      return commit.queryFieldByType(CabinDependent, 'principalPar', principalId);
    }

    // TODO: The code for caching cabins in the push request is rough, clean it up
    principalId = await pullRepo.queryField('principal_cabin', 'brn', 'name', name);
    String? output;
    if (principalId != null) {
      commit.addObjectToPush(await pullRepo.getObject(principalId));
      output =  await pullRepo.queryField('cabin_dependent', 'ses', 'principalPar', principalId);
    }

    if (output != null) {
      commit.addObjectToPush(await pullRepo.getObject(output));
    }

    return output;
  }

  Future<Set<Camper>> getCampersInCabin(String id) async {
    Set<String> camperIds = await pullRepo.getSetFieldValue(id, 'camperRefs');
    return await pullRepo.getObjects(camperIds);
  }

  Future<Map<String, String>> getPrincipalCabinNames() async {
    final rawData = await pullRepo.getFieldFromCollection('principal_cabin', 'brn', 'name');
    Map<String, String> valuesToString = rawData.map((key, value) => MapEntry(key, value as String));
    return valuesToString;
  }

  Future<PrincipalCabin> getPrincipalCabin(String id) {
    // TODO: check and make sure id points to a prin cabin
    return pullRepo.getObject(id);
  }

  Future<PrincipalCabin> getDependantCabin(String id) {
    // TODO: check and make sure id points to a cabin dep
    return pullRepo.getObject(id);
  }

  Future<Map<String, String>> getCabinDependentIdsToPrincipalIds() async {
    final rawData = await pullRepo.getFieldFromCollection('cabin_dependent', 'ses', 'principalPar');
    Map<String, String> valuesToString = rawData.map((key, value) => MapEntry(key, value as String));
    return valuesToString;
  }

  Future<Map<CabinDependent, PrincipalCabin>> getCabinDependentToPrincipalCabins() async {
    final results = await Future.wait([this.cabinDependents, this.principalCabins]);

    Set<CabinDependent> cabinDependents = results[0] as Set<CabinDependent>;
    Set<PrincipalCabin> principalCabins = results[1] as Set<PrincipalCabin>;
    Map<CabinDependent, PrincipalCabin> output = {};

    Map<String, PrincipalCabin> principalCabinsById = {
      for (var principal in principalCabins) principal.id: principal
    };

    for (var dependent in cabinDependents) {
      PrincipalCabin? matchingPrincipal = principalCabinsById[dependent.principalPar];

      if (matchingPrincipal != null) {
        output[dependent] = matchingPrincipal;
      }
    }

    // Return the resulting map
    return output;
  }

  Future<Set<String>> getRegisteredPrincipalCabinIds() async {
    final rawData = await pullRepo.getFieldFromCollection('cabin_dependent', 'ses', 'principalPar');
    Set<dynamic> dynamicSet = rawData.values.toSet();
    Set<String> stringSet = {};
    for (var item in dynamicSet) {
      stringSet.add(item as String);
    }
    return stringSet;
  }

  void createPrincipalCabin(Commit commit, String name, int capacity) {
    PrincipalCabin cabinToCreate = PrincipalCabin(
      name: name,
      capacity: capacity,
    );
    commit.addObjectToPush(cabinToCreate);
  }

  // Future<DeleteRequest> deleteBranchCabin() {
  //   // TODO: implement this
  // }

  Future<void> registerCabinToSession(Commit commit, PrincipalCabin principalCabin) async {
    if ((await getRegisteredPrincipalCabinIds()).contains(principalCabin.id)) {
      Debug.logInfo('This cabin is already registered to this session');
      return;
    }
    CabinDependent cabinToRegister = CabinDependent(principalPar: principalCabin.id);
    commit.addObjectToPush(cabinToRegister);
  }

  Future<void> registerCabinToSessionFromId(Commit commit, String principalCabinId) async {
    PrincipalCabin principalCabin = commit.getObject(principalCabinId) ?? await pullRepo.getObject(principalCabinId);
    await registerCabinToSession(commit, principalCabin);
  }

  // Future<DeleteRequest> unregisterCabinDependent() {
  //   // TODO: implement this
  // }

  Future<void> addCamperToCabin(Commit commit, CabinDependent cabinDependent, Camper camperToAdd) async {
    PrincipalCabin principalCabin = commit.getObject(cabinDependent.principalPar) ?? await pullRepo.getObject(cabinDependent.principalPar);
    if((cabinDependent.camperRefs.length + 1) > principalCabin.capacity) {
      //TODO: Over capacity conflict
      throw StateError('Can\'t add camper: ${camperToAdd.fullName} to cabin ${principalCabin.name} because it will put it over capacity');
    } else if (camperToAdd.cabinRef == null) {
      cabinDependent.camperRefs.add(camperToAdd.id);
      camperToAdd.cabinRef = cabinDependent.id;
      camperToAdd.cabinName = principalCabin.name;
      commit.addObjectToPush(cabinDependent);
      commit.addObjectToPush(camperToAdd);
    } else {
      removeCamperFromCabin(commit, cabinDependent, camperToAdd);
      addCamperToCabin(commit, cabinDependent, camperToAdd);
    }
  }

  void removeCamperFromCabin(Commit commit, CabinDependent cabinDependent, Camper camperToRemove) {
    cabinDependent.camperRefs.remove(camperToRemove.id);
    camperToRemove.cabinRef = null;
    camperToRemove.cabinName = null;
    commit.addObjectToPush(cabinDependent);
    commit.addObjectToPush(camperToRemove);
  }


}
