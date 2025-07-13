import 'package:bess_ui/src/common/widgets/buttons/icon_button.dart';
import 'package:bess_ui/src/pages/activity_preferences/controllers/activity_preferences_controller.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../common/constants/colors.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/header/menu_bar.dart';

List<Widget> buildActivityPreferencesCenterActions({
  required ActivityPreferencesController controller,
}) {
  return [
    BessIconButton(
      iconData: LucideIcons.house,
      onPressed: () => controller.setCabinsOpened(!controller.cabinsOpened),
      selected: controller.cabinsOpened,
      enabled: controller.selectedCabinData != null,
      radius: 8,
    ),

    SizedBox(width: 16,),

    BessIconButton(
      iconData: LucideIcons.usersRound,
      onPressed: () => controller.setCampersOpened(!controller.campersOpened),
      selected: controller.campersOpened,
      enabled: !controller.cabinsOpened,
      radius: 8,
    ),
  ];
}

BessMenuBar<ActivityPreferencesController> buildActivityPreferencesMenuBar({
  required ActivityPreferencesController controller,
}) {
  return BessMenuBar<ActivityPreferencesController>(
    externalPageController: controller,
  );
}
