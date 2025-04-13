import 'package:bessie/common/constants/colors.dart';
import 'package:bessie/common/constants/sizes.dart';
import 'package:bessie/common/widgets/containers/rounded_container.dart';
import 'package:bessie/common/widgets/roster_table/widgets/column_header.dart';
import 'package:bessie/common/widgets/roster_table/widgets/data_row.dart';
import 'package:bessie/common/widgets/roster_table/widgets/table_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/roster_table_controller.dart';

class BessRosterTable extends StatelessWidget {
  final List<String> columns;
  final RosterTableController controller;
  final String tableTitle;
  static const double columnWidth = 250;

  const BessRosterTable({
    super.key,
    required this.columns,
    required this.controller,
    required this.tableTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return BessRoundedContainer(

        showShadow: false,
        showBorder: true,
        borderThickness: BessSizes.borderThicknessMd,
        backgroundColor: BessColors.core,
        padding: EdgeInsets.zero,
        clipContent: true,
        child: Column(
          children: [
            TableHeader(tableTitle: tableTitle, controller: controller),

            Column(
              children: [
                Row(
                  children: List.generate(columns.length, (index) {
                    if (index == columns.length - 1) {
                      return Expanded(
                        child: ColumnHeader(
                          columnLabel: columns[index],
                        ),
                      );
                    } else {
                      // Other columns -> SizedBox with specific width
                      // Check if currentWidths has data to prevent range errors during init
                      final width = index < controller.columnWidths.length ? controller.columnWidths[index] : RosterTableController.minColumnWidth;
                      return SizedBox(
                        width: width, // Apply width from controller's list
                        child: ColumnHeader(
                          columnLabel: columns[index],
                        ),
                      );
                    }
                  }),
                ),

                Divider(
                  height: 1,
                  color: BessColors.borderPrimary,
                ),

                SizedBox(
                  height: 1000,
                  child: ListView.builder(
                    itemCount: controller.processedCampersData.length,
                    itemBuilder: (context, rowIndex) {
                      return BessDataRow(
                        data: controller.processedCampersData[rowIndex], // Data for this specific row
                        columnWidths: controller.columnWidths,  // Pass the *entire* list of widths
                        even: rowIndex % 2 == 0,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

}

