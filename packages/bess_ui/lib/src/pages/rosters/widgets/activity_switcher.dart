import 'package:bess_ui/src/common/styles/text_styles.dart';
import 'package:bess_ui/src/common/widgets/buttons/action_initiator.dart';
import 'package:bess_ui/src/common/widgets/buttons/card_button.dart';
import 'package:bess_ui/src/common/widgets/containers/titled_container.dart';
import 'package:bess_ui/src/common/widgets/misc/card_grid_selector.dart';
import 'package:bess_ui/src/common/widgets/misc/card_selector.dart';
import 'package:ember_core/ember_core.dart';
import 'package:flutter/material.dart';

import '../../../common/constants/colors.dart';
import '../../../common/constants/sizes.dart';
import '../../../common/widgets/misc/card_list.dart';
import '../controllers/rosters_controller.dart';

class ActivitySwitcher extends StatelessWidget {
  const ActivitySwitcher({
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
        children: [
          Flexible(
            flex: 2,
            child: TitledContainer(
              title: 'Select Activity Period',
              child: CardSelector(
                items: controller.amas,
                onSelectItem: controller.setSelectedAma,
                selectedItem: controller.selectedAma,
                maxLines: 1,
                isHorizontal: false,
              ),
            ),
          ),
          SizedBox(width: BessSizes.spaceBtwItems),
          Flexible(
            flex: 6,
            child: TitledContainer(
              title: 'Select Activity',
              child: controller.selectedAma != null
                  ? CardGridSelector<ActivityDependent>(
                      items: controller.activityDependents.where((d) => d.blockRef == controller.selectedAma!.id).toList(),
                      childAspectRatio: 6.0,
                      columns: 2,
                      itemBuilder: (context, item) {
                        PrincipalActivity? principalActivity = controller.principalActivities[item.principalPar];
                        int countAdded = controller.selectedItems.length - (controller.selectedItems.where((camper) => item.camperRefs.contains(camper.id))).length;
                        bool? atCap = principalActivity != null
                            ? item.camperRefs.length + countAdded > principalActivity.capacity
                            : null;
                        return CardButton(
                          tintStates: atCap != null
                              ? [
                                  (controller.selectedActivity == item, BessColors.primary),
                                  (atCap, BessColors.red),
                                  (!atCap, BessColors.green)
                                ]
                              : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(principalActivity?.name ?? 'Error', style: BessTextStyles.boldCardTitle),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (controller.selectedItems.isNotEmpty && atCap != null && !atCap)
                                    Text(
                                      '$countAdded+',
                                      overflow: TextOverflow.clip,
                                      style: BessTextStyles.standard.copyWith(color: BessColors.green),
                                    ),
                                  if (controller.selectedItems.isNotEmpty && atCap != null && atCap)
                                    Text(
                                      '$countAdded+',
                                      overflow: TextOverflow.clip,
                                      style: BessTextStyles.standard.copyWith(color: BessColors.red),
                                    ),
                                  Text(
                                    '${item.camperRefs.length}/${principalActivity?.capacity}',
                                    overflow: TextOverflow.clip,
                                    style: BessTextStyles.standardBold,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          onTap: () => controller.setSelectedActivity(item),
                          height: 50,
                        );
                      },
                    )
                  : Center(child: Text('Select an activity period first!', style: BessTextStyles.tableHeaderSecondary)),
            ),
          ),
          SizedBox(width: BessSizes.spaceBtwItems),
          Flexible(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: TitledContainer(
                    title: 'Summary',
                    child: controller.selectedItems.isNotEmpty
                        ? CardList<Rosterable>(
                            items: controller.selectedItems.toList(),
                            trailingBuilder: (item) {
                              String? selectedAmaId = controller.selectedAma?.id;
                              String? selectedActivityTitle =
                                  controller.principalActivities[controller.selectedActivity?.principalPar]?.displayTitle;
                              if (selectedAmaId == null || selectedActivityTitle == null) {
                                return Text('No change', style: BessTextStyles.standardBold);
                              }
                              String? oldActivityId = item.activityAssignmentRefs[selectedAmaId];
                              String? oldActivityTitle;
                              if (oldActivityId != null) {
                                ActivityDependent? oldActivity;
                                for (ActivityDependent activityDep in controller.activityDependents) {
                                  if (activityDep.id == oldActivityId) {
                                    oldActivity = activityDep;
                                  }
                                }
                                oldActivityTitle = controller.principalActivities[oldActivity?.principalPar]?.displayTitle;
                              }
                              if (oldActivityId == null || oldActivityTitle == null) {
                                return Text('Assign to $selectedActivityTitle', style: BessTextStyles.standardBold);
                              }
                              if (oldActivityId == controller.selectedActivity!.id) {
                                return Text('No change', style: BessTextStyles.standardBold);
                              }

                              return Text('$oldActivityTitle ➔ $selectedActivityTitle', style: BessTextStyles.standardBold);
                            },
                          )
                        : Center(child: Text('Select some campers first!', style: BessTextStyles.tableHeaderSecondary)),
                  ),
                ),
                SizedBox(
                  height: BessSizes.spaceBtwItems,
                ),
                ActionInitiator(
                  onPressed: () => controller.assignSelected(),
                  disabled:
                      controller.selectedAma == null || controller.selectedActivity == null || controller.selectedItems.isEmpty,
                  awaiting: controller.assigningCamper,
                  enabledText: 'Commit',
                  disabledText: 'Nothing to commit yet',
                  awaitingText: 'One moment...',
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
