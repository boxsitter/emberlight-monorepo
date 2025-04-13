import 'dart:async';
import 'dart:math';

import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../styles/text_styles.dart';

class RosterTableController extends GetxController {
  final ClientContextService contextService = Get.find<ClientContextService>();
  final CabinService cabinsService = Get.find<CabinService>();
  final SessionRosterService sessionRosterService = Get.find<SessionRosterService>();

  // --- Configuration ---
  List<String> _columnHeaders = []; // Internal storage for column headers
  static const double maxColumnWidth = 300; // Max width constraint
  static const double minColumnWidth = 80;  // Min width constraint

  // Placeholder TextStyles
  static final TextStyle _headerStyle = BessTextStyles.columnHeader;
  static final TextStyle _dataStyle = BessTextStyles.columnHeader;

  // --- State ---
  final RxMap<String, Camper> campers = <String, Camper>{}.obs;
  final RxInt count = 0.obs;
  final RxList<double> columnWidths = <double>[].obs;

  // --- Stream Subscription ---
  StreamSubscription<Map<String, Camper>>? _campersSubscription;

  // --- Derived State (Getter for Processed Data) ---
  List<List<String>> get processedCampersData {
    return campers.values.map((camper) {
      return [
        camper.fullName,
        camper.preferredName,
        camper.gender,
        camper.age.toString(),
        camper.cabinName ?? 'none',
      ];
    }).toList();
  }

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
    return textPainter.size.width;
  }

  // --- Core Logic: Calculate and Update Widths ---
  void _calculateAndUpdateColumnWidths() {
    if (_columnHeaders.isEmpty) return; // Don't calculate if headers aren't set

    final List<List<String>> currentData = processedCampersData;
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
    print('Column widths calculated: $columnWidths'); // For debugging
  }


  // --- Stream Handling Methods ---
  void _startListening() {
    _campersSubscription = sessionRosterService.camperStream.listen((camperMap) {
      campers.assignAll(camperMap); // This triggers the 'ever' listener below
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

    ever(campers, (_) {
      count.value = campers.length;
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
}
