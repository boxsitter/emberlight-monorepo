import 'package:bess_ui/src/common/widgets/roster_table/widgets/checkbox_cell.dart';
import 'package:bess_ui/src/common/widgets/roster_table/widgets/string_cell.dart';
import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../controllers/roster_table_controller.dart';

class BessDataRow extends StatelessWidget {
  final RosterTableController controller;
  final String rowId;
  final List<String> data;
  final List<double> columnWidths;
  final bool? even;

  const BessDataRow({
    super.key,
    required this.controller,
    required this.rowId,
    required this.data,
    required this.columnWidths,
    this.even,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: even ?? false ? BessColors.core : BessColors.background,
      ),
      child: Row(
        // Generate data.length + 1 children: 1 checkbox + data.length data cells
        children: List.generate(data.length + 1, (cellIndex) {
          if (cellIndex == 0) {
            // Checkbox Cell
            // Assumes CheckboxCell defines its own width or uses a standard.
            // If it needs an explicit width for the Row, wrap in SizedBox or pass width to it.
            // The 'columnWidths' prop of BessDataRow is for data fields.
            return CheckboxCell(controller: controller, rowId: rowId);
          } else {
            // Data Cell
            final dataIndex = cellIndex - 1; // Index for 'data' list and 'columnWidths' list

            // Ensure dataIndex is valid for 'data' list (it should be if data.length > 0)
            final String cellContent = (dataIndex < data.length) ? data[dataIndex] : "";

            // 'columnWidths' are the widths for the data fields, passed from BessRosterTable
            final widthForDataCell = (dataIndex < columnWidths.length)
                ? columnWidths[dataIndex]
                : RosterTableController.minColumnWidth; // Fallback

            return StringCell(content: cellContent, width: widthForDataCell);
          }
        }),
      )
    );
  }
}