import 'dart:collection';

import 'package:bess_ui/src/common/controllers/save_controller.dart';
import 'package:bess_ui/src/common/services/popup_service.dart';
import 'package:bess_ui/src/common/widgets/header/header_controller.dart';
import 'package:bess_ui/src/common/widgets/layouts/sidebars/sidebar_controller.dart';
import 'package:ember_core/ember_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../common/mixins/route_aware_controller_mixin.dart';
import '../../../common/routes/routes.dart';
import '../../../common/widgets/header/controllers/menu_bar_controller.dart';

typedef CabinDependantId = String;

class ActivityPreferencesControllerDiplomatic extends GetxController with RouteAwareControllerMixin {
  final ContextService clientContextService = Get.find<ContextService>();
  final CabinService cabinsService = Get.find<CabinService>();
  final RosterService rosterService = Get.find<RosterService>();
  final ScheduleService scheduleService = Get.find<ScheduleService>();
  final PopupService popupService = Get.find<PopupService>();
  final ActivityPreferenceService activityPreferenceService = Get.find<ActivityPreferenceService>();
  final CommitRepository commitRepo = Get.find<CommitRepository>();
  // final SaveController saveController = Get.find<SaveController>();
  final MenuBarController menuBarController = Get.find<MenuBarController>();

  Map<CabinDependantId, PrincipalCabin> cabins = {};
  (CabinDependantId, PrincipalCabin)? selectedCabin;

  Map<String, Camper> campers = {};
  List<Camper> campersInSelectedCabin = [];
  Camper? selectedCamper;

  Map<String, PrincipalActivity> _allPrincipalActivities = {};
  List<PrincipalActivity> neutralActivities = [];
  List<PrincipalActivity> requestedActivities = [];
  List<PrincipalActivity> vetoedActivities = [];
  PrincipalActivity? pickedUpActivity;
  int? maxRequests;
  int? maxVetoes;

  Map<CamperId, Map<PrincipalActivityId, double?>> entriesToSave = {};
  Map<CamperId, Map<PrincipalActivityId, double?>> entriesSaving = {};
  bool isSaving = false;

  bool isCabinDataLoaded = false;
  bool isCamperDataLoaded = false;
  bool isActivityDataLoaded = false;

  bool cabinsOpened = true;
  bool campersOpened = false;

  final List<ActivityCategory> categories = [
    ActivityCategory.creative,
    //ActivityCategory.silly,
    ActivityCategory.waterfront,
    ActivityCategory.campClassics,
    ActivityCategory.sportsAndAthletics,
    ActivityCategory.skills,
  ];
  ActivityCategory? selectedCategory;

  List<PrincipalActivity> getActivitiesInCategory(ActivityCategory category) {
    return neutralActivities.where((element) => element.category == category).toList();
  }

  List<Camper> getCampersInCabin(CabinDependantId cabinDependantId, bool shouldSort) {
    List<Camper> unsortedCampers = campers.values.where((element) => element.cabinRef == cabinDependantId).toList();
    if (shouldSort) {
      unsortedCampers.sort((a, b) => a.lastName.compareTo(b.lastName));
    }
    return unsortedCampers;
  }

  int getCampersStartCount(List<Camper> campers) {
    return campers.where((element) => element.preferencesStarted).length;
  }

  (int, int) startedOutOfCount(CabinDependantId cabinDependantId) {
    List<Camper> campers = getCampersInCabin(cabinDependantId, false);
    return (getCampersStartCount(campers), campers.length);
  }

  @override
  Future<void> onNavigateTo(String to, String? from) async {
    cabinsOpened = true;
    campersOpened = false;
    await _loadCabinData();
    await _loadCamperData();
    await _loadActivityData();
  }

  @override
  Future<void> onNavigateFrom(String to, String? from) async {
    save();
  }

  Future<void> _loadCabinData() async {
    cabins = {};
    isCabinDataLoaded = false;
    update();

    final cabinDepToPrin = await cabinsService.getCabinDependentToPrincipalCabins();
    cabins = cabinDepToPrin.map((key, value) => MapEntry(key.id, value));

    isCabinDataLoaded = true;
    update();
  }

  Future<void> _loadCamperData() async {
    campers = {};
    isCamperDataLoaded = false;
    update();

    campers = await rosterService.registeredCampers;

    isCamperDataLoaded = true;
    update();
  }

  Future<void> _loadActivityData() async {
    neutralActivities = [];
    isActivityDataLoaded = false;
    update();

    _allPrincipalActivities = Map.fromEntries(
      (await scheduleService.getScheduledPrincipalActivities())
          .where((element) => element.category != ActivityCategory.hidden) // Correction is here
          .map((e) => MapEntry(e.id, e)),
    );

    final results = await Future.wait([scheduleService.getScheduledPrincipalActivities(), clientContextService.session]);
    Set<PrincipalActivity> scheduledPrincipalActivities = results[0] as Set<PrincipalActivity>;
    Session session = results[1] as Session;
    maxRequests = session.maxRequests;
    maxVetoes = session.maxVetoes;
    separateActivities();
    isActivityDataLoaded = true;
    update();
  }

  void separateActivities() {
    neutralActivities = [];
    requestedActivities = [];
    vetoedActivities = [];
    if (selectedCamper == null) return;
    _allPrincipalActivities.forEach((key, value) {
      if (selectedCamper!.preferenceRefs.containsKey(key) && selectedCamper!.preferenceRefs[key] != null) {
        double preference = selectedCamper!.preferenceRefs[key]!;
        if (preference >= 0 && preference < 0.5) {
          vetoedActivities.add(value);
        } else if (preference == 0.5) {
          neutralActivities.add(value);
        } else if (preference > 0.5 && preference <= 1.0) {
          requestedActivities.add(value);
        } else {
          throw StateError('invalid preference');
        }
      } else {
        neutralActivities.add(value);
      }
    });
  }

  Future<void> setCabinsOpened(bool value) async {
    if (campersOpened && value == true) {
      campersOpened = false;
    }
    cabinsOpened = value;
    if (value == true) save();
    update();
  }

  Future<void> setCampersOpened(bool value) async {
    if (cabinsOpened) return;
    campersOpened = value;
    update();
  }

  Future<void> setSelectedCabin((CabinDependantId, PrincipalCabin) value) async {
    selectedCabin = value;
    cabinsOpened = false;
    campersInSelectedCabin = getCampersInCabin(value.$1, true);
    campersOpened = true;
    selectedCamper = campersInSelectedCabin.first;
    separateActivities();
    menuBarController.setHideSidebar(true);
    update();
  }

  Future<void> setSelectedCamper(Camper? value) async {
    selectedCamper = value;
    separateActivities();
    save();
    update();
  }

  Future<void> showActivityInfo(PrincipalActivityId principalActivityId) async {
    final activity = await activityPreferenceService.getPrincipalActivity(principalActivityId);
    popupService.showActivityInfo(activity);
  }

  void onDragStarted(PrincipalActivity activity) {
    pickedUpActivity = activity;
    selectedCategory = activity.category;
    update();
  }

  void onDragEnd() {
    pickedUpActivity = null;
    update();
  }

  void addToRequested(PrincipalActivity activity) {
    if (requestedActivities.contains(activity)) {
      pickedUpActivity = null;
      update();
      return;
    }

    if (activity.isSkillsRec && requestedActivities.where((element) => element.isSkillsRec).length == 2) {
      pickedUpActivity = null;
      update();
      Debug.logWarning('Attempted to request more than two skills recs.', userMessage: 'You can only request two skills recs. Remove a requested skills rec first.');
      return;
    }
    if (requestedActivities.length >= maxRequests!) {
      pickedUpActivity = null;
      update();
      Debug.logWarning('Attempted to exceed requests', userMessage: 'You have reached the maximum of $maxRequests requests');
      return;
    }
    if (neutralActivities.contains(activity)) {
      neutralActivities.remove(activity);
    }
    if (vetoedActivities.contains(activity)) {
      vetoedActivities.remove(activity);
    }
    requestedActivities.add(activity);
    pickedUpActivity = null;
    addForSaving();
    update();
  }

  void addToVetoed(PrincipalActivity activity) {
    if (vetoedActivities.contains(activity)) {
      pickedUpActivity = null;
      update();
      return;
    }
    if (vetoedActivities.length >= maxVetoes!) {
      pickedUpActivity = null;
      update();
      Debug.logWarning('Attempted to exceed vetoes', userMessage: 'You have reached the maximum of $maxVetoes vetoes');
      return;
    }
    if (neutralActivities.contains(activity)) {
      neutralActivities.remove(activity);
    }
    if (requestedActivities.contains(activity)) {
      requestedActivities.remove(activity);
    }
    vetoedActivities.add(activity);
    pickedUpActivity = null;
    addForSaving();
    update();
  }

  void addToNeutral(PrincipalActivity activity) {
    if (neutralActivities.contains(activity)) {
      pickedUpActivity = null;
      update();
      return;
    }
    if (vetoedActivities.contains(activity)) {
      vetoedActivities.remove(activity);
    }
    if (requestedActivities.contains(activity)) {
      requestedActivities.remove(activity);
    }
    neutralActivities.add(activity);
    pickedUpActivity = null;
    addForSaving();
    update();
  }

  void setSelectedCategory(ActivityCategory value) {
    selectedCategory = value;
    update();
  }

  void addForSaving() {
    if (selectedCamper == null) return;
    if (entriesToSave.containsKey(selectedCamper!.id)) {
      entriesToSave.remove(selectedCamper!.id);
    }
    final Map<PrincipalActivityId, double?> newRefs = {};
    requestedActivities.forEach((element) {
      newRefs[element.id] = 1.0;
    });
    vetoedActivities.forEach((element) {
      newRefs[element.id] = 0.0;
    });
    entriesToSave[selectedCamper!.id] = newRefs;
  }

  Future<void> save() async {
    if (entriesToSave.isEmpty || isSaving) {
      return;
    }
    isSaving = true;
    final Map<CamperId, Map<PrincipalActivityId, double?>> entriesForThisSave = Map.from(entriesToSave);
    entriesToSave.clear();
    entriesSaving.addAll(entriesForThisSave);
    update();
    try {
      final Commit commit = Commit(disarmRequirementsLevel: 0);
      entriesForThisSave.forEach((key, value) {
        if (campers[key] != null) {
          campers[key]!.preferenceRefs.clear();
          campers[key]!.preferenceRefs.addEntries(value.entries);
        }
      });
      await activityPreferenceService.setMultipleActivityPreferences(commit: commit, preferences: entriesForThisSave);
      await commitRepo.commit(commit);
    } finally {
      entriesSaving.removeWhere((key, _) => entriesForThisSave.containsKey(key));
      isSaving = false;
      update();
      if (entriesToSave.isNotEmpty) {
        save();
      }
    }
  }
}
