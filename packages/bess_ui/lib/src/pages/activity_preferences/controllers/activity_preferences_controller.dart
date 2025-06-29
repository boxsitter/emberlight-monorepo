import 'package:bess_ui/src/common/services/popup_service.dart';
import 'package:ember_core/ember_core.dart';
import 'package:get/get.dart';

import '../../../common/mixins/route_aware_controller_mixin.dart';
import '../../../common/routes/routes.dart';

typedef CabinDependantId = String;

class ActivityPreferencesController extends GetxController with RouteAwareControllerMixin {
  final ContextService clientContextService = Get.find<ContextService>();
  final CabinService cabinsService = Get.find<CabinService>();
  final RosterService rosterService = Get.find<RosterService>();
  final ScheduleService scheduleService = Get.find<ScheduleService>();
  final PopupService popupService = Get.find<PopupService>();
  final ActivityPreferenceService activityPreferenceService = Get.find<ActivityPreferenceService>();
  final CommitRepository commitRepo = Get.find<CommitRepository>();

  // --- State Variables ---
  Map<CabinDependantId, String> cabinNames = {};
  Map<CabinDependantId, int> camperCounts = {};
  Map<CabinDependantId, int> campersWithPreferencesCounts = {};

  String? selectedCabinId;
  String? selectedCabinName;

  List<Camper> campers = [];
  Set<Camper> camperIsCompleted = {};
  Camper? selectedCamper;

  Map<PrincipalActivityId, String> standardActivityNames = {};
  Map<PrincipalActivityId, String> skillsActivityNames = {};
  List<PrincipalActivityId> orderedStandardActivityIds = [];
  List<PrincipalActivityId> orderedSkillsActivityIds = [];

  bool isCabinDataLoaded = false;
  bool isCamperDataLoaded = false;
  bool isActivityDataLoaded = false;
  bool saveInProgress = false;

  /// Determines which data to load based on whether a cabin has been selected.
  @override
  void onNavigateTo(String to, String? from) {
    if (to == BessRoutes.activityPreferencesCabins) {
      _loadCabinsData();
    } else {
      _loadSelectorData();
    }
  }

  @override
  void onNavigateFrom(String from, String to) {
    // Nothing here
  }

  Future<void> _loadCabinsData() async {
    isCabinDataLoaded = false;
    update();

    final Map<CabinDependent, PrincipalCabin> cabinsInUse = await cabinsService.getCabinDependentToPrincipalCabins();

    final names = <CabinId, String>{};
    final counts = <CabinId, int>{};
    final preferences = <CabinId, int>{};

    for (var entry in cabinsInUse.entries) {
      names[entry.key.id] = entry.value.name;
      counts[entry.key.id] = entry.key.camperRefs.length;
      preferences[entry.key.id] = entry.key.campersWithPreferences.length;
    }

    cabinNames = names;
    camperCounts = counts;
    campersWithPreferencesCounts = preferences;
    isCabinDataLoaded = true;
    update();
  }

  Future<void> _loadSelectorData() async {
    if (selectedCabinName == null || selectedCabinId == null) {
      Debug.logInfo('SelectedCabinName: $selectedCabinName, SelectedCabinId: $selectedCabinId');
      return;
    }
    Debug.logInfo('Loaded selector screen!');
    // Reset state for the selector screen
    isCamperDataLoaded = false;
    isActivityDataLoaded = false;
    campers = [];
    camperIsCompleted = {};
    skillsActivityNames = {};
    orderedStandardActivityIds = [];
    orderedSkillsActivityIds = [];
    update();

    final results = await Future.wait([
      cabinsService.getCampersInCabin(selectedCabinId!),
      clientContextService.schedule,
      scheduleService.getScheduledPrincipalActivitiesToNames(false),
      scheduleService.getScheduledPrincipalActivitiesToNames(true),
    ]);

    final List<Camper> campersInSelectedCabin = (results[0] as Set<Camper>).toList();
    final Schedule schedule = results[1] as Schedule;
    standardActivityNames = results[2] as Map<PrincipalActivityId, String>;
    skillsActivityNames = results[3] as Map<PrincipalActivityId, String>;

    for (Camper camper in campersInSelectedCabin) {
      if (ModelHelperFunctions.preferenceCompleted(camper, schedule)) {
        camperIsCompleted.add(camper);
      }
    }
    campers = campersInSelectedCabin;


    if (campers.isNotEmpty) {
      selectedCamper = campers.first;
    }

    isCamperDataLoaded = true;
    update();

    await updateActivityOrder();

    isActivityDataLoaded = true;
    update();
  }

  Future<void> updateActivityOrder() async {
    if (selectedCamper == null) {
      throw StateError('Error updating activity order: No camper selected');
    }
    isActivityDataLoaded = false;
    update();

    orderedStandardActivityIds = [];
    orderedSkillsActivityIds = [];

    try {
      final results = await Future.wait([
        scheduleService.getOrderedActivities(selectedCamper!.id, false),
        scheduleService.getOrderedActivities(selectedCamper!.id, true),
      ]);

      orderedStandardActivityIds.addAll(results[0]);
      orderedSkillsActivityIds.addAll(results[1]);
    } catch (e) {
      orderedStandardActivityIds = [];
      orderedSkillsActivityIds = [];
      throw StateError('Error ordering activities');
    } finally {
      isActivityDataLoaded = true;
      Debug.logInfo('Finished POPULATING ACTIVITY MAPS for camper: ${selectedCamper!}');
      update();
    }
  }

  void onReorderStandardActivities(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final String movedItemId = orderedStandardActivityIds.removeAt(oldIndex);
    orderedStandardActivityIds.insert(newIndex, movedItemId);
    Debug.logInfo("Reordered standard activities: $orderedStandardActivityIds");
    update();
  }

  void onReorderSkillsActivities(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final String movedItemId = orderedSkillsActivityIds.removeAt(oldIndex);
    orderedSkillsActivityIds.insert(newIndex, movedItemId);
    Debug.logInfo("Reordered skills activities: $orderedSkillsActivityIds");
    update();
  }

  Future<void> saveActivityRanking() async {
    if (selectedCamper == null) {
      popupService.showToast(title: 'Error', message: 'No camper selected');
      return;
    }
    if (orderedStandardActivityIds.isEmpty && orderedSkillsActivityIds.isEmpty) {
      popupService.showToast(title: 'Info', message: 'No activities have been scheduled for this session');
      return;
    }

    saveInProgress = true;
    update();

    try {
      Commit commit = Commit(disarmRequirementsLevel: 0);
      await activityPreferenceService.setRanking(
        commit: commit,
        camperId: selectedCamper!.id,
        orderedPrincipalActivityIds: orderedStandardActivityIds,
      );
      await activityPreferenceService.setRanking(
        commit: commit,
        camperId: selectedCamper!.id,
        orderedPrincipalActivityIds: orderedSkillsActivityIds,
      );
      await commitRepo.commit(commit);

      camperIsCompleted.add(selectedCamper!);
      popupService.showToast(title: 'Success', message: 'Activity ranking for ${selectedCamper!.name} has been saved!');
    } catch (e) {
      Debug.logInfo("Error saving ranking: $e");
      popupService.showToast(title: 'Error', message: 'Failed to save ranking: $e');
    } finally {
      saveInProgress = false;
      update();
    }
  }

  Future<void> navigateToSelection(String cabinId, String cabinName) async {
    selectedCabinId = cabinId;
    selectedCabinName = cabinName;
    // No need for update() here as Get.toNamed will trigger a new view/wrapper
    Get.toNamed(BessRoutes.activityPreferencesSelector);
  }

  Future<void> selectCamper(Titled camper) async {
    if (camper is Camper) {
      selectedCamper = camper;
      update(); // Update the UI to show the new camper name is selected
      await updateActivityOrder(); // This will call update() when it's done.
    }
  }

  Future<void> showActivityInfo(PrincipalActivityId principalActivityId) async {
    final activity = await activityPreferenceService.getPrincipalActivity(principalActivityId);
    popupService.showActivityInfo(activity);
  }
}