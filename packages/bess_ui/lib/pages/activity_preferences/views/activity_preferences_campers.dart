import 'package:bessie/pages/activity_preferences/controllers/activity_preferences_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/layouts/templates/site_layout.dart';
import '../widgets/cabin_card_button.dart';

class ActivityPreferencesCampers extends StatelessWidget {
  const ActivityPreferencesCampers({super.key});

  @override
  Widget build(BuildContext context) {
    return const BessSiteTemplate(desktop: ActivityPreferencesCampersDesktop());
  }
}

class ActivityPreferencesCampersDesktop extends StatelessWidget {
  const ActivityPreferencesCampersDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final ActivityPreferencesController controller = Get.find<ActivityPreferencesController>();

    final args = Get.arguments;

    if (args is! Map<String, String> || !args.containsKey('cabinId') || !args.containsKey('cabinName')) {
      // Show an error widget instead of crashing
      return const Center(
        child: Text(
          // TODO: Make a more standardized error message to display or throw something and let the error service display it
          'Error: Missing cabin information.',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      );
    }

    final selectedCabinId = args['cabinId']!;
    final selectedCabinName = args['cabinName']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Campers in $selectedCabinName',
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

                  return CabinCardButton(name: name, count: count, preferenceCount: preferencesCount, cabinId: '', controller: controller);
                }).toList(),
              ),
            );
          }),
        ),
      ],
    );
  }
}

