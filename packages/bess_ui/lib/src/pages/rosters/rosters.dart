import 'package:bess_ui/src/common/theme/widget_themes/checkbox_theme.dart';
import 'package:bess_ui/src/common/utils/helpers/helper_functions.dart';
import 'package:bess_ui/src/pages/rosters/widgets/table_header.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/constants/colors.dart';
import '../../common/constants/sizes.dart';
import '../../common/styles/text_styles.dart';
import '../../common/widgets/containers/rounded_container.dart';
import '../../common/widgets/layouts/templates/site_layout.dart';
import '../../common/widgets/state/controller_dependant_wrapper.dart';
import 'controllers/rosters_controller.dart';

/// A stateless widget that represents the main Rosters page.
/// It uses a [BessSiteTemplate] to provide a consistent layout
/// and displays the [RostersDesktop] widget for desktop view.
class Rosters extends StatelessWidget {
  const Rosters({
    super.key,
    required this.pageControllerTag,
  });

  /// A unique tag for the GetX controller to distinguish it from other instances.
  final String pageControllerTag;

  @override
  Widget build(BuildContext context) {
    return BessSiteTemplate(desktop: RostersDesktop(pageControllerTag: pageControllerTag));
  }
}

/// A stateless widget that represents the desktop view of the Rosters page.
/// It displays a paginated data table with roster information.
class RostersDesktop extends StatelessWidget {
  RostersDesktop({
    super.key,
    required this.pageControllerTag,
  });

  /// A unique tag for the GetX controller.
  final String pageControllerTag;

  /// The default title for the roster table.
  static const String defaultTitle = 'Campers';

  /// The default fields to be displayed in the roster table.
  final List<RosterField> defaultRosterFields = [
    RosterField.fullName,
    RosterField.preferredName,
    RosterField.gender,
    RosterField.age,
    RosterField.cabinName
  ];

  @override
  Widget build(BuildContext context) {
    // Initialize the RostersController using GetX dependency injection.
    // The controller is responsible for managing the state and business logic of the roster.
    final RostersController controller = Get.put(
      RostersController(
        defaultTitle: defaultTitle,
        defaultFields: defaultRosterFields,
      ),
      tag: pageControllerTag,
    );

    // This custom wrapper widget rebuilds its child widget whenever the controller notifies its listeners.
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TableHeader(
                pageControllerTag: pageControllerTag,
                title: controller.rosterTitle,
                count: controller.count,
                onDelete: controller.deleteSelected,
                onImport: controller.importCsv,
                selectedRowIds: controller.selectedRowIds,
                onSearchChange: controller.setSearchQuery,
                noMatches: controller.noMatches(),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (controller.fields.isEmpty) {
                    return const Center(child: Text('Add some columns!'));
                  } else if (controller.filteredRoster.isEmpty &&
                      controller.searchQuery.isNotEmpty) {
                    return Center(
                        child: Text(
                            'No campers found for "${controller.searchQuery}".'));
                    } else {
                      return DataTable2(
                        datarowCheckboxTheme: BessieCheckboxTheme.checkboxTheme.copyWith(splashRadius: 0),
                        headingCheckboxTheme: BessieCheckboxTheme.checkboxTheme.copyWith(splashRadius: 0),
                        headingRowColor: WidgetStateProperty.all<Color?>(BessColors.background),
                        headingRowHeight: 42,
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
                      rows: List<DataRow>.generate(
                          controller.filteredRoster.length, (index) {
                        final rosterItem = controller.filteredRoster[index];
                          final isSelected = controller.selectedRowIds.contains(rosterItem.id);
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
                              controller.toggleRowSelection(rosterItem.id, selected);
                            },
                            cells: controller
                                .getRowDataFromItem(rosterItem)
                                .map((cellData) => DataCell(
                              Text(
                                cellData,
                                style: BessTextStyles.standard,
                                maxLines: controller.compact ? 1 : 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                                .toList(),
                          );
                        }).toList(),
                      );
                    }
                  }
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
