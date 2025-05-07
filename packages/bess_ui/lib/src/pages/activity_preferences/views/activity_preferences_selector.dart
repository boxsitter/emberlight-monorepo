import 'package:bess_ui/src/common/widgets/buttons/action_initiator.dart';
import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:bess_ui/src/pages/activity_preferences/controllers/activity_preferences_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/layouts/templates/site_layout.dart';
import '../widgets/small_card_button.dart';

class ActivityPreferencesSelector extends StatelessWidget {
  const ActivityPreferencesSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return const BessSiteTemplate(desktop: ActivityPreferencesSelectorDesktop());
  }
}

class ActivityPreferencesSelectorDesktop extends StatelessWidget {
  const ActivityPreferencesSelectorDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<
        ActivityPreferencesController>();

    return GetBuilder<ActivityPreferencesController>(
      builder: (controller) {
        return Obx(() {
          if (!controller.isCamperDataLoaded.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ranking activities for ${controller.selectedCamperName}',
                style: BessTextStyles.lightTitle,
                overflow: TextOverflow.clip,
                maxLines: 1,
              ),

              const SizedBox(height: BessSizes.spaceBtwItems),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: controller.camperNames.keys.map((camperId) {
                    final name = controller.camperNames[camperId] ??
                        'Unknown';
                    final bool isSelected = controller.selectedCamperId == camperId;
                    final bool isCompleted = controller.camperIsCompleted.contains(camperId);

                    return Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: BessSizes.spaceBtwItems,
                          horizontal: BessSizes.spaceBtwItems / 2),
                      child: SmallCardButton(
                        title: name,
                        height: 35,
                        width: 120,
                        isSelected: isSelected,
                        isCompleted: isCompleted,
                        onTap: () => controller.selectCamper(camperId, name),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: BessSizes.spaceBtwItems),
              // Space before activity list

              // --- Section for Activity Ranking ---
              // This part updates based on the selected camper
              Expanded( // Use Expanded if this list should fill remaining space
                child: Obx(() { // Use Obx to react to activity loading state/data
                  if (!controller.isActivityDataLoaded.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Use orderedActivityIds for checking emptiness now
                  if (controller.orderedActivityIds.isEmpty) {
                    return const Center(child: Text(
                        'No activities scheduled for this session'));
                  }

                  // Example:
                  return Column( // Column to hold the list and the save button
                    children: [
                      Expanded( // Let the list take available space
                        child: SizedBox(
                          width: 400,
                          child: ReorderableListView.builder(
                            buildDefaultDragHandles: false,
                            shrinkWrap: true,


                            itemCount: controller.orderedActivityIds.length,

                            itemBuilder: (context, index) {
                              final activityId = controller
                                  .orderedActivityIds[index];
                              // Lookup name from the map
                              final activityName = controller
                                  .activityNames[activityId] ??
                                  'Unknown Activity';


                              // *** Each item MUST have a unique Key ***
                              return BessRoundedContainer(
                                  key: ValueKey(activityId),
                                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  width: 400,
                                  height: 40,
                                  borderThickness: 2,
                                  showBorder: true,
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text( // Display rank number
                                        '#${index + 1}    $activityName',
                                        style: BessTextStyles.standard,
                                      ),

                                    Spacer(),

                                    IconButton(
                                      onPressed: () => controller.showActivityInfo(activityId),
                                      icon: const Icon(LucideIcons.info),
                                    ),

                                      ReorderableDragStartListener(
                                        index: index,
                                        // Required for the listener
                                        child: Icon(LucideIcons.gripVertical),
                                      ),
                                    ],
                                  )
                              );
                            },
                            // *** Callback when item is reordered ***
                            onReorder: controller.onReorderActivities,
                            // Optional: Improve appearance while dragging
                            proxyDecorator: (Widget child, int index,
                                Animation<double> animation) {
                              return Material( // Ensures elevation shadow is drawn correctly
                                color: Colors.transparent,
                                // Keep card visuals during drag
                                child: child,
                              );
                            },

                            header: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('Choice Activities', style: BessTextStyles.boldCardTitle),
                              ),

                            footer: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ActionInitiator(
                                enabled: !controller.saveInProgress.value,
                                onPressed: controller.saveActivityRanking,
                                enabledText: 'Save Ranking',
                                disabledText: 'Saving...',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          );
        });
      });
  }
}