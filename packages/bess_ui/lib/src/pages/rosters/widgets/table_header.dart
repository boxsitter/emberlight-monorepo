import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../common/constants/colors.dart';
import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';
import 'action_button_row.dart';

class TableHeader extends StatelessWidget {
  final String title;
  final int count;
  final Set<String> selectedRowIds;
  final VoidCallback onImport;
  final VoidCallback onDelete;

  const TableHeader({
    super.key,
    required this.title,
    required this.count,
    required this.selectedRowIds,
    required this.onImport,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BessColors.core,
        border: Border(bottom: BorderSide(width: 1, color: BessColors.borderPrimary)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: BessSizes.md, left: BessSizes.md, top: BessSizes.ms, bottom: BessSizes.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: BessTextStyles.tableHeader,
                ),

                SizedBox(height: BessSizes.xs),

                BessRoundedContainer(
                  radius: 5,
                  backgroundColor: BessColors.crust,
                  padding: const EdgeInsets.all(BessSizes.xs),
                  child: Text(
                    'Count: $count',
                    style: BessTextStyles.secondarySmall,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ActionButtonRow(
              selectedRowIds: selectedRowIds,
              onImport: onImport,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
