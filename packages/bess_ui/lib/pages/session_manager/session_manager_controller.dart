import 'dart:collection';

import 'package:bessie/common/utils/helpers/helper_functions.dart';
import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:get/get.dart';

class SessionManagerController extends GetxController {
  final CabinService cabinsService = Get.find<CabinService>();
  final FrontendCommitService commitService = Get.find<FrontendCommitService>();
  // --- Observable State Variables ---

  // Use RxList for the list of cabin names so the UI reacts to changes
  // Initialize it maybe in onInit() by fetching data
  final RxMap<String, String> cabinPrinIdsToNames = <String, String>{}.obs;

  // Use RxMap to store the selection state { 'cabinName': true/false }
  final RxSet<String> selectedCabinPrinIds = <String>{}.obs;

  // Optional: Loading indicator state
  final RxBool isLoading = true.obs;

  Future<void> populate() async {
    isLoading.value = true;
    cabinPrinIdsToNames.clear();
    selectedCabinPrinIds.clear();

    Map<String, String> rawData = await cabinsService.getPrincipalCabinNames();
    List<MapEntry<String, String>> sortedEntries = rawData.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    Map<String, String> sortedMap = LinkedHashMap.fromEntries(sortedEntries);
    cabinPrinIdsToNames.assignAll(sortedMap);

    selectedCabinPrinIds.assignAll((await cabinsService.getCabinDependentIdsToPrincipalIds()).values.toSet());
    isLoading.value = false;
  }


  // Method called by the UI when a checkbox is tapped
  void toggleCabinSelection(String cabinPrinId) {
    if (selectedCabinPrinIds.contains(cabinPrinId)) {
      selectedCabinPrinIds.remove(cabinPrinId);
      print('$cabinPrinId selection is now: false');
    } else {
      selectedCabinPrinIds.add(cabinPrinId);
      print('$cabinPrinId selection is now: true');
    }
  }

  Future<void> commitSelection() async {
    Set<String> registeredPrinCabinIds = await cabinsService.getRegisteredPrincipalCabinIds();
    Commit commit = Commit(disarmRequirementsLevel: 0);

    for (String selectedCabinPrinId in selectedCabinPrinIds) {
      if (!registeredPrinCabinIds.contains(selectedCabinPrinId)) {
        await cabinsService.registerCabinToSessionFromId(commit, selectedCabinPrinId);
      }
    }

    // for each current registered cabin prin id
    for (String registeredPrinCabinId in registeredPrinCabinIds) {
      if (!selectedCabinPrinIds.contains(registeredPrinCabinId)) {
        final Map<String, String> cabinPrincipalIdsToDependentIds = BessHelperFunctions.transposeMap(await cabinsService.getCabinDependentIdsToPrincipalIds());
        commit.addObjectToDelete(commit.getObject(cabinPrincipalIdsToDependentIds[registeredPrinCabinId]) ?? await BackendManager.instance.getObject(cabinPrincipalIdsToDependentIds[registeredPrinCabinId]!));
      }
    }

    commitService.commitRequest(commit);
  }

// Add any other methods needed, like saving the state
// void saveActiveCabins() { ... }

}
