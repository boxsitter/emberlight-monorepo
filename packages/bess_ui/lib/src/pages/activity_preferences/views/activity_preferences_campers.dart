import 'package:bess_ui/src/pages/activity_preferences/controllers/activity_preferences_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/layouts/templates/site_layout.dart';
import '../widgets/card_button.dart';

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Campers in ${controller.selectedCabinName}',
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

            return SingleChildScrollView(
              padding: const EdgeInsets.only(right: 24),
              child: Wrap (
                spacing: 24,
                runSpacing: 24,
                children: controller.camperNames.keys.map((camperId) {
                  final name = controller.camperNames[camperId] ?? 'Unknown';

                  return CardButton(
                    title: name,
                    height: 70,
                    width: 200,
                    onTap: () => controller.navigateToSelection(camperId, name),
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

