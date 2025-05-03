import 'package:bess_ui/common/widgets/roster_table/widgets/string_cell.dart';
import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../controllers/roster_table_controller.dart';

class BessDataRow extends StatelessWidget {
  final List<String> data;
  final List<double> columnWidths;
  final bool? even;

  const BessDataRow({
    super.key,
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
          return StringCell(content: data[cellIndex], width: width);
        }),
      )
    );
  }
}