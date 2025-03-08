import 'package:bessie/common/widgets/roster_table/widgets/string_cell.dart';
import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class BessDataRow extends StatelessWidget {
  final List<String> data;
  final double cellWidth;

  const BessDataRow({
    super.key,
    required this.data,
    required this.cellWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: BessColors.crust, width: 2))),
      child: Row (
        mainAxisAlignment: MainAxisAlignment.start,
        children: data.map((String cellContent) => StringCell(content: cellContent, width: cellWidth,)).toList(),
      ),
    );
  }
}