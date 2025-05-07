import 'dart:math';
import 'package:ember_core/ember_core_services.dart';
import 'package:get/get.dart';

import '../../ember_core_backend.dart';
import '../../ember_core_models.dart';
import '../backend/backend_manager.dart';


class ActivityPreferenceService extends GetxService {
  CoreBackend backend = BackendManager.instance;
  SessionRosterService sessionRosterService = Get.find<SessionRosterService>();

  // follows the rules of the simple assignment algorithm
  Future<void> setRanking ({
    required Commit commit,
    required CamperId camperId,
    required List<PrincipalActivityId> orderedPrincipalActivityIds,
  }) async {
    Camper camper = commit.getObject(camperId) ?? await backend.getObject(camperId);
    CabinDependent camperCabin = commit.getObject(camper.cabinRef!) ?? await backend.getObject(camper.cabinRef!);

    int position = 0;
    int totalPositions = orderedPrincipalActivityIds.length - 1;
    List<PrincipalActivityId> invertedList = orderedPrincipalActivityIds.reversed.toList();
    for (PrincipalActivityId principalActivityId in invertedList) {
      camper.preferenceRefs[principalActivityId] = position / totalPositions;
      position++;
    }

    camperCabin.campersWithPreferences.add(camper.id);

    commit.addObjectsToPush({camper, camperCabin});
  }

  Future<void> clearPreference(Commit commit, CamperId camperId) async {
    Camper camper = commit.getObject(camperId) ?? await backend.getObject(camperId);
    CabinDependent camperCabin = commit.getObject(camper.cabinRef!) ?? await backend.getObject(camper.cabinRef!);

    camper.preferenceRefs.forEach((key, value) {
      camper.preferenceRefs[key] = null;
      camper.preferenceWeightRefs[key] = 0;
    });

    camperCabin.campersWithPreferences.remove(camperId);

    commit.addObjectsToPush({camper, camperCabin});

  }

  // assigns all campers a random preference for each activity
  // for testing
  Future<void> rankRandom(Commit commit) async {
    final _ = Random();
    Set<Camper> campers = await sessionRosterService.registeredCampers;
  }

  Future<PrincipalActivity> getPrincipalActivity(PrincipalActivityId id) {
    return backend.getObject(id);
  }
}