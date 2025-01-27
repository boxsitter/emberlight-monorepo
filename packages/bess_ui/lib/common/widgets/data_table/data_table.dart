import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class BessDataTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<String> columns;

  const BessDataTable({
    super.key,
    required this.data,
    required this.columns,
  });

  @override
  State<BessDataTable> createState() => _BessDataTableState();
}

class _BessDataTableState extends State<BessDataTable> {
  @override
  Widget build(BuildContext context) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 600,
      columns: widget.columns.map((col) => DataColumn(
          label: Text(
            col,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ).toList(),
      rows: widget.data.map((row) {
        return DataRow(
          cells: widget.columns.map((col) {
            return DataCell(
              Text(row[col]?.toString() ?? ""),
              onTap: () {
                // Handle cell tap if necessary
              },
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}