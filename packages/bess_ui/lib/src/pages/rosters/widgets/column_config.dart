import 'package:bess_ui/src/common/widgets/misc/card_grid_selector.dart';
import 'package:ember_core/ember_core.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../common/constants/colors.dart';
import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/buttons/card_button.dart';
import '../../../common/widgets/buttons/icon_button.dart';
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
          Expanded(
            child: TitledContainer(
              title: 'Visible Columns',
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: VerticalListReorderer<RosterField>(
                items: controller.fields,
                onReorder: controller.setColumnOrder,
                titleBuilder: (RosterField item) => Text(item.displayTitle, style: BessTextStyles.standard),
                trailingBuilder: (RosterField item) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.allowGrouping)
                        BessIconButton(
                          iconData: LucideIcons.group,
                          onPressed: () => controller.setGroupBy(item),
                          selected: controller.groupByField == item,
                        ),
                      BessIconButton(
                        iconData: controller.sortDirection == SortDirection.asc ? LucideIcons.arrowUpAZ : LucideIcons.arrowDownZA,
                        onPressed: () => controller.setSortBy(item),
                        selected: controller.sortByField == item,
                      ),
                      BessIconButton(
                        iconData: LucideIcons.circleChevronRight,
                        onPressed: () => controller.removeVisibleColumn(item),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(width: BessSizes.spaceBtwItems),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: TitledContainer(
                    title: 'Hidden Columns',
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: CardList(
                      items: controller.availableFields(false),
                      leadingBuilder: (Titled item) {
                        final field = item as RosterField;
                        return IconButton(
                          icon: const Icon(LucideIcons.circleChevronLeft, size: 20),
                          onPressed: () => controller.addVisibleColumn(field),
                          splashRadius: 20,
                        );
                      },
                      trailingBuilder: (Titled item) {
                        final field = item as RosterField;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (field.allowGrouping)
                              BessIconButton(
                                iconData: LucideIcons.group,
                                onPressed: () => controller.setGroupBy(field),
                                selected: controller.groupByField == field,
                              ),
                            BessIconButton(
                              iconData: controller.sortDirection == SortDirection.asc ? LucideIcons.arrowUpAZ : LucideIcons.arrowDownZA,
                              onPressed: () => controller.setSortBy(field),
                              selected: controller.sortByField == field,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                Expanded(
                  child: TitledContainer(
                    title: 'Hidden Activity Periods',
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: CardList(
                      items: controller.availableFields(true),
                      leadingBuilder: (Titled item) {
                        final field = item as RosterField;
                        return IconButton(
                          icon: const Icon(LucideIcons.circleChevronLeft, size: 20),
                          onPressed: () => controller.addVisibleColumn(field),
                          splashRadius: 20,
                        );
                      },
                      trailingBuilder: (Titled item) {
                        final field = item as RosterField;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (field.allowGrouping)
                              BessIconButton(
                                iconData: LucideIcons.group,
                                onPressed: () => controller.setGroupBy(field),
                                selected: controller.groupByField == field,
                              ),
                            BessIconButton(
                              iconData: controller.sortDirection == SortDirection.asc ? LucideIcons.arrowUpAZ : LucideIcons.arrowDownZA,
                              onPressed: () => controller.setSortBy(field),
                              selected: controller.sortByField == field,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
