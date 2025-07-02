import 'package:bess_ui/src/common/widgets/misc/card_grid_selector.dart';
import 'package:ember_core/ember_core.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../common/constants/colors.dart';
import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/buttons/card_button.dart';
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: 4,
            child: TitledContainer(
              title: 'Visible Columns',
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: VerticalListReorderer(
                items: controller.fields,
                onReorder: controller.setColumnOrder,
                trailingBuilder: (Titled item) {
                  // You can safely assume the item is the RosterField for this row
                  final field = item as RosterField;
                  return Row(
                    mainAxisSize: MainAxisSize.min, // This is the fix!
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.group, size: 20),
                        // The onPressed callback now knows which 'field' to remove
                        onPressed: () => controller.setGroupBy(field),
                        splashRadius: 20,
                        iconSize: 20,
                      ),
                      IconButton(
                        icon: Icon(
                          controller.sortDirection == SortDirection.asc ? LucideIcons.arrowUpAZ : LucideIcons.arrowDownZA,
                          size: 20,
                        ),
                        // The onPressed callback now knows which 'field' to remove
                        onPressed: () => controller.setSortBy(field),
                        splashRadius: 20,
                        iconSize: 20,
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.circleChevronRight, size: 20),
                        // The onPressed callback now knows which 'field' to remove
                        onPressed: () => controller.removeVisibleColumn(field),
                        splashRadius: 20,
                        iconSize: 20,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(width: BessSizes.spaceBtwItems),
          Flexible(
            flex: 2,
            child: TitledContainer(
              title: 'Hidden Columns',
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              trailing: BessIconSwitch(
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
          ),
          const SizedBox(width: BessSizes.spaceBtwSections),
          Flexible(
            flex: 4,
            child: TitledContainer(
              title: 'Presets',
              child: CardGridSelector<String>(
                columns: 3,
                childAspectRatio: 4,
                items: [
                  'Example Preset 1',
                  'Example Preset 2',
                  'Example Preset 3',
                  'Example Preset 4',
                  'Example Preset 5',
                  'Example Preset 6',
                  'Example Preset 7',
                  'Example Preset 8',
                  'Example Preset 9',
                ],
                itemBuilder: (context, item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4),
                    child: CardButton(
                      child: Center(
                          child: Text(
                        item,
                        style: BessTextStyles.standard,
                      )),
                      onTap: () => {},
                      height: 50,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
