import 'package:bessie/common/services/popup_service.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:ember_core/ember_core_utils.dart';
import 'package:get/get.dart';

import '../../../common/routes/routes.dart';

typedef CabinId = String;

class ActivityPreferencesController extends GetxController {
  final ClientContextService clientContextService = Get.find<ClientContextService>();
  final CabinService cabinsService = Get.find<CabinService>();
  final SessionRosterService sessionRosterService = Get.find<SessionRosterService>();
  final ScheduleService scheduleService = Get.find<ScheduleService>();
  final PopupService popupService = Get.find<PopupService>();

  final RxMap<CabinId, String> cabinNames = <CabinId, String>{}.obs;
  final RxMap<CabinId, int> camperCounts = <CabinId, int>{}.obs;
  final RxMap<CabinId, int> campersWithPreferencesCounts = <CabinId, int>{}.obs;

  CabinId? selectedCabinId;
  String? selectedCabinName;
  final RxMap<CamperId, String> camperNames = <CamperId, String>{}.obs;
  final RxMap<CamperId, bool> camperIsCompleted = <CamperId, bool>{}.obs;

  CabinId? selectedCamperId;
  String? selectedCamperName;
  final RxMap<PrincipalActivityId, String> activityNames = <PrincipalActivityId, String>{}.obs;
  final RxList<PrincipalActivityId> orderedActivityIds = <PrincipalActivityId>[].obs;

  final RxBool isCabinDataLoaded = false.obs;
  final RxBool isCamperDataLoaded = false.obs;
  final RxBool isActivityDataLoaded = false.obs;

  Future<void> populateCabinMaps() async {
    isCabinDataLoaded.value = false;
    print('POPULATING CABIN MAPS');
    final Map<CabinDependent, PrincipalCabin> cabinsInUse = await cabinsService.getCabinDependentToPrincipalCabins();

    final names = <CabinId, String>{};
    final counts = <CabinId, int>{};
    final preferences = <CabinId, int>{};

    for (final CabinDependent cabin in cabinsInUse.keys) {
      names[cabin.id] = cabinsInUse[cabin]!.name;
      counts[cabin.id] = cabin.camperRefs.length;
      preferences[cabin.id] = cabin.campersWithPreferences.length;
    }

    cabinNames.value = names;
    camperCounts.value = counts;
    campersWithPreferencesCounts.value = preferences;
    isCabinDataLoaded.value = true;
  }

  Future<void> populateCamperMaps() async {
    if (selectedCabinName == null || selectedCabinId == null) {
      return;
    }
    isCamperDataLoaded.value = false;
    print('POPULATING CAMPER MAPS');
    final Set<Camper> campers = await cabinsService.getCampersInCabin(selectedCabinId!);
    final Schedule schedule = await clientContextService.schedule;

    final names = <CamperId, String>{};
    final completed = <CamperId, bool>{};

    for (final Camper camper in campers) {
      names[camper.id] = camper.fullName;
      completed[camper.id] = ModelHelperFunctions.preferenceCompleted(camper, schedule);
    }

    camperNames.value = names;
    camperIsCompleted.value = completed;
    selectedCamperId = camperNames.keys.first;
    selectedCamperName = camperNames[selectedCamperId];
    isCamperDataLoaded.value = true;
  }

  Future<void> populateActivityMaps() async {
    // Ensure state is ready before proceeding
    if (selectedCamperId == null) {
      print('No camper selected, cannot populate activities.');
      activityNames.clear();
      orderedActivityIds.clear(); // Clear order too
      isActivityDataLoaded.value = false;
      return;
    }
    isActivityDataLoaded.value = false; // Trigger loading indicator
    activityNames.clear(); // Clear previous data
    orderedActivityIds.clear(); // Clear previous order

    try {
      final names = scheduleService.getScheduledPrincipalActivitiesToNames();
      final idsInOrder = scheduleService.getOrderedActivities(selectedCamperId!);
    } catch (e) {
      print("Error fetching activities: $e");
      popupService.showToast(title: 'Error', message: 'Could not load activities for $selectedCabinName'); // TODO: This should be handled by simply throwing an error
      // Ensure lists are cleared on error
      activityNames.clear();
      orderedActivityIds.clear();
    } finally {
      isActivityDataLoaded.value = true; // Set loading complete
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

    print("Saving activity ranking for $selectedCamperId:");
    final currentRanking = orderedActivityIds.toList(); // Get current order
    print("Order: $currentRanking");

    // --- TODO: Implement actual saving logic to your backend/service ---
    try {
      // Show loading indicator? Maybe disable save button?
      // await activityService.saveRanking(selectedCamperId!, currentRanking);
      await Future.delayed(const Duration(seconds: 1)); // Simulate save
      popupService.showToast(title: 'Success', message: 'Activity ranking saved!');
      // Optionally update completion status and refresh relevant parts
      // camperIsCompleted[selectedCamperId!] = true;
      // camperIsCompleted.refresh();
    } catch (e) {
      print("Error saving ranking: $e");
      popupService.showToast(title: 'Error', message: 'Failed to save ranking: $e');
    } finally {
      // Hide loading indicator? Re-enable save button?
    }
    // --- End Saving Logic ---
  }

  void navigateToCampers(String cabinId, String cabinName) {
    selectedCabinId = cabinId;
    selectedCabinName = cabinName;
    Get.toNamed(BessRoutes.activityPreferencesCampers);
  }

  Future<void> navigateToSelection(String cabinId, String cabinName) async {
    selectedCabinId = cabinId;
    selectedCabinName = cabinName;
    populateCamperMaps();
    selectedCamperName = '';
    selectedCamperId = '';
    Get.toNamed(BessRoutes.activityPreferencesSelector);
  }

  // selectCamper method (ensure it calls populateActivityMaps)
  void selectCamper(String camperId, String camperName) {
    selectedCamperId = camperId;
    selectedCamperName = camperName;
    saveActivityRanking();
    print('Selected Camper: $selectedCamperName ($selectedCamperId)');
    populateActivityMaps(); // Fetch activities for the new camper
    update(); // Trigger GetBuilder updates (for title etc.)
  }

}
