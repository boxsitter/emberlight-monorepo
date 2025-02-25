import 'package:bessie/common/constants//colors.dart';
import 'package:bessie/common/styles/text_styles.dart';
import 'package:bessie/common/widgets/containers/rounded_container.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/data_table_controller.dart';

class BessDataTable extends StatefulWidget {
  final List<String> columns;
  final DataTableController controller;

  const BessDataTable({
    super.key,
    required this.columns,
    required this.controller,
  });

  @override
  State<BessDataTable> createState() => _BessDataTableState();
}

class _BessDataTableState extends State<BessDataTable> {
  late DataTableController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      print("Updating UI with campers: ${controller.campers.values}");
      List<Map<String, dynamic>> data = controller.campers.values.map((camper) {
        return {
          "Name": camper.fullName,
          "Preferred Name": camper.preferredName,
          "Gender": camper.gender,
          "Age": camper.age,
          "Cabin": camper.cabin?.name ?? "None",
        };
      }).toList();

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
          dataRowHeight: 60,
          headingRowHeight: 50,
          headingTextStyle: BessTextStyles.label,
          dataTextStyle: BessTextStyles.standard,
          border: TableBorder(
            horizontalInside: BorderSide(
              color: BessColors.element1,
              width: 1,
            ),
          ),
          headingRowDecoration: BoxDecoration(
            color: BessColors.element1,
          ),
          columns: widget.columns.map((col) {
            return DataColumn2(
              label: Text(
                col,
              ),
            );
          }).toList(),
          rows: data.map((row) {
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
    });
  }
}