import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:get/get.dart';

import '../../../common/routes/routes.dart';

typedef CabinId = String;

class ActivityPreferencesController extends GetxController {
  final ClientContextService contextService = Get.find<ClientContextService>();
  final CabinService cabinsService = Get.find<CabinService>();
  final SessionRosterService sessionRosterService = Get.find<SessionRosterService>();

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
  final RxList<ActivityDependentId> orderedActivityIds = <ActivityDependentId>[].obs;

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

    final names = <CamperId, String>{};
    final completed = <CamperId, bool>{};

    for (final Camper camper in campers) {
      names[camper.id] = camper.fullName;
      completed[camper.id] = camper.camperPreferenceCompleted;
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
    print('POPULATING ACTIVITY MAPS for camper: $selectedCamperId');

    try {
      // --- TODO: Replace with your actual data fetching logic ---
      // Fetch activities WITH an order (e.g., default, previous ranking)
      // Your fetch should ideally return List<ActivityObject> or List<MapEntry<ID, Name>>
      final List<MapEntry<ActivityDependentId, String>> fetchedData = [
        MapEntry('act-swimming-${selectedCamperId}', 'Swimming'), // Example IDs
        MapEntry('act-archery-${selectedCamperId}', 'Archery'),
        MapEntry('act-crafts-${selectedCamperId}', 'Crafts'),
        MapEntry('act-hiking-${selectedCamperId}', 'Hiking'),
      ];
      // --- End Fetching Logic ---

      final names = <ActivityDependentId, String>{};
      final idsInOrder = <ActivityDependentId>[];
      for (var entry in fetchedData) {
        names[entry.key] = entry.value;
        idsInOrder.add(entry.key);
      }
      activityNames.value = names;
      orderedActivityIds.value = idsInOrder; // Update the reactive list

    } catch (e) {
      print("Error fetching activities: $e");
      Get.snackbar("Error", "Could not load activities.");
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
      Get.snackbar('Error', 'No camper selected.');
      return;
    }
    if (orderedActivityIds.isEmpty) {
      Get.snackbar('Info', 'No activities to rank.');
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
      Get.snackbar('Success', 'Activity ranking saved!');
      // Optionally update completion status and refresh relevant parts
      // camperIsCompleted[selectedCamperId!] = true;
      // camperIsCompleted.refresh();
    } catch (e) {
      print("Error saving ranking: $e");
      Get.snackbar('Error', 'Failed to save ranking: $e');
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
