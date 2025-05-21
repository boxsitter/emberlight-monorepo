import 'package:bess_ui/src/common/styles/text_styles.dart';
import 'package:bess_ui/src/common/widgets/roster_table/controllers/roster_table_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/sizes.dart';

class CheckboxCell extends StatelessWidget {
  final RosterTableController controller;
  final String rowId;

  const CheckboxCell({
    super.key,
    required this.controller,
    required this.rowId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      padding: const EdgeInsets.symmetric(
          horizontal: BessSizes.md, vertical: BessSizes.sm),
      child: SizedBox(
        child: Align(
          alignment: Alignment.center,
          child: Obx(() {
            return Checkbox(
              value: controller.selectedRowIds.contains(rowId),
              onChanged: (bool? newValue) {
                controller.toggleRowSelection(rowId, newValue);
              }
            );
          }),
        ),
      ),
    );
  }
}