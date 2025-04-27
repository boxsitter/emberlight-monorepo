import 'package:bessie/common/services/popup_service.dart';
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

  CabinId? selectedCabinId;
  String? selectedCabinName;
  final RxMap<CamperId, String> camperNames = <CamperId, String>{}.obs;
  final RxSet<CamperId> camperIsCompleted = <CamperId>{}.obs;
  CamperId? selectedCamperId;
  String? selectedCamperName;
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
    if (selectedCabinName == null || selectedCabinId == null) {
      // TODO: Throw an error
      return;
    }
    camperNames.clear();
    camperIsCompleted.clear();
    activityNames.clear();
    orderedActivityIds.clear();
    isCamperDataLoaded.value = false;
    isActivityDataLoaded.value = false;

    final results = await Future.wait([
      cabinsService.getCampersInCabin(selectedCabinId!),
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

    selectedCamperId = camperNames.keys.first;
    selectedCamperName = camperNames[selectedCamperId];
    isCamperDataLoaded.value = true;

    orderedActivityIds.addAll(await scheduleService.getOrderedActivities(selectedCamperId!));
    isActivityDataLoaded.value = true;
  }

  Future<void> updateActivityOrder() async {
    if (selectedCamperId == null || selectedCamperId!.isEmpty) {
      // TODO: Throw an error
      return;
    }
    isActivityDataLoaded.value = false;
    orderedActivityIds.clear();

    try {
      orderedActivityIds.addAll(await scheduleService.getOrderedActivities(selectedCamperId!));
    } catch (e) {
      print("Error fetching activities: $e");
      popupService.showToast(title: 'Error', message: 'Could not load activities for $selectedCabinName'); // TODO: This should be handled by simply throwing an error
      orderedActivityIds.clear();
    } finally {
      isActivityDataLoaded.value = true;
      print('Finished POPULATING ACTIVITY MAPS for camper: $selectedCamperId');
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
    if (selectedCamperId == null) {
      popupService.showToast(title: 'Error', message: 'No camper selected'); // TODO: throw an error
      return;
    }
    if (orderedActivityIds.isEmpty) {
      popupService.showToast(title: 'Info', message: 'No activities have been scheduled for this session');
      return;
    }
    saveInProgress.value = true;
    final currentRanking = orderedActivityIds.toList();
    final String currentCamperId = selectedCamperId!;
    final String currentCamperName = selectedCamperName!;

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
    selectedCabinId = cabinId;
    selectedCabinName = cabinName;
    Get.toNamed(BessRoutes.activityPreferencesSelector);
  }

  // selectCamper method (ensure it calls populateActivityMaps)
  Future<void> selectCamper(String camperId, String camperName) async {
    selectedCamperId = camperId;
    selectedCamperName = camperName;
    update();
    await updateActivityOrder();
    update();
  }

  Future<void> showActivityInfo(PrincipalActivityId principalActivityId) async {
    popupService.showActivityInfo(await backend.getObject(principalActivityId));
  }

}
