import 'package:bessie/common/utils/device/web_material_scroll.dart';
import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import 'column_header.dart';
import 'data_row.dart';

class BessTable extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> data;
  final double columnWidth;

  const BessTable({
    super.key,
    required this.columns,
    required this.data,
    required this.columnWidth,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: columns.map((String column) => ColumnHeader(columnLabel: column, width: columnWidth)).toList(),
        ),

        Divider(
          height: 1,
          color: BessColors.borderPrimary,
        ),

        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return BessDataRow(data: data[index], cellWidth: columnWidth,);
            },
          ),
        ),
      ],
    );
  }
}
