import 'package:bess_ui/src/pages/activity_preferences/controllers/activity_preferences_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/header/menu_bar.dart';
import '../../../common/widgets/layouts/templates/site_layout.dart';
import '../widgets/card_button.dart';

class ActivityPreferencesCabins extends StatelessWidget {
  const ActivityPreferencesCabins({super.key,});

  @override
  Widget build(BuildContext context) {
    return BessSiteTemplate(
      desktop: ActivityPreferencesCabinsDesktop(),
      menuBar: BessMenuBar(),
    );
  }
}

class ActivityPreferencesCabinsDesktop extends StatelessWidget {
  const ActivityPreferencesCabinsDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActivityPreferencesController>(
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
