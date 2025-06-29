import 'package:bess_ui/src/common/theme/widget_themes/checkbox_theme.dart';
import 'package:bess_ui/src/common/utils/helpers/helper_functions.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../common/constants/colors.dart';
import '../../../common/styles/text_styles.dart';
import '../controllers/rosters_controller.dart';

class RostersTable extends StatelessWidget {
  const RostersTable({
    super.key,
    required this.controller,
  });

  // TODO: Awful
  final Set<String> makeRed = const {
    'Unassigned',
    'Error (not found)',
    'Error (no principal activity)',
    'No',
  };

  final RostersController controller;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (controller.fields.isEmpty) {
        return const Center(child: Text('Add some columns!'));
      } else if (controller.filteredRoster.isEmpty && controller.searchQuery.isNotEmpty) {
        return Center(child: Text('No campers found for "${controller.searchQuery}".'));
      } else {
        return DataTable2(
          datarowCheckboxTheme: BessieCheckboxTheme.checkboxTheme.copyWith(splashRadius: 0),
          headingCheckboxTheme: BessieCheckboxTheme.checkboxTheme.copyWith(splashRadius: 0),
          headingRowColor: WidgetStateProperty.all<Color?>(BessColors.crust),
          //headingRowDecoration: BoxDecoration(border: Border(bottom: BorderSide(width: 2, color: BessColors.borderPrimary))),
          headingRowHeight: 40,
          columnSpacing: 16,
          horizontalMargin: 24,
          dataRowHeight: controller.compact ? 40 : 80,
          dividerThickness: controller.rowDividers ? 1 : 0,
          onSelectAll: (selected) {
            controller.toggleSelectAll(selected);
          },
          minWidth: controller.minWidth + 10,
          // Assign the custom sizes map to the table.
          columns: controller.fields.map((field) {
            if (controller.fields.last == field) {
              // LAST COLUMN: Use 'size' to make it expand.
              return DataColumn2(
                label: Text(
                  field.title,
                  style: BessTextStyles.columnHeader,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
                size: ColumnSize.L,
              );
            } else {
              // OTHER COLUMNS: Use 'fixedWidth' to prevent them from expanding.
              // You may need to adjust this value based on your content.
              return DataColumn2(
                label: Text(
                  field.title,
                  style: BessTextStyles.columnHeader,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
                fixedWidth: field.defaultWidth,
              );
            }
          }).toList(),
          rows: List<DataRow>.generate(controller.filteredRoster.length, (index) {
            final rosterItem = controller.filteredRoster[index];
            final isSelected = controller.selectedItems.contains(rosterItem);
            return DataRow(
              selected: isSelected,
              // Set the color property using MaterialStateProperty.
              color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                // Color for selected rows.
                if (states.contains(WidgetState.selected)) {
                  if (index.isOdd && controller.alternateRowColors) {
                    return controller.highContrast
                        ? BessHelperFunctions.blendColors(BessColors.crust, BessColors.primary, 40)
                        : BessHelperFunctions.blendColors(BessColors.background, BessColors.primary, 30);
                  } else {
                    return BessHelperFunctions.blendColors(BessColors.core, BessColors.primary, 30);
                  }
                }
                // Alternate colors for even and odd rows.
                if (index.isOdd && controller.alternateRowColors) {
                  return controller.highContrast ? BessColors.crust : BessColors.background;
                }
                // Return null for odd rows to use the default transparent color.
                return null;
              }),
              onSelectChanged: (selected) {
                controller.toggleRowSelection(rosterItem, selected);
              },
              cells: controller
                  .getRowDataFromItem(rosterItem)
                  .map((cellData) => DataCell(
                        Text(
                          cellData,
                          style: BessTextStyles.standard.copyWith(color: makeRed.contains(cellData) ? BessColors.red : BessColors.textPrimary),
                          maxLines: controller.compact ? 1 : 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                  .toList(),
            );
          }).toList(),
        );
      }
    });
  }
}
