import 'dart:async';
import 'dart:math';

import 'package:bess_ui/src/common/services/popup_service.dart';
import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_debug.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/mixins/route_aware_controller_mixin.dart';
import '../widgets/popups/roster_importer.dart';

class RostersController extends GetxController with RouteAwareControllerMixin {
  final ContextService contextService = Get.find<ContextService>();
  final CabinService cabinsService = Get.find<CabinService>();
  final SessionRosterService sessionRosterService = Get.find<SessionRosterService>();
  final RosterService rosterService = Get.find<RosterService>();
  final FrontendCommitService commitService = Get.find<FrontendCommitService>();
  final ScheduleService scheduleService = Get.find<ScheduleService>();

  // --- State (Now using standard Dart types) ---
  late String rosterTitle;

  List<Rosterable> roster = [];
  String searchQuery = '';
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
  List<PrincipalActivity> principalActivities = [];
  List<ActivityDependent> activityDependents = [];
  late final List<RosterField> fields;
  double minWidth = 0;

  int get count => filteredRoster.length;
  Set<String> selectedRowIds = {};

  bool importingCampers = false;
  bool populatingActivities = false;

  // Column config
  RosterField? sortByField;
  SortDirection sortDirection = SortDirection.asc;
  RosterField? groupBy;
  bool displayAmas = false;

  // View Settings
  bool alternateRowColors = true;
  bool highContrast = false;
  bool rowDividers = false;
  bool compact = true;

  // --- Stream Subscription ---
  StreamSubscription<Map<String, Camper>>? _campersSubscription;

  RostersController({
    required String defaultTitle,
    required List<RosterField> defaultFields,
  }) {
    rosterTitle = defaultTitle;
    fields = defaultFields;
  }

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
  void onNavigateTo(String to, String? from) {
    Debug.logInfo('RosterTableController navigated to - Starting Listener');
    populateActivities();
    if (_campersSubscription == null) {
      Debug.logInfo('Started listening to camper stream');
      sessionRosterService.camperStream.then((stream) {
        _campersSubscription = stream.listen((camperMap) {
          onRosterUpdated(camperMap.values.toList());
        });
      });
    }
    updateMinimumWidth();
  }

  // TODO: NEED TO MAKE THIS A STREAM
  Future<void> populateActivities() async {
    populatingActivities = true;
    update();
    final List<dynamic> activityData = (await scheduleService.getActivityData());
    amas = (activityData[0] as Set<AMABlock>).toList();
    principalActivities = (activityData[2] as Set<PrincipalActivity>).toList();
    activityDependents = (activityData[1] as Set<ActivityDependent>).toList();
    populatingActivities = false;
    update();
  }

  @override
  void onNavigateFrom(String to, String? from) {
    Debug.logInfo('RosterTableController navigated from - Stopping Listener');
    if (_campersSubscription != null) {
      Debug.logInfo('Stopped listening to camper stream');
      _campersSubscription?.cancel();
      _campersSubscription = null;
    }
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
        // TODO: This sucks
        if (!populatingActivities) {
          String activityDependentId = rosterItem.getFieldAsString(field);
          if (activityDependentId == '') {
            rowData.add('unassigned');
            continue;
          }
          ActivityDependent? activityDependent;
          for (ActivityDependent activityDep in activityDependents) {
            if (activityDep.id == activityDependentId) {
              activityDependent = activityDep;
            } else {
              rowData.add('error');
              continue;
            }
          }

          PrincipalActivity? principalActivity;
          for (PrincipalActivity prinActivity in principalActivities) {
            if (activityDependent!.principalPar == prinActivity.id) {
              principalActivity = prinActivity;
            } else {
              rowData.add('error');
              continue;
            }
          }
          rowData.add(principalActivity!.name);
        } else {
          rowData.add('loading...');
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

  bool isNothingSelected() {
    return selectedRowIds.isEmpty;
  }

  bool isSingleSelected() {
    return selectedRowIds.length == 1;
  }

  bool isMultiSelected() {
    return selectedRowIds.length > 1;
  }

  /// Call this method whenever the roster data is fetched or changed.
  void onRosterUpdated(List<Rosterable> newRoster) {
    roster = newRoster;
    update(); // This will trigger its own update()
  }

  void toggleRowSelection(String rowId, bool? newValue) {
    if (newValue == true) {
      selectedRowIds.add(rowId);
    } else {
      selectedRowIds.remove(rowId);
    }
    update(); // Update UI to reflect selection change
  }

  void toggleSelectAll(bool? select) {
    final filteredIds = filteredRoster.map((e) => e.id).toSet();
    if (select! && selectedRowIds.isNotEmpty) {
      selectedRowIds.clear();
    } else if (select) {
      selectedRowIds.addAll(filteredIds);
    } else {
      selectedRowIds.clear();
    }
    update();
  }

  bool? get headingCheckboxState {
    final filteredIds = filteredRoster.map((e) => e.id).toSet();
    if (filteredIds.isEmpty) return false;
    final selectedFiltered = selectedRowIds.intersection(filteredIds);

    if (selectedFiltered.isEmpty) {
      return false;
    }
    if (selectedFiltered.length == filteredIds.length) {
      return true;
    }
    return null;
  }

  List<String> getRowData(int rowIndex) {
    return rosterService.getRowData(roster, rowIndex, fields);
  }

  Future<bool> showImporterPopup() {
    PopupService popupService = Get.find<PopupService>();
    return popupService.showFullScreenDialog(
      title: 'Import Roster From UltraCamp',
      child: RosterImporter(
        isImporting: importingCampers,
        onImport: importCsv,
      ),
    );
  }

  Future<void> importCsv() async {
    importingCampers = true;
    update(); // Show loading state

    try {
      await commitService.commit(await sessionRosterService.importFromCsv());
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
      Set<Camper> campersToDelete = await BackendManager.instance.getObjects(selectedRowIds);
      commit.addObjectsToDelete(campersToDelete);
      await commitService.commit(commit);
    } finally {
      selectedRowIds.clear();
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
    // Create a set of all possible IDs from the main roster list.
    final allIds = roster.map((rosterable) => rosterable.id).toSet();

    // The new set of selected IDs will be all IDs from the roster
    // that are not currently in the selectedRowIds set.
    // The `difference` method on sets is perfect for this.
    selectedRowIds = allIds.difference(selectedRowIds);

    // Update the UI to reflect the change in selection.
    update();
  }
}
