import 'package:bessie/common/constants//colors.dart';
import 'package:bessie/common/widgets/containers/rounded_container.dart';
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
    return BessRoundedContainer(
      showShadow: true,
      showBorder: true,
      borderThickness: 2,
      backgroundColor: BessColors.core,
      borderColor: BessColors.element1,
      padding: EdgeInsets.zero,
      child: DataTable2(
        columnSpacing: 0,
        horizontalMargin: 12,
        minWidth: 0,
        dividerThickness: 0,
        dataRowHeight: 35,
        headingRowHeight: 50,
        border: TableBorder(
          horizontalInside: BorderSide(
            color: BessColors.element1,
            width: 1,
          ),
        ),
        headingRowDecoration: BoxDecoration(
          color: BessColors.element1,
        ),
        columns:  widget.columns.map((col) {
          return DataColumn2(
            label: Text(
              col,
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
          );
        }).toList(),
        rows: widget.data.map((row) {
          return DataRow2(
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
      ),
    );
  }
}