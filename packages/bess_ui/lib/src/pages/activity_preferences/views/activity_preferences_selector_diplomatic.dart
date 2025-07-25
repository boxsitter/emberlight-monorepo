import 'package:bess_ui/src/common/styles/text_styles.dart';
import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:bess_ui/src/common/widgets/containers/titled_container.dart';
import 'package:bess_ui/src/common/widgets/loaders/circular_loader.dart';
import 'package:bess_ui/src/common/widgets/misc/tab_switcher.dart';
import 'package:bess_ui/src/common/widgets/misc/widget_list.dart';
import 'package:bess_ui/src/pages/activity_preferences/widgets/draggable_container.dart';
import 'package:ember_core/ember_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../common/constants/colors.dart';
import '../../../common/constants/sizes.dart';
import '../../../common/widgets/misc/widget_grid.dart';
import '../controllers/activity_preferences_controller_diplomatic.dart';

class ActivityPreferencesSelectorDiplomatic extends StatelessWidget {
  ActivityPreferencesSelectorDiplomatic({super.key, required this.controller});

  final ActivityPreferencesControllerDiplomatic controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isActivityDataLoaded == false) return const BessCircularLoader();

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: DragTarget<PrincipalActivity>(
              onAcceptWithDetails: (data) => controller.addToNeutral(data.data),
              builder: (context, candidateData, rejectedData) {
                return TitledContainer(
                  title: 'Activity Library (I\'d Be Open To Trying It)',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: TabSwitcher<ActivityCategory>(
                            items: controller.categories,
                            selectedItem: controller.selectedCategory ?? controller.categories[0],
                            onItemSelected: (item) => controller.setSelectedCategory(item),
                          ),
                          width: double.infinity,
                        ),
                        SizedBox(
                          height: 32,
                        ),
                        WidgetGrid(
                          items: controller.getActivitiesInCategory(controller.selectedCategory ?? controller.categories[0]),
                          runSpacing: 4,
                          spacing: 2,
                          itemBuilder: (context, item) {
                            return BessDraggableContainer<PrincipalActivity>(
                              item: item,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              onDragStarted: () => controller.onDragStarted(item),
                              onDragEnd: (_) => controller.onDragEnd(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(
            width: 16,
          ),

          // Deny Area
          SizedBox(
            width: 300,
            child: Column(
              children: [
                Expanded(
                  child: DragTarget<PrincipalActivity>(
                    onAcceptWithDetails: (data) => controller.addToRequested(data.data),
                    builder: (context, candidateData, rejectedData) {
                      return TitledContainer(
                        title: 'Yes Please',
                        baseTint: BessColors.green,
                        padding: EdgeInsets.zero,
                        trailing: Text(
                          '${controller.maxRequestsStandard! - controller.requestedActivities.length > 0 ? controller.maxRequestsStandard! - controller.requestedActivities.length : 'no'} available requests',
                          style: BessTextStyles.standard.copyWith(color: BessColors.green),
                        ),
                        child: Builder(builder: (context) {
                          if (controller.requestedActivities.isEmpty) {
                            return Center(
                                child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.replace,
                                  color: BessColors.green,
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  'Drag And Drop Here',
                                  style: BessTextStyles.standard.copyWith(color: BessColors.green),
                                )
                              ],
                            ));
                          }
                          return WidgetList(
                            items: controller.requestedActivities,
                            itemBuilder: (context, item) {
                              return BessDraggableContainer<PrincipalActivity>(
                                item: item,
                                padding: const EdgeInsets.only(
                                  left: 32,
                                  right: 32,
                                  bottom: 0,
                                  top: 16,
                                ),
                                onDragStarted: () => controller.onDragStarted(item),
                                onDragEnd: (_) => controller.onDragEnd(),
                              );
                            },
                          );
                        }),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Expanded(
                  child: DragTarget<PrincipalActivity>(
                    onAcceptWithDetails: (data) => controller.addToVetoed(data.data),
                    builder: (context, candidateData, rejectedData) {
                      return TitledContainer(
                        title: 'No Thanks',
                        baseTint: BessColors.red,
                        padding: EdgeInsets.zero,
                        trailing: Text(
                          '${controller.maxVetoesStandard! - controller.vetoedActivities.length > 0 ? controller.maxVetoesStandard! - controller.vetoedActivities.length : 'no'} available vetoes',
                          style: BessTextStyles.standard.copyWith(color: BessColors.red),
                        ),
                        child: Builder(builder: (context) {
                          if (controller.vetoedActivities.isEmpty) {
                            return Center(
                                child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.replace,
                                  color: BessColors.red,
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  'Drag And Drop Here',
                                  style: BessTextStyles.standard.copyWith(color: BessColors.red),
                                )
                              ],
                            ));
                          }
                          return WidgetList(
                            items: controller.vetoedActivities,
                            itemBuilder: (context, item) {
                              return BessDraggableContainer<PrincipalActivity>(
                                item: item,
                                padding: const EdgeInsets.only(
                                  left: 32,
                                  right: 32,
                                  bottom: 0,
                                  top: 16,
                                ),
                                onDragStarted: () => controller.onDragStarted(item),
                                onDragEnd: (_) => controller.onDragEnd(),
                              );
                            },
                          );
                        }),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Accept Area
        ],
      ),
    );
  }
}
