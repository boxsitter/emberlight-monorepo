import 'package:bess_ui/src/common/styles/text_styles.dart';
import 'package:bess_ui/src/common/utils/helpers/helper_functions.dart';
import 'package:bess_ui/src/pages/rosters/widgets/table/table_row.dart';
import 'package:flutter/material.dart';

import '../../../../common/constants/colors.dart';
import '../../controllers/rosters_controller.dart';

class RostersTable extends StatelessWidget {
  const RostersTable({
    super.key,
    required this.controller,
  });

  final RostersController controller;

  static const double _checkboxColumnWidth = 50.0;

  @override
  Widget build(BuildContext context) {
    if (controller.fields.isEmpty) {
      return const Center(child: Text('Add some columns!'));
    } else if (controller.filteredRoster.isEmpty && controller.searchQuery.isNotEmpty) {
      return Center(child: Text('No campers found for "${controller.searchQuery}".'));
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          final List<double> defaultDataWidths = controller.fields.map((field) => field.defaultWidth).toList();
          final double minDataWidthSum = defaultDataWidths.reduce((value, element) => value + element);

          final double totalMinWidthIncludingCheckbox = minDataWidthSum + _checkboxColumnWidth;

          List<double> adjustedDataWidths = List.from(defaultDataWidths);
          double actualTableWidth;

          if (constraints.maxWidth >= totalMinWidthIncludingCheckbox) {
            final double excessSpace = constraints.maxWidth - totalMinWidthIncludingCheckbox;
            if (adjustedDataWidths.isNotEmpty) {
              adjustedDataWidths[adjustedDataWidths.length - 1] += excessSpace;
            }
            actualTableWidth = constraints.maxWidth;
          } else {
            actualTableWidth = totalMinWidthIncludingCheckbox;
          }

          final Color outlineColor = controller.highContrast ? BessColors.element3 : BessColors.borderPrimary;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: actualTableWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  BessRow.BessTableRow(
                    height: 34,
                    data: controller.fields.map((field) => field.displayTitle).toList(),
                    widths: adjustedDataWidths,
                    color: BessColors.crust,
                    maxLines: 1,
                    textOverflow: TextOverflow.clip,
                    isSelected: controller.selectedItems.length == controller.filteredRoster.length
                        ? true
                        : (controller.selectedItems.isNotEmpty ? null : false),
                    onToggle: controller.toggleSelectAll,
                    textStyle: BessTextStyles.columnHeader,
                    showHorizontalSeparator: true,
                    showVerticalSeparators: controller.columnSeparators,
                    separatorsColor: outlineColor,
                    toggleableRow: false,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.filteredRoster.length,
                      itemBuilder: (context, rowIndex) {
                        final rosterItem = controller.filteredRoster[rowIndex];
                        final Color backgroundColor;
                        if (controller.highContrast && controller.alternateRowColors) {
                          backgroundColor = BessColors.crust;
                        } else if (controller.highContrast && !controller.alternateRowColors) {
                          backgroundColor = BessColors.core;
                        } else if (!controller.highContrast && controller.alternateRowColors) {
                          backgroundColor = BessColors.background;
                        } else {
                          backgroundColor = BessColors.background;
                        }
                        final Color baseColor = controller.alternateRowColors
                            ? rowIndex % 2 == 0
                                ? BessColors.core
                                : backgroundColor
                            : backgroundColor;
                        final Color rowColor = controller.selectedItems.contains(rosterItem)
                            ? BessHelperFunctions.blendColors(baseColor, BessColors.primary, 30)
                            : baseColor;
                        return BessRow.BessTableRow(
                          height: controller.compact ? 40 : 80,
                          data: controller.getRowDataFromItem(rosterItem),
                          widths: adjustedDataWidths,
                          color: rowColor,
                          maxLines: controller.compact ? 1 : 3,
                          textOverflow: TextOverflow.ellipsis,
                          isSelected: controller.selectedItems.contains(rosterItem),
                          onToggle: () => controller.toggleRowSelection(rosterItem),
                          textStyle: BessTextStyles.standard,
                          showHorizontalSeparator: controller.rowSeparators,
                          showVerticalSeparators: controller.columnSeparators,
                          separatorsColor: outlineColor,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
