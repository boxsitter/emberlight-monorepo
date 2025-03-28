import 'package:bessie/pages/activity_preferences/controllers/activity_preferences_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/containers/rounded_container.dart';
import '../../../common/widgets/layouts/templates/site_layout.dart';
import '../../../common/widgets/roster_table/controllers/roster_table_controller.dart';
import '../widgets/cabin_card_button.dart';

class ActivityPreferencesCabins extends StatelessWidget {
  const ActivityPreferencesCabins({super.key});

  @override
  Widget build(BuildContext context) {
    return const BessSiteTemplate(desktop: ActivityPreferencesCabinsDesktop());
  }
}

class ActivityPreferencesCabinsDesktop extends StatelessWidget {
  const ActivityPreferencesCabinsDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ActivityPreferencesController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cabins',
          style: BessTextStyles.lightTitle,
          overflow: TextOverflow.clip,
          maxLines: 1,
        ),

        const SizedBox(height: 24),

        Expanded(
          child: Obx(() {
            if (!controller.isCabinDataLoaded.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.only(right: 24),
              child: Wrap (
                spacing: 24,
                runSpacing: 24,
                children: controller.cabinNames.keys.map((cabinId) {
                  final name = controller.cabinNames[cabinId] ?? 'Unknown';
                  final count = controller.camperCounts[cabinId] ?? 0;
                  final preferencesCount = controller.campersWithPreferencesCounts[cabinId] ?? 0;

                  return CabinCardButton(
                    cabinId: cabinId,
                    name: name,
                    count: count,
                    preferenceCount: preferencesCount,
                    controller: controller,
                  );
                }).toList(),
              ),
            );
          }),
        ),
      ],
    );
  }
}

