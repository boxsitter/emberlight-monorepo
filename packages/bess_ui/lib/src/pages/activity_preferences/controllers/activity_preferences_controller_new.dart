// import 'package:bess_ui/src/common/services/popup_service.dart';
// import 'package:ember_core/ember_core.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:get/get.dart';
//
// import '../../../common/mixins/route_aware_controller_mixin.dart';
// import '../../../common/routes/routes.dart';
//
// typedef CabinDependantId = String;
//
// const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//
// class ActivityPreferencesController extends GetxController with RouteAwareControllerMixin {
//   final ContextService clientContextService = Get.find<ContextService>();
//   final CabinService cabinsService = Get.find<CabinService>();
//   final RosterService rosterService = Get.find<RosterService>();
//   final ScheduleService scheduleService = Get.find<ScheduleService>();
//   final PopupService popupService = Get.find<PopupService>();
//   final ActivityPreferenceService activityPreferenceService = Get.find<ActivityPreferenceService>();
//   final CommitRepository commitRepo = Get.find<CommitRepository>();
//
//   final ScrollController scrollController = ScrollController();
//
//   // --- State Variables ---
//   List<((CabinDependent, PrincipalCabin), (List<Camper>, int))> cabinCamperData = [];
//   ((CabinDependent, PrincipalCabin), (List<Camper>, int))? selectedCabinData;
//   Camper? selectedCamper;
//
//   // Data lists
//   List<(PrincipalActivity, int?)> principalActivities = [];
//   List<(PrincipalActivity, int?)> filteredActivities = [];
//
//   // State for UI
//   int? totalActivityCount;
//   int focusedActivityIndex = 0;
//   bool preferenceSelectionLoading = false;
//   int? selectedDay;
//
//   bool isCabinCamperDataLoaded = false;
//   bool isActivityDataLoaded = false;
//   bool showingSkillsRecs = false;
//   bool cabinsOpened = true;
//   bool campersOpened = true;
//
//   @override
//   void onClose() {
//     scrollController.dispose();
//     super.onClose();
//   }
//
//   @override
//   void onNavigateTo(String to, String? from) {
//     setCabinsOpened(true);
//   }
//
//   @override
//   void onNavigateFrom(String from, String to) {
//     // Nothing here
//   }
//
//   // --- Data Loading ---
//
//   Future<void> _loadCabinCamperData() async {
//     isCabinCamperDataLoaded = false;
//     update();
//
//     final results = await Future.wait([
//       cabinsService.getCabinDependentToPrincipalCabins(),
//       rosterService.registeredCampers,
//     ]);
//
//     final cabinDepToPrinCabin = results[0] as Map<CabinDependent, PrincipalCabin>;
//     final campers = (results[1] as Map<String, Camper>).values.toSet();
//
//     final populatedCabins = cabinDepToPrinCabin.entries.map((entry) {
//       final cabinDependent = entry.key;
//       final principalCabin = entry.value;
//
//       final cabinRoster = campers.where((camper) => cabinDependent.camperRefs.contains(camper.id)).toList()
//         ..sort((a, b) => a.lastName.compareTo(b.lastName));
//
//       final completedCount = cabinRoster.where((c) => c.preferencesCompleted == true).length;
//
//       return ((cabinDependent, principalCabin), (cabinRoster, completedCount));
//     }).toList();
//
//     populatedCabins.sort((a, b) => a.$1.$2.displayTitle.compareTo(b.$1.$2.displayTitle));
//
//     cabinCamperData = populatedCabins;
//     isCabinCamperDataLoaded = true;
//     update();
//   }
//
//   Future<void> _loadActivityData(bool onlySkills) async {
//     if (selectedCamper == null) return;
//
//     isActivityDataLoaded = false;
//     update();
//
//     final results = await Future.wait([
//       scheduleService.getScheduledPrincipalActivities(),
//       scheduleService.amas,
//     ]);
//     final Set<PrincipalActivity> allActivities = results[0] as Set<PrincipalActivity>;
//     final List<AMABlock> allBlocks = (results[1] as Set<AMABlock>).toList();
//
//     allBlocks.sort((a, b) => a.start.compareTo(b.start));
//
//     Set<PrincipalActivity> seenActivities = {};
//
//     // We need to keep track of the days processed to match with selectedDay.
//     // Let's assume the first block's date is our reference point for day 0.
//     DateTime? firstBlockDate;
//     if (allBlocks.isNotEmpty) {
//       firstBlockDate = allBlocks.first.start;
//     }
//
//     int currentDayIndex = 0;
//     DateTime? previousBlockDate;
//
//     for (final block in allBlocks) {
//       // If we have a selectedDay, and we've gone past that day, break.
//       // We need to account for multiple blocks on the same day.
//       if (firstBlockDate != null && selectedDay != null) {
//         final blockDay = block.start.difference(firstBlockDate).inDays;
//         if (previousBlockDate == null ||
//             block.start.day != previousBlockDate.day ||
//             block.start.month != previousBlockDate.month ||
//             block.start.year != previousBlockDate.year) {
//           // If it's a new day, increment our day index.
//           if (blockDay > currentDayIndex) {
//             currentDayIndex = blockDay;
//           }
//         }
//         if (currentDayIndex > selectedDay!) {
//           break;
//         }
//         previousBlockDate = block.start;
//       }
//
//       Set<PrincipalActivity> activitiesInBlock = {};
//
//       for (final dependentId in block.activityDependentCmps) {
//         // Assuming you have a way to get the ActivityDependent from its ID.
//         // For this example, let's assume scheduleService has a method like:
//         // scheduleService.getActivityDependent(dependentId)
//         final activityDependent = await scheduleService.getActivityDependent(dependentId);
//
//         if (activityDependent != null && activityDependent.principalPar != null) {
//           // Find the corresponding PrincipalActivity from allActivities using principalPar
//           final principalActivity = allActivities.firstWhereOrNull(
//             (activity) => activity.id == activityDependent.principalPar,
//           );
//
//           if (principalActivity != null) {
//             // Only add if it's a new activity for this block (not seen before in previous blocks)
//             if (!seenActivities.contains(principalActivity)) {
//               activitiesInBlock.add(principalActivity);
//             }
//           }
//         }
//       }
//
//       // Add all newly found activities from this block to the seenActivities set
//       seenActivities.addAll(activitiesInBlock);
//     }
//
//     final dailyGroupedActivities = <int, List<PrincipalActivity>>{};
//     for (final activity in allActivities) {
//       if (activity.isHidden) continue;
//
//       final appearanceDate = firstAppearance[activity.id];
//       if (appearanceDate != null) {
//         final dayOfWeek = appearanceDate.weekday;
//         (dailyGroupedActivities[dayOfWeek] ??= []).add(activity);
//       }
//     }
//
//     final nestedOutput = List.generate(7, (_) => <(PrincipalActivity, int?)>[]);
//     dailyGroupedActivities.forEach((day, activities) {
//       activities.sort((a, b) => a.displayTitle.compareTo(b.displayTitle));
//       final dayIndex = day - 1;
//       if (dayIndex >= 0 && dayIndex < 7) {
//         nestedOutput[dayIndex] = activities.map((activity) {
//           final preference = selectedCamper?.preferenceRefs[activity.id];
//           final prefAsInt = preference == null ? null : (preference * 10).round();
//           return (activity, prefAsInt);
//         }).toList();
//       }
//     });
//
//     principalActivities = nestedOutput;
//     principalActivities = nestedOutput.expand((dayList) => dayList).toList();
//     totalActivityCount = principalActivities.length;
//
//     _updateFilteredActivities();
//
//     isActivityDataLoaded = true;
//     update();
//   }
//
//   // --- Filtering Logic ---
//
//   void _updateFilteredActivities() {
//     // If selectedDay is null or the "All" button is selected
//     if (selectedDay == null || selectedDay! >= principalActivities.length) {
//       filteredActivities = List.from(principalActivities);
//     }
//     // If a specific day is selected
//     else if (selectedDay! < principalActivities.length) {
//       filteredActivities = List.from(principalActivities[selectedDay!]);
//     } else {
//       filteredActivities = [];
//     }
//   }
//
//   void selectDay(int? dayIndex) {
//     selectedDay = dayIndex;
//     _updateFilteredActivities();
//     update();
//   }
//
//   // --- UI Actions ---
//
//   Future<void> setCabinsOpened(bool value) async {
//     if (campersOpened && value == true) {
//       campersOpened = false;
//     }
//     cabinsOpened = value;
//     if (value == true) {
//       await _loadCabinCamperData();
//     }
//     update();
//   }
//
//   Future<void> setCampersOpened(bool value) async {
//     if (cabinsOpened) return;
//     campersOpened = value;
//     if (value == true) {
//       await _loadCabinCamperData();
//     }
//     update();
//   }
//
//   Future<void> setSelectedCabin(((CabinDependent, PrincipalCabin), (List<Camper>, int))? cabinData) async {
//     selectedCabinData = cabinData;
//     final campersInCabin = cabinData?.$2.$1;
//     if (campersInCabin != null && campersInCabin.isNotEmpty) {
//       selectedCamper = campersInCabin.first;
//     } else {
//       selectedCamper = null;
//     }
//
//     cabinsOpened = false;
//     campersOpened = true;
//
//     if (selectedCamper != null) {
//       await _loadActivityData(false);
//     } else {
//       isActivityDataLoaded = true;
//       principalActivities.clear();
//       principalActivities.clear();
//       filteredActivities.clear();
//       totalActivityCount = 0;
//     }
//     update();
//   }
//
//   Future<void> setSelectedCamper(Camper? value) async {
//     selectedCamper = value;
//     isActivityDataLoaded = false;
//     await _loadActivityData(false);
//     update();
//   }
//
//   Future<void> showActivityInfo(PrincipalActivityId principalActivityId) async {
//     final activity = await activityPreferenceService.getPrincipalActivity(principalActivityId);
//     popupService.showActivityInfo(activity);
//   }
//
//   void setShowingSkillsRecs(bool state) {
//     showingSkillsRecs = state;
//     update();
//   }
//
//   void setFocusedActivityIndex(int value) {
//     if (value < 0 || value >= filteredActivities.length) {
//       return;
//     }
//     focusedActivityIndex = value;
//     final double slotHeight = 84.0;
//     scrollController.animateTo(
//       value * slotHeight,
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeOut,
//     );
//     update();
//   }
//
//   (int, int)? _findNestedIndices(int flatIndex) {
//     if (flatIndex < 0) return null;
//     int cumulativeCount = 0;
//     for (int dayIndex = 0; dayIndex < principalActivities.length; dayIndex++) {
//       final dayActivityCount = principalActivities[dayIndex].length;
//       if (flatIndex < cumulativeCount + dayActivityCount) {
//         final activityIndex = flatIndex - cumulativeCount;
//         return (dayIndex, activityIndex);
//       }
//       cumulativeCount += dayActivityCount;
//     }
//     return null;
//   }
//
//   Future<void> setActivityPreference(int index, double? preference) async {
//     if (selectedCamper == null || (preference != null && (preference < 0.0 || preference > 1.0))) return;
//
//     if (index < 0 || index >= filteredActivities.length) return;
//     final activityToUpdate = filteredActivities[index].$1;
//     final originalFlatIndex = principalActivities.indexWhere((e) => e.$1.id == activityToUpdate.id);
//
//     if (originalFlatIndex == -1) return;
//
//     preferenceSelectionLoading = true;
//     update();
//
//     final indices = _findNestedIndices(originalFlatIndex);
//     if (indices == null) {
//       preferenceSelectionLoading = false;
//       update();
//       return;
//     }
//     final (dayIndex, activityIndex) = indices;
//
//     final newPreferenceAsInt = preference == null ? null : (preference * 10).round();
//
//     final commit = Commit(disarmRequirementsLevel: 0);
//     selectedCamper?.preferenceRefs[activityToUpdate.id] = preference;
//
//     principalActivities[dayIndex][activityIndex] = (activityToUpdate, newPreferenceAsInt);
//     principalActivities[originalFlatIndex] = (activityToUpdate, newPreferenceAsInt);
//     filteredActivities[index] = (activityToUpdate, newPreferenceAsInt);
//     update();
//
//     await activityPreferenceService.setActivityPreference(
//       commit: commit,
//       camperId: selectedCamper!.id,
//       principalActivityId: activityToUpdate.id,
//       preference: preference,
//     );
//     await commitRepo.commit(commit);
//
//     preferenceSelectionLoading = false;
//     update();
//
//     final nextIndex = index + 1;
//     if (nextIndex < filteredActivities.length && filteredActivities[nextIndex].$2 == null) {
//       setFocusedActivityIndex(nextIndex);
//     }
//   }
//
//   void syncFocusedIndexFromScroll(int index) {
//     if (index < 0 || index >= filteredActivities.length) return;
//
//     // Only update if the index has actually changed
//     if (focusedActivityIndex != index) {
//       focusedActivityIndex = index;
//       update();
//     }
//   }
// }
