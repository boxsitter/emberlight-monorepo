import 'package:bess_ui/src/pages/activity_preferences/controllers/activity_preferences_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/layouts/templates/site_layout.dart';
import '../../../common/widgets/state/controller_dependant_wrapper.dart';
import '../widgets/card_button.dart';

class ActivityPreferencesCabins extends StatelessWidget {
  const ActivityPreferencesCabins({
    super.key,
    required this.pageControllerTag,
  });

  final String pageControllerTag;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActivityPreferencesController(), tag: pageControllerTag);
    return BessSiteTemplate(
      desktop: ActivityPreferencesCabinsDesktop(
        controller: controller,
        tag: pageControllerTag,
      ),
    );
  }
}

class ActivityPreferencesCabinsDesktop extends StatelessWidget {
  const ActivityPreferencesCabinsDesktop({
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
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Cabins',
            style: BessTextStyles.lightTitle,
            overflow: TextOverflow.clip,
            maxLines: 1,
          ),
          const SizedBox(height: BessSizes.spaceBtwSections),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(right: 24),
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                children: controller.cabinNames.keys.map((cabinId) {
                  final name = controller.cabinNames[cabinId] ?? 'Unknown';
                  final count = controller.camperCounts[cabinId] ?? 0;
                  final preferencesCount = controller.campersWithPreferencesCounts[cabinId] ?? 0;
                  final bool isCompleted = preferencesCount >= count;
                  final bool isInProgress = preferencesCount > 0 && preferencesCount < count;

                  return CardButton(
                    title: name,
                    subtitle: '$preferencesCount/$count campers completed',
                    isCompleted: isCompleted,
                    isInProgress: isInProgress,
                    height: 90,
                    width: 250,
                    onTap: () => controller.navigateToSelection(cabinId, name),
                  );
                }).toList(),
              ),
            ),
          )
        ]);
      },
    );
  }
}
