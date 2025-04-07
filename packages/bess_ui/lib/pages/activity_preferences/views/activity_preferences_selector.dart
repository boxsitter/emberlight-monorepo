import 'package:bessie/pages/activity_preferences/controllers/activity_preferences_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/layouts/templates/site_layout.dart';

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

    if (controller.selectedCabinName == null || controller.selectedCabinId == null) {
      // Show an error widget instead of crashing
      return const Center(
        child: Text(
          // TODO: Make a more standardized error message to display or throw something and let the error service display it
          'Error: Missing cabin information.',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Obx(() {
            if (!controller.isCamperDataLoaded.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return Placeholder();
          }),
        ),

        const SizedBox(height: BessSizes.spaceBtwItems),

        Text(
          'Ranking activities for ${controller.selectedCabinName}',
          style: BessTextStyles.lightTitle,
          overflow: TextOverflow.clip,
          maxLines: 1,
        ),

        const SizedBox(height: BessSizes.spaceBtwSections),

        Expanded(
          child: Obx(() {
            if (!controller.isCamperDataLoaded.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return Placeholder();
          }),
        ),
      ],
    );
  }
}