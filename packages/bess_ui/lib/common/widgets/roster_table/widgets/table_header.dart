import 'package:bessie/common/widgets/containers/rounded_container.dart';
import 'package:bessie/common/widgets/roster_table/widgets/action_button_row.dart';
import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../styles/text_styles.dart';

class TableHeader extends StatelessWidget {
  const TableHeader({
    super.key,
    required this.tableTitle,
  });

  final String tableTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: BessColors.core,
        border: Border(
            bottom: BorderSide(width: 1, color: BessColors.borderPrimary)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
            left: BessSizes.lg,
            right: BessSizes.md,
            top: BessSizes.md,
            bottom: BessSizes.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              tableTitle,
              style: BessTextStyles.tableHeader,
            ),

            const SizedBox(width: 100),

            BessRoundedContainer(
              width: 80,
              height: 80,
              backgroundColor: BessColors.primary,
              child: Text('Count: 30'),
            ),

            const Spacer(),

            const ActionButtonRow(),
          ],
        ),
      ),
    );
  }
}
