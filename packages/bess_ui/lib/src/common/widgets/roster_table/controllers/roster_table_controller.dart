import 'dart:async';
import 'dart:math';

import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/sizes.dart';
import '../../../styles/text_styles.dart';

class RosterTableController extends GetxController {
  final ClientContextService contextService = Get.find<ClientContextService>();
  final CabinService cabinsService = Get.find<CabinService>();
  final SessionRosterService sessionRosterService = Get.find<SessionRosterService>();
  final RosterService rosterService = Get.find<RosterService>();

  // --- Configuration ---
  List<String> _columnHeaders = []; // Internal storage for column headers
  static const double maxColumnWidth = 300.0;
  static const double minColumnWidth = 80;  // Min width constraint
  static const double horizontalPadding = BessSizes.md;

  // Placeholder TextStyles
  static final TextStyle _headerStyle = BessTextStyles.columnHeader;
  static final TextStyle _dataStyle = BessTextStyles.columnHeader;

  // --- State ---
  final RxList<Rosterable> sortedRoster = <Rosterable>[].obs;

  final RxInt count = 0.obs;
  final RxList<double> columnWidths = <double>[].obs;
  final RxSet<String> selectedRowIds = <String>{}.obs;

  // --- Stream Subscription ---
  StreamSubscription<Map<String, Camper>>? _campersSubscription;

  // --- Public Method to Initialize ---
  void initializeColumns(List<String> headers) {
    _columnHeaders = headers;
  }

  // --- Helper: Measure Text Width (No Padding Added Here) ---
  double _measureTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    // Return only the calculated text width
    double calculatedWidth = textPainter.size.width;
    double widthWithPadding = calculatedWidth + (horizontalPadding * 2);
    double roundedUpToEven = widthWithPadding.ceil() as double;
    if (roundedUpToEven % 2 != 0) {
      roundedUpToEven++;
    }
    if ((roundedUpToEven as int) - ((horizontalPadding as int) * 2) == (minColumnWidth as int)) {
      roundedUpToEven += 2;
    }
    return roundedUpToEven;
  }

  // --- Core Logic: Calculate and Update Widths ---
  void _calculateAndUpdateColumnWidths() {
    if (_columnHeaders.isEmpty) return; // Don't calculate if headers aren't set

    final List<List<String>> currentData = ;
    List<double> calculated = List.filled(_columnHeaders.length, 0.0);

    for (int i = 0; i < _columnHeaders.length; i++) {
      // Measure header width
      double headerWidth = _measureTextWidth(_columnHeaders[i], _headerStyle);

      // Measure max data width for this column
      double maxDataWidth = 0;
      for (var rowData in currentData) {
        if (i < rowData.length) { // Check index validity
          double cellWidth = _measureTextWidth(rowData[i], _dataStyle);
          maxDataWidth = max(maxDataWidth, cellWidth);
        }
      }

      // Determine required width (header vs data)
      double requiredWidth = max(headerWidth, maxDataWidth);

      // Apply min/max constraints (clamping)
      calculated[i] = requiredWidth.clamp(minColumnWidth, maxColumnWidth);
    }

    // Update the reactive list - UI will react via Obx/GetX
    columnWidths.assignAll(calculated);
  }


  // --- Stream Handling Methods ---
  Future<void> _startListening() async {
    final camperStream = await sessionRosterService.camperStream;
    _campersSubscription = camperStream.listen((camperMap) {
      sortedRoster.assignAll(camperMap); // This triggers the 'ever' listener below
    });
  }

  void startListening() {
    if (_campersSubscription == null) {
      print('Started listening to camper stream');
      _startListening();
    }
  }

  void stopListening() {
    if (_campersSubscription != null) {
      print('Stopped listening to camper stream');
      _campersSubscription?.cancel();
      _campersSubscription = null;
    }
  }

  // --- Lifecycle Methods ---
  @override
  void onInit() {
    super.onInit();
    // Reactively update count AND recalculate widths whenever campers map changes

    ever(sortedRoster, (_) {
      count.value = sortedRoster.length;
      _calculateAndUpdateColumnWidths(); // Trigger width calculation on data change
    });
    print('RosterTableController Initialized');
  }

  @override
  void onClose() {
    print('RosterTableController Closing - Stopping Listener');
    stopListening();
    super.onClose();
  }

  void toggleRowSelection(String rowId, bool? newValue) {
    if (newValue != null && newValue) {
      if (!selectedRowIds.contains(rowId)) {
        selectedRowIds.add(rowId);
        return;
      }
    } else if (newValue != null) {
      selectedRowIds.remove(rowId);
      return;
    }

    if (selectedRowIds.contains(rowId)) {
      selectedRowIds.remove(rowId);
    } else {
      selectedRowIds.add(rowId);
    }
  }

  void toggleSelectAll(bool? newValue) {
    if (newValue != null && newValue) {
      selectedRowIds.clear();
      selectedRowIds.addAll(sortedRoster.keys);
      return;
    } else if (newValue != null) {
      selectedRowIds.clear();
      return;
    }

    if (selectedRowIds.isEmpty) {
      selectedRowIds.addAll(sortedRoster.keys);
    } else {
      selectedRowIds.clear();
    }
  }
}
