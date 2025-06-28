import 'package:bess_ui/src/common/widgets/containers/titled_container.dart';
import 'package:bess_ui/src/common/widgets/misc/card_selector.dart';
import 'package:ember_core/ember_core.dart';
import 'package:flutter/material.dart';

import '../../../common/constants/colors.dart';
import '../../../common/constants/sizes.dart';
import '../controllers/rosters_controller.dart';

class ActivitySwitcher extends StatelessWidget {
  const ActivitySwitcher({
    super.key,
    required this.controller,
  });

  final RostersController controller;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.all(BessSizes.md),
        decoration: BoxDecoration(border: BorderDirectional(bottom: BorderSide(color: BessColors.borderPrimary, width: 2))),
        height: 500,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitledContainer(
              title: 'Select Activity Period',
              child: CardSelector(
                items: controller.amas,
                onSelectItem: controller.setSelectedAma,
                selectedItem: controller.selectedAma,
                maxLines: 1,
                cardWidth: 240,
                isHorizontal: false,

              ),
            ),

            SizedBox(width: BessSizes.spaceBtwItems),
          ],
        ),
      ),
    );
  }
}
