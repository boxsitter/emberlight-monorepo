import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:bess_ui/src/common/widgets/misc/contained_tile_list.dart';
import 'package:bess_ui/src/common/widgets/misc/horizontal_card_selector.dart';
import 'package:bess_ui/src/common/widgets/switches/icon_switch.dart';
import 'package:bess_ui/src/pages/rosters/controllers/rosters_controller.dart';
import 'package:ember_core/ember_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../common/constants/colors.dart';
import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/misc/list_reorderer.dart';

/// A button that, when pressed, reveals a popover with a form
/// for selecting visible columns.
class ColumnConfigButton extends StatefulWidget {
  const ColumnConfigButton({super.key, required this.controller});

  final RostersController controller;

  @override
  State<ColumnConfigButton> createState() => _ColumnConfigButtonState(controller: controller);
}

class _ColumnConfigButtonState extends State<ColumnConfigButton> {
  final popoverController = ShadPopoverController();
  final RostersController controller;

  _ColumnConfigButtonState({required this.controller});

  @override
  void dispose() {
    popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadPopover(
      controller: popoverController,
      // The popover contains the stateless form widget.
      popover: (context) => _ColumnForm(
        controller: controller,
        shadController: popoverController,
      ),
      // This is the button that triggers the popover.
      child: ShadIconButton.secondary(
        height: 30,
        width: 30,
        padding: EdgeInsets.zero,
        icon: const Icon(
          LucideIcons.columns3Cog500,
          size: 18,
        ),
        onPressed: popoverController.toggle,
        backgroundColor: BessColors.core,
      ),
    );
  }
}

class _ColumnForm extends StatelessWidget {
  const _ColumnForm({
    super.key,
    required this.controller,
    required this.shadController,
  });

  final RostersController controller;
  final ShadPopoverController shadController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BessSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VerticalListReorderer(
                width: 350,
                height: 400,
                title: 'Visible Columns',
                items: controller.fields,
                onReorder: controller.setColumnOrder,
                trailingBuilder: (Titled item) {
                  // You can safely assume the item is the RosterField for this row
                  final field = item as RosterField;
                  return IconButton(
                    icon: const Icon(LucideIcons.circleChevronRight, size: 20),
                    // The onPressed callback now knows which 'field' to remove
                    onPressed: () => controller.removeVisibleColumn(field),
                    splashRadius: 20,
                  );
                },
              ),
              SizedBox(width: BessSizes.spaceBtwItems),
              ContainedTileList(
                width: 350,
                height: 400,
                title: 'Hidden Columns',
                items: controller.displayAmas
                    ? controller.amas
                        .where((ama) => !controller.fields.map((field) => field.dataId).toSet().contains(ama.id))
                        .toList()
                    : RosterField.values.where((field) => !controller.fields.contains(field)).toList(),
                leadingBuilder: (Titled item) {
                  RosterField field;
                  if (controller.displayAmas) {
                    final ama = item as AMABlock;
                    field = RosterField(
                        name: 'activityPeriod', title: ama.displayTitle, required: false, defaultWidth: 210, dataId: ama.id);
                  } else {
                    field = item as RosterField;
                  }
                  return IconButton(
                    icon: const Icon(LucideIcons.circleChevronLeft, size: 20),
                    // The onPressed callback now knows which 'field' to remove
                    onPressed: () => controller.addVisibleColumn(field),
                    splashRadius: 20,
                  );
                },
                headerTrailingWidget: BessIconSwitch(
                  iconOne: LucideIcons.circleUserRound,
                  iconTwo: LucideIcons.volleyball,
                  colorOne: BessColors.primary,
                  colorTwo: BessColors.secondary,
                  value: controller.displayAmas,
                  onToggle: () => controller.toggleDisplayAmas(),
                ),
              ),
            ],
          ),
          const SizedBox(height: BessSizes.spaceBtwSections),
          Text('Presets', style: BessTextStyles.tableHeaderSecondary),
          const SizedBox(height: BessSizes.sm),
        ],
      ),
    );
  }
}
