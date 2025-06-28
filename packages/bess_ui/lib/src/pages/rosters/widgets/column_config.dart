import 'package:ember_core/ember_core.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../common/constants/colors.dart';
import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/containers/titled_container.dart';
import '../../../common/widgets/misc/card_list.dart';
import '../../../common/widgets/misc/list_reorderer.dart';
import '../../../common/widgets/switches/icon_switch.dart';
import '../controllers/rosters_controller.dart';

class ColumnConfig extends StatelessWidget {
  const ColumnConfig({
    super.key,
    required this.controller,
  });

  final RostersController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BessSizes.md),
      decoration: BoxDecoration(border: BorderDirectional(bottom: BorderSide(color: BessColors.borderPrimary, width: 2))),
      height: 500,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitledContainer(
            width: 350,
            height: double.infinity,
            title: 'Visible Columns',
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: VerticalListReorderer(
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
          ),

          SizedBox(width: BessSizes.spaceBtwItems),

          TitledContainer(
            width: 350,
            title: 'Hidden Columns',
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            trailing:  BessIconSwitch(
              iconOne: LucideIcons.circleUserRound,
              iconTwo: LucideIcons.volleyball,
              colorOne: BessColors.primary,
              colorTwo: BessColors.secondary,
              value: controller.displayAmas,
              onToggle: () => controller.toggleDisplayAmas(),
            ),
            child: CardList(
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
            ),
          ),
          const SizedBox(width: BessSizes.spaceBtwSections),
          Text('Presets', style: BessTextStyles.tableHeaderSecondary),
          const SizedBox(width: BessSizes.sm),
        ],
      ),
    );
  }
}