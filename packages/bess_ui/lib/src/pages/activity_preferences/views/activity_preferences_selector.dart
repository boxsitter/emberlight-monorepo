import 'package:bess_ui/src/common/widgets/buttons/action_initiator.dart';
import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:bess_ui/src/pages/activity_preferences/controllers/activity_preferences_controller.dart';
import 'package:bess_ui/src/pages/activity_preferences/widgets/activity_reorderable_list.dart';
import 'package:bess_ui/src/common/widgets/misc/horizontal_card_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/layouts/templates/site_layout.dart';
import '../../../common/widgets/state/controller_dependant_wrapper.dart';
import '../widgets/small_card_button.dart';

class ActivityPreferencesSelector extends StatelessWidget {
  const ActivityPreferencesSelector({
    super.key,
    required this.pageControllerTag,
  });

  final String pageControllerTag;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActivityPreferencesController(), tag: pageControllerTag);
    return BessSiteTemplate(
      desktop: ActivityPreferencesSelectorDesktop(
        controller: controller,
        tag: pageControllerTag,
      ),
    );
  }
}

class ActivityPreferencesSelectorDesktop extends StatelessWidget {
  const ActivityPreferencesSelectorDesktop({
    super.key,
    required this.controller,
    required this.tag,
  });

  final ActivityPreferencesController controller;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return ControllerDependantWrapper<ActivityPreferencesController>(
        controller: controller,
        tag: tag,
        builder: (controller) {
          if (!controller.isCamperDataLoaded) {
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
              HorizontalCardSelector(
                itemIdsToNames: controller.camperNames,
                selectedId: controller.selectedCamperId,
                completedIds: controller.camperIsCompleted,
                selectItem: controller.selectCamper,
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

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ActionInitiator(
                  enabled: !controller.saveInProgress,
                  onPressed: controller.saveActivityRanking,
                  enabledText: 'Save Ranking',
                  disabledText: 'Saving...',
                  width: 400,
                ),
              ),
            ],
          );
        });
  }
}
