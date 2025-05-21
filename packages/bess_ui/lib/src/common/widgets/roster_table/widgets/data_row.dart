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
        children: List.generate(data.length, (cellIndex) {
          final width = cellIndex < columnWidths.length ? columnWidths[cellIndex] : RosterTableController.minColumnWidth;
          if (cellIndex == 0) {
            return CheckboxCell(controller: controller, rowId: rowId);
          } else {
            return StringCell(content: data[cellIndex - 1], width: width);
          }
        }),
      )
    );
  }
}