import 'package:bess_ui/src/common/widgets/buttons/checkbox.dart';
import 'package:bess_ui/src/pages/rosters/widgets/searchbar.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../common/constants/colors.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/header/menu_bar.dart';
import '../controllers/roster_group.dart';
import '../controllers/rosters_controller.dart';

List<Widget> buildRostersCenterActions({
  required RostersController controller,
}) {
  return [
    ShadIconButton.secondary(
      height: 30,
      width: 30,
      padding: EdgeInsets.zero,
      icon: const Icon(
        LucideIcons.columns3Cog500,
        size: 18,
      ),
      onPressed: () => controller.toggleSecondaryPage(1),
      backgroundColor: controller.columnConfigOpened ? BessColors.primary : BessColors.core,
      foregroundColor: controller.columnConfigOpened ? BessColors.textInverted : BessColors.textPrimary,
      hoverBackgroundColor: controller.columnConfigOpened ? BessColors.primary : BessColors.crust,
    ),
    ShadIconButton.secondary(
      height: 30,
      width: 30,
      padding: EdgeInsets.zero,
      icon: const Icon(
        LucideIcons.arrowRightLeft500,
        size: 18,
      ),
      onPressed: () => controller.toggleSecondaryPage(2),
      backgroundColor: controller.activitySwitcherOpened ? BessColors.primary : BessColors.core,
      foregroundColor: controller.activitySwitcherOpened ? BessColors.textInverted : BessColors.textPrimary,
      hoverBackgroundColor: controller.activitySwitcherOpened ? BessColors.primary : BessColors.crust,
    ),
    SizedBox(width: 10,),
    BessCheckbox(
      tristate: true,
      value: controller.selectedItems.containsAll(controller.roster) ? true : controller.selectedItems.isEmpty ? false : null,
      onPressed: controller.toggleSelectAll,
    ),
  ];
}

BessMenuBar<RostersController> buildRostersMenuBar({
  required RostersController controller,
}) {
  return BessMenuBar<RostersController>(
    externalPageController: controller,
    fileItems: [
      ShadContextMenuItem(child: const Text('Import From Ultracamp'), onPressed: controller.importCsv),
      ShadSeparator.horizontal(
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: BessColors.borderPrimary,
      ),
      const ShadContextMenuItem(child: Text('Export')),
      const ShadContextMenuItem(child: Text('Print')),
    ],
    viewItems: [
      const ShadContextMenuItem(
        leading: Icon(LucideIcons.check, color: Colors.transparent),
        child: Text('Paginated'),
      ),
      ShadContextMenuItem(
        child: const Text('Alternate Row Colors'),
        onPressed: controller.toggleAlternateRowColors,
        leading: controller.alternateRowColors
            ? Icon(
                LucideIcons.check,
                color: BessColors.textPrimary,
              )
            : const Icon(
                LucideIcons.check,
                color: Colors.transparent,
              ),
      ),
      ShadContextMenuItem(
        child: const Text('High Contrast'),
        onPressed: controller.toggleHighContrast,
        leading: controller.highContrast
            ? Icon(
                LucideIcons.check,
                color: BessColors.textPrimary,
              )
            : const Icon(LucideIcons.check, color: Colors.transparent),
      ),
      ShadContextMenuItem(
        child: const Text('Row Dividers'),
        onPressed: controller.toggleRowSeparators,
        leading: controller.rowSeparators
            ? Icon(
                LucideIcons.check,
                color: BessColors.textPrimary,
              )
            : const Icon(
                LucideIcons.check,
                color: Colors.transparent,
              ),
      ),
      ShadContextMenuItem(
        child: const Text('Column Dividers'),
        onPressed: controller.toggleColumnSeparators,
        leading: controller.columnSeparators
            ? Icon(
                LucideIcons.check,
                color: BessColors.textPrimary,
              )
            : const Icon(
                LucideIcons.check,
                color: Colors.transparent,
              ),
      ),
      ShadContextMenuItem(
        child: const Text('Compact'),
        onPressed: controller.toggleCompact,
        leading: controller.compact
            ? Icon(
                LucideIcons.check,
                color: BessColors.textPrimary,
              )
            : const Icon(
                LucideIcons.check,
                color: Colors.transparent,
              ),
      ),
    ],
    editItems: [
      ShadContextMenuItem(
        child: const Text('Invert Selection'),
        onPressed: controller.invertSelection,
        enabled: controller.selectedItems.isNotEmpty,
      ),
      ShadSeparator.horizontal(
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: BessColors.borderPrimary,
      ),
      ShadContextMenuItem(
        child: const Text('Rank Random'),
        onPressed: controller.rankRandomSelected,
        enabled: controller.selectedItems.isNotEmpty,
      ),
      ShadContextMenuItem(
        child: const Text('Clear Preferences'),
        onPressed: controller.clearPrefsSelected,
        enabled: controller.selectedItems.isNotEmpty,
      ),
      ShadSeparator.horizontal(
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: BessColors.borderPrimary,
      ),
      ShadContextMenuItem(
        child: const Text('Assign To Activity'),
        onPressed: controller.assignSelected,
        enabled: controller.selectedItems.isNotEmpty && controller.selectedAma != null && controller.selectedActivity != null,
      ),
      ShadContextMenuItem(
        child: const Text('Smart Assign All'),
        onPressed: controller.smartAssignAll,
      ),
      ShadContextMenuItem(
        child: const Text('Auto Assign'),
        onPressed: controller.autoAssignSelected,
        enabled: controller.selectedItems.isNotEmpty,
      ),
      ShadContextMenuItem(
        child: const Text('Unassign From Selected Activity'),
        onPressed: controller.unassignSelectedFromActivity,
        enabled: controller.selectedItems.isNotEmpty && controller.selectedAma != null && controller.selectedActivity != null,
      ),
      ShadContextMenuItem(
        child: const Text('Unassign For Selected Period'),
        onPressed: controller.unassignSelectedFromAma,
        enabled: controller.selectedItems.isNotEmpty && controller.selectedAma != null,
      ),
      ShadContextMenuItem(
        child: Text('Unassign From All Periods',
            style: controller.isSingleSelected() || controller.isMultiSelected()
                ? BessTextStyles.standard.copyWith(color: BessColors.red)
                : BessTextStyles.standardSecondary),
        onPressed: controller.unassignSelectedFromAll,
        enabled: controller.selectedItems.isNotEmpty,
      ),
      ShadSeparator.horizontal(
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: BessColors.borderPrimary,
      ),
      ShadContextMenuItem(
        child: Text('Delete',
            style: controller.isSingleSelected() || controller.isMultiSelected()
                ? BessTextStyles.standard.copyWith(color: BessColors.red)
                : BessTextStyles.standardSecondary),
        onPressed: controller.deleteSelected,
        enabled: controller.isSingleSelected() || controller.isMultiSelected(),
      ),
    ],
  );
}

List<Widget> buildRostersTrailingWidgets({
  required RostersController controller,
}) {
  return [
    BessSearchbar(
      onSearchChange: controller.setSearchQuery,
      noMatches: controller.filteredRoster.isEmpty,
      controller: controller.searchController,
    ),
  ];
}
