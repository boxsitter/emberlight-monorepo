import 'dart:math';
import 'package:ember_core/ember_core_services.dart';
import 'package:get/get.dart';

import '../../ember_core_backend.dart';
import '../../ember_core_models.dart';


class ActivitySignupService extends GetxService {
  BackendInterface backend = BackendManager.instance;
  SessionRosterService sessionRosterService = Get.find<SessionRosterService>();

  Future<Set<CamperPreference>> getCamperPreferences() async {
    Set<Camper> campers = await sessionRosterService.registeredCampers;
    Set<CamperPreference> output = {};

    for (Camper camper in campers) {
      try {
        CamperPreference preference = await backend.getObject(camper.camperPreferenceCmp!);
        output.add(preference);
      } catch (error) {
        print("Error fetching preference for camper ${camper.id /* or other identifier */}: $error");
      }
    }

    // Return the populated set (implicitly wrapped in a Future by the async keyword)
    return output;
  }

  // follows the rules of the simple assignment algorithm
  Future<void> setRanking ({
    required Commit commit,
    required CamperId camperId,
    required List<PrincipalActivityId> orderedPrincipalActivityIds,
  }) async {
    Camper camper = commit.getObject(camperId) ?? await backend.getObject(camperId);
    CamperPreference camperPreference = commit.getObject(camper.camperPreferenceCmp!) ?? await backend.getObject(camper.camperPreferenceCmp!);
    CabinDependent camperCabin = commit.getObject(camper.cabinRef!) ?? await backend.getObject(camper.cabinRef!);

    int position = 0;
    int totalPositions = orderedPrincipalActivityIds.length - 1;
    for (PrincipalActivityId principalActivityId in orderedPrincipalActivityIds) {
      camperPreference.preferenceRefs[principalActivityId] = position / totalPositions;
      position++;
    }

    camperPreference.completed = true;
    camper.camperPreferenceCompleted = true;
    camperCabin.campersWithPreferences[camper.id] = camperPreference.id;

    commit.addObjectsToPush({camperPreference, camper, camperCabin});
  }

  Future<void> clearPreference(Commit commit, CamperId camperId) async {
    Camper camper = commit.getObject(camperId) ?? await backend.getObject(camperId);
    CamperPreference camperPreference = commit.getObject(camper.camperPreferenceCmp!) ?? await backend.getObject(camper.camperPreferenceCmp!);
    CabinDependent camperCabin = commit.getObject(camper.cabinRef!) ?? await backend.getObject(camper.cabinRef!);

    camperPreference.preferenceRefs.forEach((key, value) {
      camperPreference.preferenceRefs[key] = null;
      camperPreference.preferenceWeightRefs[key] = 0;
    });

    camperPreference.completed = false;
    camper.camperPreferenceCompleted = false;
    camperCabin.campersWithPreferences.remove(camperId);

    commit.addObjectsToPush({camperPreference, camper, camperCabin});

  }

  // assigns all campers a random preference for each activity
  // for testing
  Future<void> rankRandom(Commit commit) async {
    final random = Random();
    Set<CamperPreference> camperPreferences = await getCamperPreferences();

    for (CamperPreference camperPreference in camperPreferences) {
      for (PrincipalActivityId principalActivityId in camperPreference.preferenceRefs.keys) {
        double randomValue = random.nextDouble();
        camperPreference.preferenceRefs[principalActivityId] = randomValue;
      }
      Camper camper = commit.getObject(camperPreference.camperRef) ?? await backend.getObject(camperPreference.camperRef);
      CabinDependent camperCabin = commit.getObject(camper.cabinRef!) ?? await backend.getObject(camper.cabinRef!);
      camperPreference.completed = true;
      camper.camperPreferenceCompleted = true;
      camperCabin.campersWithPreferences[camper.id] = camperPreference.id;
      commit.addObjectsToPush({camperPreference, camper, camperCabin});
    }
  }
}