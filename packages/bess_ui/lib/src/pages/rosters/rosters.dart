import 'dart:math';

import 'package:bess_ui/src/pages/rosters/widgets/table/column_header.dart';
import 'package:bess_ui/src/pages/rosters/widgets/table/data_row.dart';
import 'package:bess_ui/src/pages/rosters/widgets/table/header_checkbox.dart';
import 'package:bess_ui/src/pages/rosters/widgets/table_header.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/constants/colors.dart';
import '../../common/constants/sizes.dart';
import '../../common/widgets/containers/rounded_container.dart';
import '../../common/widgets/layouts/templates/site_layout.dart';
import '../../common/widgets/state/controller_dependant_wrapper.dart';
import 'controllers/rosters_controller.dart';

class Rosters extends StatelessWidget {
  const Rosters({
    super.key,
    required this.pageControllerTag,
  });

  final String pageControllerTag;

  @override
  Widget build(BuildContext context) {
    return BessSiteTemplate(desktop: RostersDesktop(pageControllerTag: pageControllerTag));
  }
}

class RostersDesktop extends StatelessWidget {
  RostersDesktop({
    super.key,
    required this.pageControllerTag,
  });

  final String pageControllerTag;
  static const double actualKnownCheckboxColumnWidth = 50.0;
  static const String defaultTitle = 'Campers';
  final List<RosterField> defaultRosterFields = [
    RosterField.fullName,
    RosterField.preferredName,
    RosterField.gender,
    RosterField.age,
    RosterField.cabinName
  ];

  @override
  Widget build(BuildContext context) {
    final RostersController controller = Get.put(
      RostersController(
        defaultTitle: defaultTitle,
        defaultFields: defaultRosterFields,
      ),
      tag: pageControllerTag,
    );

    return ControllerDependantWrapper<RostersController>(
      controller: controller,
      tag: pageControllerTag,
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
                pageControllerTag: pageControllerTag,
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

                    // Determine the layout width. It's the greater of the available width or the content's required width.
                    final double layoutWidth = max(actualKnownCheckboxColumnWidth + totalDataColumnsWidth, constraints.maxWidth);

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
