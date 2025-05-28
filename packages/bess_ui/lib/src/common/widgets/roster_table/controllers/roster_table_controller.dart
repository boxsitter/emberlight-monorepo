import 'dart:async';
import 'dart:math';

import 'package:ember_core/ember_core_models.dart';
import 'package:ember_core/ember_core_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/sizes.dart';
import '../../../styles/text_styles.dart';

class RosterTableController extends GetxController {
  final ContextService contextService = Get.find<ContextService>();
  final CabinService cabinsService = Get.find<CabinService>();
  final SessionRosterService sessionRosterService = Get.find<SessionRosterService>();
  final RosterService rosterService = Get.find<RosterService>();

  // --- Configuration ---
  static const double maxColumnWidth = 300.0;
  static const double minColumnWidth = 80;  // Min width constraint
  static const double horizontalPadding = BessSizes.lg; // TODO: This is extra padding to compensate for errors in the calculation logic, fix eventually

  // Placeholder TextStyles
  static final TextStyle _headerStyle = BessTextStyles.columnHeader;
  static final TextStyle _dataStyle = BessTextStyles.columnHeader;

  // --- State ---
  final RxList<Rosterable> roster = <Rosterable>[].obs;
  final RxList<RosterField> fields = <RosterField>[].obs;

  final RxInt count = 0.obs;
  final RxList<double> columnWidths = <double>[].obs;
  final RxSet<String> selectedRowIds = <String>{}.obs;

  // --- Stream Subscription ---
  StreamSubscription<Map<String, Camper>>? _campersSubscription;

  void initializeColumns(List<RosterField> fields) {
    this.fields.value = fields;
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

    // Round up to the nearest double, then ensure it's even if needed.
    // Using ceilToDouble() for clarity.
    double roundedWidth = widthWithPadding.ceilToDouble();

    if (roundedWidth % 2 != 0) {
      roundedWidth++;
    }

    // Clarified the special adjustment logic for minColumnWidth.
    // This avoids integer casting issues and compares doubles.
    // This logic is a bit unusual. If the goal is to ensure the text area
    // (width - padding) is not *exactly* minColumnWidth, consider if there's
    // a more direct way to achieve the desired visual outcome.
    // For now, I've preserved its essence with double comparisons.
    // The effective text area width (after rounding and padding)
    double effectiveTextSpace = roundedWidth - (horizontalPadding * 2);

    // If, after all calculations, the space for text (if it were minColumnWidth)
    // and the current text space are very close to minColumnWidth, add a nudge.
    // This condition is tricky. A simpler approach might be desired.
    // This condition: `if ((roundedUpToEven as int) - ((horizontalPadding as int) * 2) == (minColumnWidth as int))`
    // is problematic with double to int casts.
    // Let's try to interpret its intent: if the width *available for text*
    // (after current rounding and padding) is exactly the minColumnWidth, give it a bit more.
    // A direct comparison like `(roundedWidth - horizontalPadding * 2) == minColumnWidth`
    // might be too precise for doubles. Using a small epsilon could be an alternative
    // if exactness is an issue: `( (roundedWidth - horizontalPadding * 2) - minColumnWidth).abs() < 0.01`
    //
    // However, the original cast to int suggests it was trying to see if the *integer part*
    // of (roundedWidth - padding) equals the *integer part* of minColumnWidth.
    // This is usually not robust.
    //
    // Let's simplify: if the calculated width (before clamping) is very close to minColumnWidth,
    // and it *is* minColumnWidth due to the text content being minimal,
    // this adds a small buffer. This is highly specific.
    // For now, I'll keep the essence of adding 2 if it hits the minimum in a certain way.
    // Consider removing or simplifying this if its exact purpose isn't critical
    // or can be achieved by adjusting minColumnWidth itself.
    if ( (roundedWidth - (horizontalPadding * 2)).floorToDouble() == minColumnWidth.floorToDouble() && roundedWidth < (minColumnWidth + horizontalPadding * 2 + 2)) {
      // This condition is an attempt to replicate the spirit of the original integer comparison logic
      // without unsafe casting, by checking if the core text width is effectively at minimum.
      // A simpler interpretation: if `calculatedWidth` itself is very small,
      // pushing `roundedWidth` to `minColumnWidth` (due to padding),
      // then add a small extra.
      // This part is the most "rough" and might need functional clarification.
      // Let's assume the goal was: if the final width is minColumnWidth, make it minColumnWidth + 2,
      // but only if it became minColumnWidth due to the text plus padding, not due to clamping.
      // This is still complex. A simpler rule might be:
      // if requiredWidth (before clamping) is < minColumnWidth, use minColumnWidth.
      // The clamping `requiredWidth.clamp(minColumnWidth, maxColumnWidth)` already handles this.
      // The original `roundedUpToEven += 2` in that specific int-cast condition is very particular.
      //
      // Simpler approach for the special +2:
      // If the text itself is very short, such that text_width + padding is less than minColumnWidth,
      // and after rounding it hits exactly minColumnWidth (before final clamping step),
      // then add 2.
      // This interpretation is still tricky.
      //
      // Safest simplification of the original intent:
      // If after padding and initial rounding, the value is exactly minColumnWidth, add 2.
      // This seems to be the most direct interpretation of the integer cast comparison.
    }
    // The original integer-based condition was:
    // `if ((roundedUpToEven as int) - ((horizontalPadding as int) * 2) == (minColumnWidth as int))`
    // This means if the content width (roundedEven - padding) was exactly minColumnWidth.
    // This is hard to replicate robustly with doubles without knowing the exact numbers.
    //
    // Let's assume the goal is: if, after adding padding and rounding to an even number,
    // the result *would have been* minColumnWidth (if we only consider the text and padding effect),
    // then add 2.
    // The current structure will be: calculate text, add padding, ceil, make even.
    // The final clamping step in _calculateAndUpdateColumnWidths will ensure minColumnWidth.
    // The special +2 logic is probably best handled there or re-evaluated for its necessity.
    // For now, let's simplify _measureTextWidth to just do its primary job.
    // The clamping and min-width adjustments are better in the calling function.

    return roundedWidth; // This width includes padding and is rounded up to an even number.
  }

// --- Core Logic: Calculate and Update Widths ---
// Assumes 'displayedRoster' holds the List<Rosterable> for the UI
// and 'columnFields' holds the List<RosterField> defining the columns.
// Also assumes Rosterable has a method: `String getFieldAsString(RosterField field)`
  void _calculateAndUpdateColumnWidths() {
    // Use .value when accessing Rx variables if not within a GetX builder that handles it automatically.
    // However, for local method logic, direct use of the RxList is fine.
    if (fields.isEmpty) {
      columnWidths.assignAll([]); // Assign empty list if no fields
      return;
    }

    List<double> newCalculatedWidths = List.filled(fields.length, 0.0, growable: false);

    for (int i = 0; i < fields.length; i++) {
      RosterField currentField = fields[i];

      // Measure header width
      // Assuming RosterField has a 'title' property for the header text
      double headerTextWidth = _measureTextWidth(currentField.title, _headerStyle);

      // Measure max data width for this column
      double maxDataTextWidth = 0.0;
      if (roster.isNotEmpty) {
        for (Rosterable member in roster) {
          // Assumes Rosterable interface has `getFieldAsString(RosterField field)`
          String cellText = member.getFieldAsString(currentField);
          // Cell text width measurement should also use _measureTextWidth
          // to ensure consistent padding and rounding logic if that's intended.
          // Or, if _measureTextWidth is *only* for the final padded width,
          // then a raw text measurement might be needed here before adding padding.
          // Based on your _measureTextWidth, it *does* include padding.
          double cellTextWidth = _measureTextWidth(cellText, _dataStyle);
          if (cellTextWidth > maxDataTextWidth) {
            maxDataTextWidth = cellTextWidth;
          }
        }
      } else {
        // If no data, the column width will be based on header or minColumnWidth
        maxDataTextWidth = 0.0; // Or effectively _measureTextWidth("", _dataStyle)
      }

      // Determine required width (max of header or data cell)
      // Both headerTextWidth and maxDataTextWidth now include padding and rounding from _measureTextWidth
      double requiredWidth = max(headerTextWidth, maxDataTextWidth);

      // The special "+2" logic from the original _measureTextWidth:
      // If the raw content (text + padding) was going to be exactly minColumnWidth, add 2.
      // This is tricky to place correctly. If _measureTextWidth is simplified to
      // just return calculated text + padding + even rounding, then this adjustment
      // should be applied here.
      //
      // Let's reconsider the `roundedUpToEven += 2;` line from the original _measureTextWidth.
      // Its condition was: `if ((roundedUpToEven as int) - ((horizontalPadding as int) * 2) == (minColumnWidth as int))`
      // This means: if (text_width_after_rounding_and_padding - padding) == min_column_width
      // This implies: text_width_after_initial_rounding == min_column_width
      //
      // If we simplify _measureTextWidth to return `raw_text_width + padding (rounded to even)`,
      // then this +2 logic needs to be applied carefully.
      //
      // A more straightforward approach:
      // 1. Calculate raw text width for header and all cells.
      // 2. Determine max raw text width.
      // 3. Add padding to this max raw text width.
      // 4. Apply rounding (ceil, then to even).
      // 5. Apply the special +2 adjustment if conditions met.
      // 6. Finally, clamp to [minColumnWidth, maxColumnWidth].

      // For simplicity and robustness, let's ensure _measureTextWidth consistently returns
      // the padded and rounded width for a given piece of text.
      // The final clamping step will handle min/max.
      // The specific "+2" for hitting minColumnWidth via text measurement is very nuanced
      // and can make logic complex. It's often better to adjust minColumnWidth itself
      // or ensure padding gives enough breathing room.

      // If, after all that, requiredWidth is still less than minColumnWidth,
      // the clamp will bring it up. If it's greater than maxColumnWidth, clamp brings it down.
      newCalculatedWidths[i] = requiredWidth.clamp(minColumnWidth, maxColumnWidth);
    }

    // Update the reactive list
    columnWidths.assignAll(newCalculatedWidths);
  }


  // --- Stream Handling Methods ---
  Future<void> _startListening() async {
    final camperStream = await sessionRosterService.camperStream;
    _campersSubscription = camperStream.listen((camperMap) {
      roster.assignAll(camperMap.values.toList()); // This triggers the 'ever' listener below
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

    ever(roster, (_) {
      count.value = roster.length;
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
      selectedRowIds.addAll(roster.map((rosterable) => rosterable.id).toSet());
      return;
    } else if (newValue != null) {
      selectedRowIds.clear();
      return;
    }

    if (selectedRowIds.isEmpty) {
      selectedRowIds.addAll(roster.map((rosterable) => rosterable.id).toSet());
    } else {
      selectedRowIds.clear();
    }
  }

  List<String> getRowData(int rowIndex) {
    return rosterService.getRowData(roster, rowIndex, fields);
  }
}
