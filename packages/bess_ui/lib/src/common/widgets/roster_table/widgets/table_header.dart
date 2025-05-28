import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:bess_ui/src/common/widgets/roster_table/controllers/roster_table_controller.dart';
import 'package:bess_ui/src/common/widgets/roster_table/widgets/action_button_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../styles/text_styles.dart';

class TableHeader extends StatelessWidget {
  final RosterTableController controller;

  const TableHeader({
    super.key,
    required this.tableTitle,
    required this.controller,
  });

  final String tableTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: BessColors.core,
        border: Border(
            bottom: BorderSide(width: 1, color: BessColors.borderPrimary)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: BessSizes.lg,
          right: BessSizes.md,
          top: BessSizes.ms,
          bottom: BessSizes.ms,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tableTitle,
                  style: BessTextStyles.tableHeader,
                ),

                BessRoundedContainer(
                  radius: 5,
                  backgroundColor: BessColors.crust,
                  padding: const EdgeInsets.all(BessSizes.xs),
                  child: Obx(() => Text('Campers: ${controller.count}',
                    style: BessTextStyles.secondarySmall,
                  )),
                ),
              ],
            ),

            const Spacer(),

            ActionButtonRow(controller: controller),
          ],
        ),
      ),
    );
  }
}
