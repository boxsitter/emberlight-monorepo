import 'package:bess_ui/common/services/popup_service.dart';
import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:get/get.dart';

import '../../../common/routes/routes.dart';

typedef CabinDependantId = String;

class ActivityPreferencesController extends GetxController {
  static CoreBackend backend = BackendManager.instance;
  final ClientContextService clientContextService = Get.find<ClientContextService>();
  final CabinService cabinsService = Get.find<CabinService>();
  final SessionRosterService sessionRosterService = Get.find<SessionRosterService>();
  final ScheduleService scheduleService = Get.find<ScheduleService>();
  final PopupService popupService = Get.find<PopupService>();
  final FrontendCommitService commitService = Get.find<FrontendCommitService>();
  final ActivityPreferenceService activityPreferenceService = Get.find<ActivityPreferenceService>();

  final RxMap<CabinDependantId, String> cabinNames = <CabinId, String>{}.obs;
  final RxMap<CabinDependantId, int> camperCounts = <CabinId, int>{}.obs;
  final RxMap<CabinDependantId, int> campersWithPreferencesCounts = <CabinId, int>{}.obs;

  Rx<String?> selectedCabinId = Rx<String?>(null);
  Rx<String?> selectedCabinName = Rx<String?>(null);
  final RxMap<CamperId, String> camperNames = <CamperId, String>{}.obs;
  final RxSet<CamperId> camperIsCompleted = <CamperId>{}.obs;
  Rx<String?> selectedCamperId = Rx<String?>(null);
  Rx<String?> selectedCamperName = Rx<String?>(null);
  final RxMap<PrincipalActivityId, String> activityNames = <PrincipalActivityId, String>{}.obs;
  final RxList<PrincipalActivityId> orderedActivityIds = <PrincipalActivityId>[].obs;

  final RxBool isCabinDataLoaded = false.obs;
  final RxBool isCamperDataLoaded = false.obs;
  final RxBool isActivityDataLoaded = false.obs;
  final RxBool saveInProgress = false.obs;

  Future<void> onCabinsLoad() async {
    cabinNames.clear();
    camperCounts.clear();
    campersWithPreferencesCounts.clear();
    isCabinDataLoaded.value = false;

    final Map<CabinDependent, PrincipalCabin> cabinsInUse = await cabinsService.getCabinDependentToPrincipalCabins();

    final names = <CabinId, String>{};
    final counts = <CabinId, int>{};
    final preferences = <CabinId, int>{};

    cabinsInUse.forEach((key, value) {
        names[key.id] = value.name;
        counts[key.id] = key.camperRefs.length;
        preferences[key.id] = key.campersWithPreferences.length;
    });

    cabinNames.addAll(names);
    camperCounts.addAll(counts);
    campersWithPreferencesCounts.addAll(preferences);
    isCabinDataLoaded.value = true;
  }

  Future<void> onSelectorLoad() async {
    if (selectedCabinName.value == null || selectedCabinId.value == null) {
      // TODO: Throw an error
      print('SelectedCabinName: ${selectedCabinName.value}, SelectedCabinId: ${selectedCabinId.value}');
      return;
    }
    print('Loaded selector screen!');
    camperNames.clear();
    camperIsCompleted.clear();
    activityNames.clear();
    orderedActivityIds.clear();
    isCamperDataLoaded.value = false;
    isActivityDataLoaded.value = false;

    final results = await Future.wait([
      cabinsService.getCampersInCabin(selectedCabinId.value!),
      clientContextService.schedule,
      scheduleService.getScheduledPrincipalActivitiesToNames(),
    ]);
    Set<Camper> campersInSelectedCabin = results[0] as Set<Camper>;
    Schedule schedule = results[1] as Schedule;
    activityNames.addAll(results[2] as Map<PrincipalActivityId, String>);

    for (Camper camper in campersInSelectedCabin) {
      camperNames[camper.id] = camper.fullName;
      if (ModelHelperFunctions.preferenceCompleted(camper, schedule)) {
        camperIsCompleted.add(camper.id);
      }
    }

    selectedCamperId.value = camperNames.keys.first;
    selectedCamperName.value = camperNames[selectedCamperId.value];
    isCamperDataLoaded.value = true;

    orderedActivityIds.addAll(await scheduleService.getOrderedActivities(selectedCamperId.value!));
    isActivityDataLoaded.value = true;
  }

  Future<void> updateActivityOrder() async {
    if (selectedCamperId.value == null || selectedCamperId.value!.isEmpty) {
      // TODO: Throw an error
      return;
    }
    isActivityDataLoaded.value = false;
    orderedActivityIds.clear();

    try {
      orderedActivityIds.addAll(await scheduleService.getOrderedActivities(selectedCamperId.value!));
    } catch (e) {
      print("Error fetching activities: $e");
      popupService.showToast(title: 'Error', message: 'Could not load activities for $selectedCabinName.value'); // TODO: This should be handled by simply throwing an error
      orderedActivityIds.clear();
    } finally {
      isActivityDataLoaded.value = true;
      print('Finished POPULATING ACTIVITY MAPS for camper: $selectedCamperId.value');
    }
  }

  // *** ADDED: Method to handle list reordering ***
  void onReorderActivities(int oldIndex, int newIndex) {
    // This logic correctly handles moving items up or down in the list
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    // Remove the item ID from the old position
    final ActivityDependentId movedItemId = orderedActivityIds.removeAt(oldIndex);
    // Insert the item ID into the new position
    orderedActivityIds.insert(newIndex, movedItemId);

    print("Reordered activities: ${orderedActivityIds.toList()}");
    // You might want to trigger a save state or indicate unsaved changes here
  }

  // *** ADDED: Method to save the current ranking ***
  Future<void> saveActivityRanking() async {
    if (selectedCamperId.value == null) {
      popupService.showToast(title: 'Error', message: 'No camper selected'); // TODO: throw an error
      return;
    }
    if (orderedActivityIds.isEmpty) {
      popupService.showToast(title: 'Info', message: 'No activities have been scheduled for this session');
      return;
    }
    saveInProgress.value = true;
    final currentRanking = orderedActivityIds.toList();
    final String currentCamperId = selectedCamperId.value!;
    final String currentCamperName = selectedCamperName.value!;

    try {
      Commit commit = Commit(disarmRequirementsLevel: 0);
      await activityPreferenceService.setRanking(
        commit: commit,
        camperId: currentCamperId,
        orderedPrincipalActivityIds: currentRanking,
      );
      await commitService.commit(commit);
      camperIsCompleted.add(currentCamperId);
      update();
      popupService.showToast(title: 'Success', message: 'Activity ranking for $currentCamperName has been saved!');
    } catch (e) {
      print("Error saving ranking: $e");
      popupService.showToast(title: 'Error', message: 'Failed to save ranking: $e');
    } finally {
      saveInProgress.value = false;
    }
    // --- End Saving Logic ---
  }

  Future<void> navigateToSelection(String cabinId, String cabinName) async {
    selectedCabinId.value = cabinId;
    selectedCabinName.value = cabinName;
    Get.toNamed(BessRoutes.activityPreferencesSelector);
  }

  // selectCamper method (ensure it calls populateActivityMaps)
  Future<void> selectCamper(String camperId, String camperName) async {
    selectedCamperId.value = camperId;
    selectedCamperName.value = camperName;
    update();
    await updateActivityOrder();
    update();
  }

  Future<void> showActivityInfo(PrincipalActivityId principalActivityId) async {
    popupService.showActivityInfo(await backend.getObject(principalActivityId));
  }

}
