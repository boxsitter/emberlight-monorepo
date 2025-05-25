import 'dart:math';

import 'package:bess_ui/src/common/constants/colors.dart';
import 'package:bess_ui/src/common/constants/sizes.dart';
import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:bess_ui/src/common/widgets/roster_table/widgets/column_header.dart';
import 'package:bess_ui/src/common/widgets/roster_table/widgets/data_row.dart';
import 'package:bess_ui/src/common/widgets/roster_table/widgets/header_checkbox.dart';
import 'package:bess_ui/src/common/widgets/roster_table/widgets/table_header.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/roster_table_controller.dart';

class BessRosterTable extends StatelessWidget {
  final List<RosterField> fields;
  final RosterTableController controller;
  final String tableTitle;

  const BessRosterTable({
    super.key,
    required this.fields,
    required this.controller,
    required this.tableTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Ensure widths are calculated and match column count
      if (controller.columnWidths.isEmpty || controller.columnWidths.length != fields.length) {
        if (controller.columnWidths.isEmpty && fields.isNotEmpty) {
          // Initialize with minimums if empty but headers exist
          controller.columnWidths.assignAll(List.filled(fields.length, RosterTableController.minColumnWidth));
        } else {
          // Or return a loading state if critical info is missing
          return const Center(child: CircularProgressIndicator(key: ValueKey('loading')));
        }
      }

      // Calculate the total minimum width required by the content
      final double totalContentWidth = controller.columnWidths.reduce((a, b) => a + b);

      return BessRoundedContainer(
        showShadow: false,
        showBorder: true,
        borderThickness: BessSizes.borderThicknessMd,
        backgroundColor: BessColors.core,
        padding: EdgeInsets.zero,
        clipContent: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TableHeader(tableTitle: tableTitle, controller: controller),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                final double availableWidth = constraints.maxWidth;
                final double layoutWidth = max(totalContentWidth, availableWidth);

                return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: layoutWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: BessColors.background,
                            ),
                            child: Row(
                              children: List.generate(fields.length, (index) {
                                final width = index < controller.columnWidths.length
                                    ? controller.columnWidths[index]
                                    : RosterTableController.minColumnWidth;
                                if (index == 0) {
                                  return HeaderCheckbox(
                                    controller: controller,
                                  );
                                } else {
                                  return ColumnHeader(
                                    columnLabel: fields[index].title,
                                    width: width,
                                  );
                                }
                              }),
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: BessColors.borderPrimary,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: controller.roster.length,
                              itemBuilder: (context, rowIndex) {
                                return BessDataRow(
                                  controller: controller,
                                  rowId: controller.roster[rowIndex].id,
                                  data: controller.getRowData(rowIndex), // Data for this specific row
                                  columnWidths: controller.columnWidths, // Pass the *entire* list of widths
                                  even: rowIndex % 2 == 0,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ));
              }),
            ),
          ],
        ),
      );
    });
  }
}
