import 'package:bess_ui/src/common/theme/widget_themes/checkbox_theme.dart';
import 'package:bess_ui/src/common/utils/helpers/helper_functions.dart';
import 'package:bess_ui/src/pages/rosters/widgets/column_config_button.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../common/constants/colors.dart';
import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/containers/rounded_container.dart';
import '../../../common/widgets/header/menu_bar.dart';
import '../../../common/widgets/layouts/templates/site_layout.dart';
import '../controllers/rosters_controller.dart';

/// A builder function that constructs and returns a configured [BessMenuBar] for the Rosters page.
List<Widget> buildRostersCenterActions({
  required RostersController controller,
}) {
    return [
        ColumnConfigButton(controller: controller),
    ];
  }