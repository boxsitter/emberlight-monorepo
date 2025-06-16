import 'dart:math';

import 'package:bess_ui/src/common/constants/colors.dart';
import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:bess_ui/src/pages/rosters/widgets/column_header.dart';
import 'package:bess_ui/src/pages/rosters/widgets/data_row.dart';
import 'package:bess_ui/src/pages/rosters/widgets/header_checkbox.dart';
import 'package:bess_ui/src/pages/rosters/widgets/table_header.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/constants/sizes.dart';
import '../../common/widgets/state/controller_dependant_wrapper.dart';
import 'controllers/roster_table_controller.dart';

class BessRosterTable extends StatelessWidget {
  final List<RosterField> fields;
  final String defaultTitle;
  final String controllerTag;
  static const double actualKnownCheckboxColumnWidth = 50.0;

  const BessRosterTable({
    super.key,
    required this.defaultTitle,
    required this.fields,
    required this.controllerTag,
  });

  @override
  Widget build(BuildContext context) {
    final RosterTableController controller = Get.put(
      RosterTableController(
        defaultTitle: defaultTitle,
        defaultColumns: fields,
      ),
      tag: controllerTag,
    );

    return ControllerDependantWrapper<RosterTableController>(
      controller: controller,
      tag: controllerTag,
      builder: (controller) {
        return BessRoundedContainer(
          showShadow: false,
          showBorder: true,
          borderThickness: BessSizes.borderThicknessMd,
          backgroundColor: BessColors.core,
          padding: EdgeInsets.zero,
          clipContent: true,
          child: Column(
            children: [
              // This TableHeader remains fixed at the top and does not scroll horizontally
              TableHeader(
                title: controller.rosterTitle,
                count: controller.count,
                selectedRowIds: controller.selectedRowIds,
                onImport: controller.showImporterPopup,
                onDelete: controller.deleteSelected,
              ),
              // This Expanded section will contain the horizontally scrollable table content
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate the total width required by all data columns
                    final double totalDataColumnsWidth =
                        controller.columnWidths.isEmpty ? 0.0 : controller.columnWidths.reduce((a, b) => a + b);

                    // Add the fixed width of the checkbox column
                    final double totalContentWidth = actualKnownCheckboxColumnWidth + totalDataColumnsWidth;

                    // Determine the layout width. It's the greater of the available width or the content's required width.
                    final double layoutWidth = max(totalContentWidth, constraints.maxWidth);

                    // Use a SingleChildScrollView to enable horizontal scrolling
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: layoutWidth,
                        child: Column(
                          children: [
                            // The row of column headers
                            Container(
                              decoration: BoxDecoration(
                                color: BessColors.background,
                              ),
                              child: Row(
                                children: [
                                  HeaderCheckbox(
                                    totalRowCount: controller.roster.length,
                                    selectedRowCount: controller.selectedRowIds.length,
                                    onChanged: (value) => controller.toggleSelectAll(value),
                                  ),
                                  if (controller.columnWidths.length == controller.fields.length)
                                    ...List.generate(
                                      controller.fields.length,
                                      (index) => ColumnHeader(
                                        columnLabel: controller.fields[index].title,
                                        width: controller.columnWidths[index],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Divider(height: 1, color: BessColors.borderPrimary),
                            // The list of data rows
                            Expanded(
                              child: ListView.builder(
                                itemCount: controller.roster.length,
                                itemBuilder: (context, rowIndex) {
                                  final rosterItem = controller.roster[rowIndex];
                                  final isSelected = controller.selectedRowIds.contains(rosterItem.id);
                                  return BessDataRow(
                                    data: controller.getRowData(rowIndex),
                                    columnWidths: controller.columnWidths,
                                    isSelected: isSelected,
                                    onToggle: (newValue) => controller.toggleRowSelection(rosterItem.id, newValue),
                                    even: rowIndex % 2 == 0,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
