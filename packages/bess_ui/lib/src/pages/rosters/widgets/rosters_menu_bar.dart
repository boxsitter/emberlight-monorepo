import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../common/constants/colors.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/header/menu_bar.dart';
import '../controllers/rosters_controller.dart';

/// A builder function that constructs and returns a configured [BessMenuBar] for the Rosters page.
BessMenuBar<RostersController> buildRostersMenuBar({
  required RostersController controller,
}) {
  return BessMenuBar<RostersController>(
    externalPageController: controller,
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
        enabled: controller.alternateRowColors,
      ),
      ShadContextMenuItem(
        child: const Text('Row Dividers'),
        onPressed: controller.toggleRowDividers,
        leading: controller.rowDividers
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
        child: Text('Delete',
            style: controller.isSingleSelected() || controller.isMultiSelected()
                ? BessTextStyles.standard.copyWith(color: BessColors.red)
                : BessTextStyles.standardSecondary),
        onPressed: controller.deleteSelected,
        enabled: controller.isSingleSelected() || controller.isMultiSelected(),
      ),
      ShadSeparator.horizontal(
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: BessColors.borderPrimary,
      ),
      ShadContextMenuItem(
          child: const Text('Invert Selection'),
          onPressed: controller.invertSelection,
          enabled: controller.selectedRowIds.isNotEmpty),
    ],
  );
}
