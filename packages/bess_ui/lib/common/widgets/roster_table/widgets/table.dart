import 'package:flutter/material.dart';

import 'column_header.dart';

class BessTable extends StatelessWidget {
  const BessTable({
    super.key,
    required this.columns,
  });

  final List<String> columns;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: columns.map((String column) => Expanded(
        child: ColumnHeader(columnLabel: column),
      )).toList(),
    );
  }
}
