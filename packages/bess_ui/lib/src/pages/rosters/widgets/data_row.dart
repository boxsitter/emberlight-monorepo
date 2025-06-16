import 'package:bess_ui/src/pages/rosters/widgets/string_cell.dart';
import 'package:flutter/material.dart';

import '../../../common/constants/colors.dart';
import '../controllers/roster_table_controller.dart';
import 'checkbox_cell.dart';

class BessDataRow extends StatelessWidget {
  final List<String> data;
  final List<double> columnWidths;
  final bool isSelected;
  final ValueChanged<bool?>? onToggle;
  final bool? even;

  const BessDataRow({
    super.key,
    required this.data,
    required this.columnWidths,
    required this.isSelected,
    required this.onToggle,
    this.even,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: even ?? false ? BessColors.core : BessColors.background,
      ),
      child: Row(
        children: [
          // The first cell is always the checkbox
          CheckboxCell(
            isSelected: isSelected,
            onChanged: onToggle,
          ),
          // The rest are the data cells
          ...List.generate(data.length, (index) {
            final String cellContent = data[index];
            final double widthForDataCell = (index < columnWidths.length)
                ? columnWidths[index]
                : RosterTableController.minColumnWidth; // Fallback

            return StringCell(
              content: cellContent,
              width: widthForDataCell,
            );
          }),
        ],
      ),
    );
  }
}