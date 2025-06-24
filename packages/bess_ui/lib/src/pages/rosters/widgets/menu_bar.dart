import 'package:bess_ui/src/common/constants/sizes.dart';
import 'package:bess_ui/src/pages/rosters/widgets/column_config_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../common/constants/colors.dart';
import '../../../common/styles/text_styles.dart';
import '../controllers/rosters_controller.dart';

class TableMenuBar extends StatelessWidget {
  final String pageControllerTag;

  const TableMenuBar({
    super.key,
    required this.pageControllerTag,
  });

  @override
  Widget build(BuildContext context) {
    final RostersController controller = Get.find<RostersController>(
      tag: pageControllerTag,
    );

    final circle = SizedBox.square(
      dimension: 16,
      child: Center(
        child: SizedBox.square(
          dimension: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: ShadTheme.of(context).colorScheme.foreground,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );

    final divider = ShadSeparator.horizontal(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: BessColors.borderPrimary,
    );
    return ShadMenubar(
      selectOnHover: false,
      radius: BorderRadius.all(Radius.circular(BessSizes.cardRadiusMd)),
      padding: EdgeInsets.only(left: 4, right: 6),
      items: [
        ShadMenubarItem(
          // File
          child: const Text('File'),
          items: [
            ShadContextMenuItem(
              child: Text('Import From Ultracamp'),
              onPressed: controller.showImporterPopup,
            ),
            divider,
            const ShadContextMenuItem(child: Text('Export')),
            const ShadContextMenuItem(child: Text('Print')),
          ],
        ),
        ShadMenubarItem(
          // Edit
          child: const Text('Edit'),
          items: [
            ShadContextMenuItem(
              child: Text('Delete',
                  style: controller.isSingleSelected() || controller.isMultiSelected()
                      ? BessTextStyles.standard.copyWith(color: BessColors.red)
                      : BessTextStyles.standardSecondary
              ),
              onPressed: controller.deleteSelected,
              enabled: controller.isSingleSelected() || controller.isMultiSelected(),
            ),
            divider,
            ShadContextMenuItem(child: const Text('Invert Selection'), onPressed: controller.invertSelection, enabled: controller.selectedRowIds.isNotEmpty),
          ],
        ),
        ShadMenubarItem(
          // View
          child: const Text('View'),
          items: [
            ShadContextMenuItem(
              leading: Icon(LucideIcons.check, color: Colors.transparent),
              child: const Text('Paginated'),
            ),
            ShadContextMenuItem(
              child: const Text('Alternate Row Colors'),
              onPressed: controller.toggleAlternateRowColors,
              leading: controller.alternateRowColors ? Icon(LucideIcons.check, color: BessColors.textPrimary,) : Icon(LucideIcons.check, color: Colors.transparent,),
            ),
            ShadContextMenuItem(
              child: const Text('High Contrast'),
              onPressed: controller.toggleHighContrast,
              leading: controller.highContrast ? Icon(LucideIcons.check, color: BessColors.textPrimary,) : Icon(LucideIcons.check, color: Colors.transparent),
              enabled: controller.alternateRowColors,
            ),
            ShadContextMenuItem(
              child: const Text('Row Dividers'),
              onPressed: controller.toggleRowDividers,
              leading: controller.rowDividers ? Icon(LucideIcons.check, color: BessColors.textPrimary,) : Icon(LucideIcons.check, color: Colors.transparent,),
            ),
            ShadContextMenuItem(
              child: const Text('Compact'),
              onPressed: controller.toggleCompact,
              leading: controller.compact ? Icon(LucideIcons.check, color: BessColors.textPrimary,) : Icon(LucideIcons.check, color: Colors.transparent,),
            ),
          ],
        ),

        ColumnConfigButton(controller: controller,),
      ],
    );
  }
}

