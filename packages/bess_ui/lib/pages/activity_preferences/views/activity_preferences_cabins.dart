import 'package:bessie/pages/activity_preferences/controllers/activity_preferences_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/layouts/templates/site_layout.dart';
import '../widgets/card_button.dart';

class ActivityPreferencesCabins extends StatelessWidget {
  const ActivityPreferencesCabins({super.key});

  @override
  Widget build(BuildContext context) {
    return const BessSiteTemplate(desktop: ActivityPreferencesCabinsDesktop(), mobile: ActivityPreferencesCabinsMobile());
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

        const SizedBox(height: BessSizes.spaceBtwSections),

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

                  return CardButton(
                    title: name,
                    subtitle: '$preferencesCount/$count campers completed',
                    height: 90,
                    width: 250,
                    onTap: () => controller.navigateToCampers(cabinId, name),
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

class ActivityPreferencesCabinsMobile extends StatelessWidget {
  const ActivityPreferencesCabinsMobile({super.key});

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

        const SizedBox(height: BessSizes.spaceBtwSections),

        Expanded(
          child: Obx(() {
            if (!controller.isCabinDataLoaded.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                alignment: Alignment.topCenter, // Center the wrap within the full-width container
                child: Wrap(
                  alignment: WrapAlignment.center, // Center-align the items in each row
                  spacing: 24,
                  runSpacing: 24,
                  children: controller.cabinNames.keys.map((cabinId) {
                    final name = controller.cabinNames[cabinId] ?? 'Unknown';
                    final count = controller.camperCounts[cabinId] ?? 0;
                    final preferencesCount = controller.campersWithPreferencesCounts[cabinId] ?? 0;

                    return CardButton(
                      title: name,
                      subtitle: '$preferencesCount/$count campers completed',
                      height: 90,
                      width: double.infinity,
                      onTap: () => controller.navigateToCampers(cabinId, name),
                    );
                  }).toList(),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

