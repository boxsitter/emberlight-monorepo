import 'package:bess_ui/src/common/styles/text_styles.dart';
import 'package:bess_ui/src/common/widgets/roster_table/controllers/roster_table_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/sizes.dart';

class HeaderCheckbox extends StatelessWidget {
  final RosterTableController controller;

  const HeaderCheckbox({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(horizontal: BessSizes.md, vertical: BessSizes.sm),
      child: Align(
        alignment: Alignment.center,
        child: Obx(() {
          return Checkbox(
            value: controller.selectedRowIds.containsAll(controller.roster..map((rosterable) => rosterable.id).toSet()),
            onChanged: (bool? newValue) {
              controller.toggleSelectAll(newValue);
            }
          );
        }),
      ),
    );
  }
}

