import 'dart:async';
import 'dart:math';

import 'package:bess_ui/src/common/services/popup_service.dart';
import 'package:bess_ui/src/common/utils/helpers/helper_functions.dart';
import 'package:ember_core/ember_core_backend.dart';
import 'package:ember_core/ember_core_debug.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/constants/sizes.dart';
import '../../../common/mixins/route_aware_controller_mixin.dart';
import '../../../common/styles/text_styles.dart';
import '../widgets/popups/roster_importer.dart';

class RosterTableController extends GetxController with RouteAwareControllerMixin {
  final ContextService contextService = Get.find<ContextService>();
  final CabinService cabinsService = Get.find<CabinService>();
  final SessionRosterService sessionRosterService = Get.find<SessionRosterService>();
  final RosterService rosterService = Get.find<RosterService>();
  final FrontendCommitService commitService = Get.find<FrontendCommitService>();

  // --- Configuration ---
  static const double maxColumnWidth = 300.0;
  static const double minColumnWidth = 80;
  static const double horizontalPadding = BessSizes.lg;
  static final TextStyle _headerStyle = BessTextStyles.columnHeader;
  static final TextStyle _dataStyle = BessTextStyles.columnHeader;

  // --- State (Now using standard Dart types) ---
  late String rosterTitle;
  final bool includeAmas;

  List<Rosterable> roster = [];
  List<RosterField> fields = [];

  int count = 0;
  List<double> columnWidths = [];
  Set<String> selectedRowIds = {};

  bool importingCampers = false;

  Map<String, String> amaBlockNames = {};
  String? selectedAMABlockId;

  // --- Stream Subscription ---
  StreamSubscription<Map<String, Camper>>? _campersSubscription;

  RosterTableController({
    required String defaultTitle,
    required List<RosterField> defaultColumns,
    this.includeAmas = false,
  }) {
    rosterTitle = defaultTitle;
    fields = defaultColumns;
  }

  @override
  void onNavigateTo() {
    Debug.logInfo('RosterTableController navigated to - Starting Listener');
    if (_campersSubscription == null) {
      Debug.logInfo('Started listening to camper stream');
      sessionRosterService.camperStream.then((stream) {
        _campersSubscription = stream.listen((camperMap) {
          onRosterUpdated(camperMap.values.toList());
        });
      });
    }
    if (includeAmas) {
      Get.find<ScheduleService>().getAMABlocks().then((amaBlocks) {
        amaBlockNames = amaBlocks.map((key, value) => MapEntry(key, value.name));
        Map<String, List<DateTime>> intervals = {};
        for (AMABlock block in amaBlocks.values) {
          intervals[block.id] = [block.start, block.end];
        }
        final nextBlockId = BessHelperFunctions.findNextOrCurrentInterval(intervals);
        if (nextBlockId != null) {
          selectedAMABlockId = nextBlockId;
        }
        update();
      });
    }
  }

  @override
  void onNavigateFrom() {
    Debug.logInfo('RosterTableController navigated from - Stopping Listener');
    if (_campersSubscription != null) {
      Debug.logInfo('Stopped listening to camper stream');
      _campersSubscription?.cancel();
      _campersSubscription = null;
    }
  }

  /// Call this method whenever the roster data is fetched or changed.
  void onRosterUpdated(List<Rosterable> newRoster) {
    roster = newRoster;
    count = roster.length;
    calculateAndUpdateColumnWidths(); // This will trigger its own update()
  }

  // Simplified and clarified rounding/padding.
  double _measureTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    double calculatedWidth = textPainter.size.width;
    double widthWithPadding = calculatedWidth + (horizontalPadding * 2);
    double roundedWidth = widthWithPadding.ceilToDouble();

    if (roundedWidth % 2 != 0) {
      roundedWidth++;
    }
    return roundedWidth;
  }

  void calculateAndUpdateColumnWidths() {
    if (fields.isEmpty) {
      columnWidths = [];
      update(); // Update UI
      return;
    }

    List<double> newCalculatedWidths = List.filled(fields.length, 0.0, growable: false);

    for (int i = 0; i < fields.length; i++) {
      RosterField currentField = fields[i];
      double headerTextWidth = _measureTextWidth(currentField.title, _headerStyle);

      double maxDataTextWidth = 0.0;
      if (roster.isNotEmpty) {
        maxDataTextWidth =
            roster.map((member) => _measureTextWidth(member.getFieldAsString(currentField), _dataStyle)).reduce(max);
      }

      double requiredWidth = max(headerTextWidth, maxDataTextWidth);
      newCalculatedWidths[i] = requiredWidth.clamp(minColumnWidth, maxColumnWidth);
    }

    columnWidths = newCalculatedWidths;
    update(); // Update the UI with the new column widths
  }

  void toggleRowSelection(String rowId, bool? newValue) {
    if (newValue == true) {
      selectedRowIds.add(rowId);
    } else {
      selectedRowIds.remove(rowId);
    }
    update(); // Update UI to reflect selection change
  }

  void toggleSelectAll(bool? newValue) {
    if (newValue == true) {
      selectedRowIds = roster.map((rosterable) => rosterable.id).toSet();
    } else {
      selectedRowIds.clear();
    }
    update(); // Update UI to reflect selection change
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
}
