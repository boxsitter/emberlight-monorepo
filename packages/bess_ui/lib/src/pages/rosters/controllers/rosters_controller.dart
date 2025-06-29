import 'dart:async';
import 'dart:math';

import 'package:bess_ui/src/common/services/popup_service.dart';
import 'package:ember_core/ember_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/mixins/route_aware_controller_mixin.dart';

class RostersController extends GetxController with RouteAwareControllerMixin {
  final ContextService contextService = Get.find<ContextService>();
  final CabinService cabinsService = Get.find<CabinService>();
  final RosterService rosterService = Get.find<RosterService>();
  final CommitRepository commitRepo = Get.find<CommitRepository>();
  final PullRepository pullRepo = Get.find<PullRepository>();
  final ScheduleService scheduleService = Get.find<ScheduleService>();

  List<Rosterable> roster = [];
  String searchQuery = '';
  final searchController = TextEditingController();
  Timer? _debounce;

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

  List<AMABlock> amas = [];
  Map<PrincipalActivityId, PrincipalActivity> principalActivities = {};
  List<ActivityDependent> activityDependents = [];
  final List<RosterField> fields = [
    RosterField.fullName,
    RosterField.preferredName,
    RosterField.gender,
    RosterField.age,
    RosterField.cabinName
  ];
  double minWidth = 0;

  int get count => filteredRoster.length;
  Set<Rosterable> selectedItems = {};

  bool importingCampers = false;
  bool populatingActivities = false;
  bool assigningCamper = false;

  // Column config
  RosterField? sortByField;
  SortDirection sortDirection = SortDirection.asc;
  RosterField? groupBy;
  bool displayAmas = false;

  // Activity Switcher
  AMABlock? selectedAma;
  ActivityDependent? selectedActivity;

  // View Settings
  bool alternateRowColors = true;
  bool highContrast = false;
  bool rowDividers = false;
  bool compact = true;

  bool columnConfigOpened = false;
  bool activitySwitcherOpened = false;

  // --- Stream Subscription ---
  StreamSubscription<Map<String, Camper>>? _campersSubscription;

  /// A computed list of fields that are available to be added.
  List<RosterField> get availableFields {
    return RosterField.values.where((field) => !fields.contains(field)).toList();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _campersSubscription?.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    // Subscribe to the stream ONLY ONCE when the controller is created.
    Debug.logInfo('RostersController initialized. Starting listener.');
    rosterService.camperStream.then((stream) {
      // Ensure we don't create a duplicate if onInit were ever called again
      _campersSubscription?.cancel();
      _campersSubscription = stream.listen((camperMap) {
        onRosterUpdated(camperMap.values.toList());
      });
    });
  }

  @override
  void onNavigateTo(String to, String? from) {
    // This method is now much simpler. It's only responsible for
    // logic that MUST run every time the page becomes visible.
    Debug.logInfo('RostersController navigated to.');
    populateActivities();
    updateMinimumWidth();
  }

  @override
  void onNavigateFrom(String to, String? from) {
    // We no longer need to manage the subscription here.
    Debug.logInfo('RostersController navigated from.');
  }

  // TODO: NEED TO MAKE THIS A STREAM
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

  void setSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 50), () {
      searchQuery = query;
      update();
    });
  }

  void setColumnOrder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = fields.removeAt(oldIndex);
    fields.insert(newIndex, item);
    // In a real implementation, you would now trigger a data refresh/re-sort
    update();
  }

  void addVisibleColumn(RosterField field) {
    if (!fields.contains(field)) {
      fields.add(field);
      updateMinimumWidth();
      update();
    }
  }

  void removeVisibleColumn(RosterField field) {
    if (fields.contains(field)) {
      fields.remove(field);
      updateMinimumWidth();
      update();
    }
  }

  void setSortBy(RosterField? field) {
    sortByField = field;
    if (field != null) sortDirection = SortDirection.asc;
    update();
  }

  void sort(RosterField field) {
    if (sortByField == field) {
      sortDirection = sortDirection == SortDirection.asc ? SortDirection.desc : SortDirection.asc;
    } else {
      sortByField = field;
      sortDirection = SortDirection.asc;
    }

    roster.sort((a, b) {
      final aValue = a.getFieldAsString(field);
      final bValue = b.getFieldAsString(field);
      final compare = aValue.compareTo(bValue);
      return sortDirection == SortDirection.asc ? compare : -compare;
    });

    update();
  }

  void toggleSortDirection() {
    sortDirection = sortDirection == SortDirection.asc ? SortDirection.desc : SortDirection.asc;
    update();
  }

  void setGroupBy(RosterField? field) {
    groupBy = field;
    update();
  }

  void updateMinimumWidth() {
    double newVal = 0;
    for (RosterField field in fields) {
      newVal += field.defaultWidth;
    }
    minWidth = newVal;
  }

  List<String> getRowDataFromItem(Rosterable rosterItem) {
    final List<String> rowData = [];
    for (final field in fields) {
      if (field.name == 'activityPeriod') {
      if (populatingActivities) {
        rowData.add('loading...');
      } else {
          String activityDependentId = rosterItem.getFieldAsString(field);
        if (activityDependentId.isEmpty) {
            rowData.add('Unassigned');
        } else {
          // Find the ActivityDependent using a more reliable method
          final activityDependent = activityDependents.firstWhereOrNull(
            (dep) => dep.id == activityDependentId,
          );

          if (activityDependent == null) {
            rowData.add('Error (not found)');
            } else {
            final principalActivity = principalActivities[activityDependent.principalPar];
          if (principalActivity == null) {
              rowData.add('Error (no principal activity)');
            } else {
          rowData.add(principalActivity.name);
            }
          }
        }
        }
      } else {
        rowData.add(rosterItem.getFieldAsString(field));
      }
    }
    return rowData;
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

  void toggleRowDividers() {
    rowDividers = !rowDividers;
    update();
  }

  void toggleCompact() {
    compact = !compact;
    update();
  }

  void toggleSecondaryPage(int page) {
    if (page == 1) {
      columnConfigOpened = !columnConfigOpened;
      activitySwitcherOpened = false;
      update();
    } else if (page == 2) {
      activitySwitcherOpened = !activitySwitcherOpened;
      columnConfigOpened = false;
      update();
    }
  }

  void setSelectedAma(Titled block) {
    if (block is AMABlock) {
      if (selectedAma == block) {
        selectedAma = null;
      } else {
        selectedAma = block;
      }
      update();
    }
  }

  void setSelectedActivity(ActivityDependent activity) {
    if (selectedActivity == activity) {
      selectedActivity = null;
    } else {
      selectedActivity = activity;
    }
    update();
  }

  bool isNothingSelected() {
    return selectedItems.isEmpty;
  }

  bool isSingleSelected() {
    return selectedItems.length == 1;
  }

  bool isMultiSelected() {
    return selectedItems.length > 1;
  }

  /// Call this method whenever the roster data is fetched or changed.
  void onRosterUpdated(List<Rosterable> newRoster) {
    roster = newRoster;
    update(); // This will trigger its own update()
  }

  void toggleRowSelection(Rosterable rosterable, bool? newValue) {
    if (newValue == true) {
      selectedItems.add(rosterable);
    } else {
      selectedItems.remove(rosterable);
    }
    update(); // Update UI to reflect selection change
  }

  void toggleSelectAll(bool? select) {
    if (select! && selectedItems.isNotEmpty) {
      selectedItems.clear();
    } else if (select) {
      selectedItems.addAll(filteredRoster);
    } else {
      selectedItems.clear();
    }
    update();
  }

  bool? get headingCheckboxState {
    final filteredIds = filteredRoster.map((e) => e.id).toSet();
    if (filteredIds.isEmpty) return false;
    final selectedFiltered = selectedItems.intersection(filteredIds);

    if (selectedFiltered.isEmpty) {
      return false;
    }
    if (selectedFiltered.length == filteredIds.length) {
      return true;
    }
    return null;
  }

  List<String> getRowData(int rowIndex) {
    Rosterable member = roster[rowIndex];
    List<String> output = [];
    for (RosterField field in fields) {
      output.add(member.getFieldAsString(field));
    }
    return output;
  }

  Future<void> importCsv() async {
    importingCampers = true;
    update(); // Show loading state

    try {
      await commitRepo.commit(await rosterService.importFromCsv());
    } on Exception catch (e, st) {
      Error.throwWithStackTrace(Debug.parseException(e), st);
    } finally {
      importingCampers = false;
      Get.back(); // This will close a dialog, UI updates on the table happen separately
      update(); // Hide loading state
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
      update(); // Update UI to clear selections
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
      update(); // Update UI to clear selections
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
      update(); // Update UI to clear selections
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
      update(); // Update UI to clear selections
    }
  }

  Map<String, bool> getColumnsVisibility() {
    // Create a map from all possible RosterField enum values.
    // The key is the field's title, and the value is whether the controller's
    // `fields` list currently contains that RosterField.
    return {for (var field in RosterField.values) field.title: fields.contains(field)};
  }

  bool noMatches() {
    if (filteredRoster.isEmpty && searchQuery.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void invertSelection() {
    selectedItems = roster.toSet().difference(selectedItems);

    // Update the UI to reflect the change in selection.
    update();
  }
}
