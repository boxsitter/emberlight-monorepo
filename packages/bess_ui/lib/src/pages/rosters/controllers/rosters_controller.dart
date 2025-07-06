import 'dart:async';

import 'package:bess_ui/src/common/services/popup_service.dart';
import 'package:bess_ui/src/pages/rosters/controllers/roster_group.dart';
import 'package:bess_ui/src/pages/rosters/controllers/table_widths.dart';
import 'package:ember_core/ember_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/mixins/route_aware_controller_mixin.dart';

class RostersController extends GetxController with RouteAwareControllerMixin {
  // Dependencies
  final ContextService contextService = Get.find<ContextService>();
  final CabinService cabinsService = Get.find<CabinService>();
  final RosterService rosterService = Get.find<RosterService>();
  final ActivityPreferenceService preferenceService = Get.find<ActivityPreferenceService>();
  final AssignmentService assignmentService = Get.find<AssignmentService>();
  final CommitRepository commitRepo = Get.find<CommitRepository>();
  final PullRepository pullRepo = Get.find<PullRepository>();
  final ScheduleService scheduleService = Get.find<ScheduleService>();
  final PopupService popupService = Get.find<PopupService>();

  // State Variables
  // --- Core Data ---
  List<Rosterable> roster = [];
  Set<Rosterable> selectedItems = {};
  List<AMABlock> amas = [];
  Map<PrincipalActivityId, PrincipalActivity> principalActivities = {};
  List<ActivityDependent> activityDependents = [];
  Map<String, bool> _isRosterGroupTitleExpanded = {};

  // --- Search & Filtering ---
  String searchQuery = '';
  final searchController = TextEditingController();

  // --- UI State Flags ---
  bool importingCampers = false;
  bool populatingActivities = false;
  bool assigningCamper = false;
  bool columnConfigOpened = false;
  bool activitySwitcherOpened = false;

  // --- Table Configuration ---
  final List<RosterField> fields = [
    RosterField.fullName,
    RosterField.preferredName,
    RosterField.gender,
    RosterField.age,
    RosterField.cabinName
  ];
  RosterField sortByField = RosterField.lastName;
  SortDirection sortDirection = SortDirection.asc;
  RosterField? groupByField;

  // --- View Settings ---
  bool displayAmas = false;
  bool alternateRowColors = true;
  bool highContrast = false;
  bool rowSeparators = false;
  bool columnSeparators = false;
  bool compact = true;
  bool expandedByDefault = false;

  // --- Activity Switcher State ---
  AMABlock? selectedAma;
  ActivityDependent? selectedActivity;

  // Private Internal State
  Timer? _debounce;
  StreamSubscription<Map<String, Camper>>? _campersSubscription;
  static const double _checkboxColumnWidth = 50.0;

  // Computed Properties (Getters)
  List<Rosterable> get filteredRoster {
    if (searchQuery.isEmpty) {
      return roster;
    } else {
      return roster.where((item) {
        final fullName = item.getFieldAsString(RosterField.fullName).toLowerCase();
        final nickname = item.getFieldAsString(RosterField.preferredName).toLowerCase();
        return fullName.contains(searchQuery.toLowerCase()) || nickname.contains(searchQuery.toLowerCase());
      }).toList();
    }
  }

  int get count => filteredRoster.length;

  List<RosterField> get availableFields {
    if (displayAmas) {
      return amas.where((ama) => !fields.contains(ama)).toList();
    }
    return RosterField.values.where((field) => !fields.contains(field)).toList();
  }

  List<RosterGroup> get rosterGroups {
    if (groupByField == null) {
      return [
        RosterGroup(
          title: 'All Campers',
          items: filteredRoster,
        )
      ];
    }

    final Map<String, List<Rosterable>> groupsMap = {};
    for (final item in filteredRoster) {
      final groupKey = item.getFieldAsString(groupByField!);
      groupsMap.putIfAbsent(groupKey, () => []).add(item);
    }

    final List<RosterGroup> groups = groupsMap.entries.map((entry) {
      return RosterGroup(
        title: entry.key.isEmpty ? 'Unspecified' : entry.key,
        groupByField: groupByField!,
        items: entry.value,
      );
    }).toList();

    groups.sort((a, b) => a.title.compareTo(b.title));
    return groups;
  }

  // Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    Debug.logInfo('RostersController initialized. Starting listener.');
    rosterService.camperStream.then((stream) {
      _campersSubscription?.cancel();
      _campersSubscription = stream.listen((camperMap) {
        roster = camperMap.values.toList();
        sort(sortByField);
        update();
      });
    });
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _campersSubscription?.cancel();
    super.onClose();
  }

  @override
  void onNavigateTo(String to, String? from) {
    Debug.logInfo('RostersController navigated to.');
    populateActivities();
  }

  @override
  void onNavigateFrom(String to, String? from) {
    Debug.logInfo('RostersController navigated from.');
  }

  // Public Methods
  Future<void> populateActivities() async {
    populatingActivities = true;
    update();
    final List<dynamic> activityData = (await scheduleService.getActivityData());
    amas = (activityData[0] as Set<AMABlock>).toList();
    principalActivities = (activityData[2] as Map<PrincipalActivityId, PrincipalActivity>);
    activityDependents = (activityData[1] as Set<ActivityDependent>).toList();
    populatingActivities = false;
    update();
  }

  // --- Search ---

  void setSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 50), () {
      searchQuery = query;
      update();
    });
  }

  // --- Column, Sorting, & Grouping ---

  void setColumnOrder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = fields.removeAt(oldIndex);
    fields.insert(newIndex, item);
    update();
  }

  void addVisibleColumn(RosterField field) {
    if (!fields.contains(field)) {
      fields.add(field);
      update();
    }
  }

  void removeVisibleColumn(RosterField field) {
    if (fields.contains(field)) {
      fields.remove(field);
      update();
    }
  }

  void sort(RosterField field) {
    roster.sort((a, b) {
      final aValue = a.getFieldAsString(field);
      final bValue = b.getFieldAsString(field);
      final compare = aValue.compareTo(bValue);
      return sortDirection == SortDirection.asc ? compare : -compare;
    });

    update();
  }

  void setSortBy(RosterField field) {
    if (sortByField != field) {
      sortDirection = SortDirection.asc;
    } else {
      sortDirection = sortDirection == SortDirection.desc ? SortDirection.asc : SortDirection.desc;
    }
    sortByField = field;
    sort(field);
    update();
  }

  void setGroupBy(RosterField? field) {
    groupByField = (groupByField == field) ? null : field;
    update();
  }

  void toggleGroupExpanded(RosterGroup group) {
    bool? expansionState = _isRosterGroupTitleExpanded[group.title];
    if (expansionState == null) {
      _isRosterGroupTitleExpanded[group.title] = !expandedByDefault;
    } else {
      _isRosterGroupTitleExpanded[group.title] = !expansionState;
    }
    update();
  }

  bool isGroupExpanded(RosterGroup group) {
    if (rosterGroups.length == 1) {
      return true;
    }
    return _isRosterGroupTitleExpanded[group.title] == null ? expandedByDefault : _isRosterGroupTitleExpanded[group.title]!;
  }

  // --- Selection ---

  void toggleRowSelection(Rosterable rosterable) {
    selectedItems.contains(rosterable) ? selectedItems.remove(rosterable) : selectedItems.add(rosterable);
    update();
  }

  void toggleSelectAll() {
    if (selectedItems.isEmpty) {
      selectedItems.addAll(filteredRoster);
    } else {
      selectedItems.removeAll(filteredRoster);
    }
    update();
  }

  void toggleSelectGroup(RosterGroup group) {
    if (selectedItems.intersection(group.items.toSet()).isEmpty) {
      selectedItems.addAll(group.items);
    } else {
      selectedItems.removeAll(group.items);
    }
    update();
  }

  void invertSelection() {
    selectedItems = roster.toSet().difference(selectedItems);
    update();
  }

  bool isNothingSelected() => selectedItems.isEmpty;
  bool isSingleSelected() => selectedItems.length == 1;
  bool isMultiSelected() => selectedItems.length > 1;

  // --- UI & View Toggles ---

  void toggleSecondaryPage(int page) {
    if (page == 1) {
      columnConfigOpened = !columnConfigOpened;
      activitySwitcherOpened = false;
    } else if (page == 2) {
      activitySwitcherOpened = !activitySwitcherOpened;
      columnConfigOpened = false;
    }
    update();
  }

  void toggleDisplayAmas() {
    displayAmas = !displayAmas;
    update();
  }

  void toggleAlternateRowColors() {
    alternateRowColors = !alternateRowColors;
    update();
  }

  void toggleHighContrast() {
    highContrast = !highContrast;
    update();
  }

  void toggleRowSeparators() {
    rowSeparators = !rowSeparators;
    update();
  }

  void toggleColumnSeparators() {
    columnSeparators = !columnSeparators;
    update();
  }

  void toggleCompact() {
    compact = !compact;
    update();
  }

  // --- Activity Switcher Actions ---

  // Activity Switcher Actions
  void setSelectedAma(Titled block) {
    if (block is AMABlock) {
      selectedAma = (selectedAma == block) ? null : block;
      selectedActivity = null;
      update();
    }
  }

  void setSelectedActivity(ActivityDependent activity) {
    selectedActivity = (selectedActivity == activity) ? null : activity;
    update();
  }

  // Core User Actions
  Future<void> importCsv() async {
    importingCampers = true;
    update();

    try {
      await commitRepo.commit(await rosterService.importFromCsv());
    } on Exception catch (e, st) {
      Error.throwWithStackTrace(Debug.parseException(e), st);
    } finally {
      importingCampers = false;
      Get.back();
      update();
    }
  }

  Future<void> deleteSelected() async {
    try {
      Commit commit = Commit(
          disarmRequirementsLevel: 1,
          confirmationMessage:
              'Once deleted, campers cannot be restored. Their activity assignments and preferences for this session will be gone. Are you sure you want to proceed?');
      commit.addObjectsToDelete(selectedItems);
      await commitRepo.commit(commit);
    } finally {
      selectedItems.clear();
      update();
    }
  }

  Future<void> assignSelected() async {
    if (selectedItems.isEmpty || selectedAma == null || selectedActivity == null) {
      Debug.logWarning('Can\'t assign selected campers');
      return;
    }
    try {
      assigningCamper = true;
      update();
      Commit commit = Commit(disarmRequirementsLevel: 0);
      for (Rosterable rosterable in selectedItems) {
        if (rosterable is Camper) {
          await rosterService.assignCamperToActivity(commit, rosterable.id, selectedActivity!.id);
        }
      }
      await commitRepo.commit(commit);
      await populateActivities();
    } catch (e, st) {
      Error.throwWithStackTrace(Debug.parseException(e), st);
    } finally {
      assigningCamper = false;
      update();
    }
  }

  Future<void> unassignSelectedFromActivity() async {
    if (selectedItems.isEmpty || selectedActivity == null) {
      Debug.logWarning('Can\'t unassign selected campers');
      return;
    }
    try {
      Commit commit = Commit(disarmRequirementsLevel: 0);
      for (Rosterable rosterable in selectedItems) {
        if (rosterable is Camper && rosterable.activityAssignmentRefs.containsValue(selectedActivity!.id)) {
          await rosterService.removeCamperFromActivity(commit, rosterable.id, selectedActivity!.id);
        }
      }
      await commitRepo.commit(commit);
      await populateActivities();
    } catch (e, st) {
      Error.throwWithStackTrace(Debug.parseException(e), st);
    } finally {
      update();
    }
  }

  Future<void> unassignSelectedFromAma() async {
    if (selectedItems.isEmpty || selectedAma == null) {
      Debug.logWarning('Can\'t unassign selected campers');
      return;
    }
    try {
      Commit commit = Commit(disarmRequirementsLevel: 0);
      for (Rosterable rosterable in selectedItems) {
        if (rosterable is Camper && rosterable.activityAssignmentRefs.containsKey(selectedAma!.id)) {
          await rosterService.unassignCamperFromAmaBlock(commit, rosterable.id, selectedAma!.id);
        }
      }
      await commitRepo.commit(commit);
      await populateActivities();
    } catch (e, st) {
      Error.throwWithStackTrace(Debug.parseException(e), st);
    } finally {
      update();
    }
  }

  Future<void> unassignSelectedFromAll() async {
    if (selectedItems.isEmpty) {
      Debug.logWarning('Can\'t unassign selected campers');
      return;
    }
    try {
      Commit commit = Commit(
          disarmRequirementsLevel: 1,
          confirmationMessage:
              'Are you sure you want to unassign the selected campers from all of their activities? This action cannot be undone.');
      for (Rosterable rosterable in selectedItems) {
        if (rosterable is Camper) {
          await rosterService.removeAllActivitiesFromCamper(commit, rosterable.id);
        }
      }
      await commitRepo.commit(commit);
      await populateActivities();
    } catch (e, st) {
      Error.throwWithStackTrace(Debug.parseException(e), st);
    } finally {
      update();
    }
  }

  Future<void> rankRandomSelected() async {
    if (selectedItems.isEmpty) {
      Debug.logWarning('Can\'t rank selected campers');
      return;
    }
    try {
      Commit commit = Commit(
          disarmRequirementsLevel: 1,
          confirmationMessage: 'Are you sure you want to overwrite these activity preferences? This action cannot be undone.');
      for (Rosterable rosterable in selectedItems) {
        if (rosterable is Camper) {
          await preferenceService.rankRandom(commit, rosterable.id);
        }
      }
      await commitRepo.commit(commit);
      await populateActivities();
    } catch (e, st) {
      Error.throwWithStackTrace(Debug.parseException(e), st);
    } finally {
      update(); // Update UI to clear selections
    }
  }

  Future<void> clearPrefsSelected() async {
    if (selectedItems.isEmpty) {
      Debug.logWarning('Can\'t clear selected campers\' preferences');
      return;
    }
    try {
      Commit commit = Commit(
          disarmRequirementsLevel: 1,
          confirmationMessage: 'Are you sure you want to remove these activity preferences? This action cannot be undone.');
      for (Rosterable rosterable in selectedItems) {
        if (rosterable is Camper) {
          await preferenceService.clearPreference(commit, rosterable.id);
        }
      }
      await commitRepo.commit(commit);
      await populateActivities();
    } catch (e, st) {
      Error.throwWithStackTrace(Debug.parseException(e), st);
    } finally {
      update();
    }
  }

  Future<void> smartAssignAll() async {
    try {
      Commit commit = Commit(
          disarmRequirementsLevel: 1,
          confirmationMessage: 'Are you sure you want to overwrite all camper assignments? This action cannot be undone.');
      bool allCampersRanked = await rosterService.allCampersRanked();
      if (allCampersRanked == false) {
        bool? confirmResult = await popupService.showConfirmationDialog(
            title: 'Confirm',
            message: 'Some campers have not finished indicating their preferences yet. '
                'Their preference for these activities will be treated as neutral which could cause fully random assignments. Are you sure you want to proceed?');
        if (confirmResult != true) {
          return;
        }
      }
      Debug.logInfo('Auto assignment starting', userMessage: 'This process could take some time, please wait');
      await assignmentService.runAssignmentAlgorithm(commit: commit, assignmentPenalty: 0.5, nonAssignmentFriction: 0.5);
      await commitRepo.commit(commit);
      await populateActivities();
      Debug.logSuccess('Auto assignment complete', userMessage: 'Auto assignment complete!');
    } catch (e, st) {
      Error.throwWithStackTrace(Debug.parseException(e), st);
    } finally {
      update();
    }
  }

  Future<void> autoAssignSelected() async {
    if (selectedItems.isEmpty) {
      Debug.logWarning('Can\'t assign selected campers');
      return;
    }
    try {
      Commit commit = Commit(
          disarmRequirementsLevel: 1,
          confirmationMessage: 'Are you sure you want to overwrite selected camper assignments? This action cannot be undone.');
      bool selectedCampersRanked = await rosterService.selectedCampersRanked(selectedItems.map((r) => r.id).toSet());
      if (selectedCampersRanked == false) {
        bool? confirmResult = await popupService.showConfirmationDialog(
            title: 'Confirm',
            message: 'Some selected campers have not finished indicating their preferences yet. '
                'Their preference for these activities will be treated as neutral which could cause fully random assignments. Are you sure you want to proceed?');
        if (confirmResult != true) {
          return;
        }
      }
      Debug.logInfo('Auto assignment starting', userMessage: 'This process could take some time, please wait');
      await assignmentService.runAssignmentForCampers(
          commit: commit,
          camperIds: selectedItems.map((rosterable) => rosterable.id).toSet(),
          assignmentPenalty: 0.5,
          nonAssignmentFriction: 0.5);
      await commitRepo.commit(commit);
      await populateActivities();
      Debug.logSuccess('Auto assignment complete', userMessage: 'Auto assignment complete!');
    } catch (e, st) {
      Error.throwWithStackTrace(Debug.parseException(e), st);
    } finally {
      update();
    }
  }

  // Helper & Utility Methods
  /// Pure calculation to determine table and column widths based on available space.
  TableWidths calculateTableWidths(double maxWidth, double indentWidth) {
    if (fields.isEmpty) {
      return TableWidths(adjustedDataWidths: [], actualTableWidth: _checkboxColumnWidth);
    }

    final List<double> defaultDataWidths = fields.map((field) => field.defaultWidth).toList();
    final double minDataWidthSum = defaultDataWidths.reduce((a, b) => a + b);
    final double totalMinWidth = minDataWidthSum + _checkboxColumnWidth;

    List<double> adjustedDataWidths = List.from(defaultDataWidths);
    double actualTableWidth;

    if (maxWidth >= totalMinWidth) {
      final double excessSpace = maxWidth - totalMinWidth;
      adjustedDataWidths[adjustedDataWidths.length - 1] += excessSpace;
      actualTableWidth = maxWidth;
    } else {
      actualTableWidth = totalMinWidth;
    }

    if (groupByField != null) {
      actualTableWidth += indentWidth;
    }

    return TableWidths(adjustedDataWidths: adjustedDataWidths, actualTableWidth: actualTableWidth);
  }

  String getActivityDependentName(Rosterable rosterItem, RosterField field) {
    if (populatingActivities) {
      return 'loading...';
    }

    String activityDependentId = rosterItem.getFieldAsString(field);
    if (activityDependentId.isEmpty) {
      return 'Unassigned';
    }

    final activityDependent = activityDependents.firstWhereOrNull((dep) => dep.id == activityDependentId);
    if (activityDependent == null) {
      return 'Error (not found)';
    }

    final principalActivity = principalActivities[activityDependent.principalPar];
    return principalActivity?.name ?? 'Error (no principal)';
  }

  List<String> getRowDataFromItem(Rosterable rosterItem) {
    final List<String> rowData = [];
    for (final field in fields) {
      if (field is AMABlock) {
        rowData.add(getActivityDependentName(rosterItem, field));
      } else {
        rowData.add(rosterItem.getFieldAsString(field));
      }
    }
    return rowData;
  }
}
