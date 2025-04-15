import 'package:bessie/common/constants/sizes.dart';
import 'package:bessie/common/styles/text_styles.dart';
import 'package:bessie/pages/session_manager/session_manager_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/buttons/inkwell_button.dart';
import '../../common/widgets/layouts/templates/site_layout.dart';

class SessionManager extends StatelessWidget {
  const SessionManager({super.key});

  @override
  Widget build(BuildContext context) {
    return BessSiteTemplate(desktop: SessionManagerDesktop());
  }
}

class SessionManagerDesktop extends StatelessWidget {
  const SessionManagerDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    // Find your already registered controller instance
    final SessionManagerController controller = Get.find<SessionManagerController>();

    return Padding(
      padding: const EdgeInsets.all(BessSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Cabins',
            style: BessTextStyles.tableHeader,
          ),

          const SizedBox(height: BessSizes.spaceBtwSections),

          // Use Expanded + SingleChildScrollView if the Wrap might overflow vertically
          SingleChildScrollView( // Allows scrolling if content exceeds screen height
            child: Obx(() {
              // Loader and empty state remain the same
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.cabinPrinIdsToNames.isEmpty) {
                return const Center(child: Text("No cabins found."));
              }

              // --- Use Wrap instead of GridView ---
              return Wrap(
                spacing: BessSizes.spaceBtwItems / 2, // Horizontal space between items on the same line
                runSpacing: BessSizes.spaceBtwItems / 2, // Vertical space between lines
                children: controller.cabinPrinIdsToNames.entries.map((entry) {
                  // Extract key and value from the entry
                  final String cabinPrinId = entry.key;
                  final String cabinName = entry.value;

                  // Build the widget for each entry (your existing logic)
                  final isSelected = controller.selectedCabinPrinIds.contains(cabinPrinId);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: BessSizes.xs, vertical: BessSizes.xs),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isSelected,
                          onChanged: (bool? newValue) {
                            controller.toggleCabinSelection(cabinPrinId);
                          },
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        Flexible(
                          child: Text(
                            cabinName,
                            style: Theme.of(context).textTheme.bodyMedium,
                            softWrap: false,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(), // Convert the mapped Iterable<Widget> to a List<Widget>
              );
            }),
          ),

          const SizedBox(height: BessSizes.spaceBtwInputFields),

          InkwellButton(
            text: 'Commit Changes',
            width: 140,
            height: 20,
            onTap: () => controller.commitSelection(),
          ),

        ],
      ),
    );
  }
}