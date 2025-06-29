import 'package:bess_ui/src/common/widgets/buttons/action_initiator.dart';
import 'package:bess_ui/src/common/widgets/misc/card_selector.dart';
import 'package:bess_ui/src/pages/activity_preferences/controllers/activity_preferences_controller.dart';
import 'package:bess_ui/src/pages/activity_preferences/widgets/activity_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/header/menu_bar.dart';
import '../../../common/widgets/layouts/templates/site_layout.dart';

class ActivityPreferencesSelector extends StatelessWidget {
  const ActivityPreferencesSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BessSiteTemplate(
      desktop: ActivityPreferencesSelectorDesktop(),
      menuBar: BessMenuBar(),
    );
  }
}

class ActivityPreferencesSelectorDesktop extends StatelessWidget {
  const ActivityPreferencesSelectorDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActivityPreferencesController>(
        builder: (controller) {
          if (!controller.isCamperDataLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ranking activities for ${controller.selectedCamper?.name}',
                style: BessTextStyles.lightTitle,
                overflow: TextOverflow.clip,
                maxLines: 1,
              ),
              const SizedBox(height: BessSizes.spaceBtwItems),
              CardSelector(
                cardHeight: 60,
                cardWidth: 140,
                maxLines: 2,
                items: controller.campers,
                completedItems: controller.camperIsCompleted,
                selectedItem: controller.selectedCamper,
                onSelectItem: controller.selectCamper,
                isHorizontal: true,
              ),
              const SizedBox(height: BessSizes.spaceBtwItems),
              Expanded(
                child: Row(
                  children: [
                    ActivityReorderableList(
                      title: 'Choice Activities',
                      orderedItemIds: controller.orderedStandardActivityIds,
                      displayInfo: controller.showActivityInfo,
                      itemIdsToNames: controller.standardActivityNames,
                      onReorder: controller.onReorderStandardActivities,
                    ),

                    const SizedBox(width: BessSizes.spaceBtwItems),

                    ActivityReorderableList(
                      title: 'Skills Recs',
                      orderedItemIds: controller.orderedSkillsActivityIds,
                      displayInfo: controller.showActivityInfo,
                      itemIdsToNames: controller.skillsActivityNames,
                      onReorder: controller.onReorderSkillsActivities,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: BessSizes.spaceBtwItems),

              ActionInitiator(
                awaiting: !controller.saveInProgress,
                onPressed: controller.saveActivityRanking,
                enabledText: 'Save Ranking',
                awaitingText: 'Saving...',
                width: 400,
              ),
            ],
          );
        });
  }
}
