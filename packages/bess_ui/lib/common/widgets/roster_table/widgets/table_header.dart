import 'package:bessie/common/widgets/containers/rounded_container.dart';
import 'package:bessie/common/widgets/roster_table/widgets/table_action_button.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../styles/text_styles.dart';
import '../../icons/t_circular_icon.dart';

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
        padding: const EdgeInsets.only(left: BessSizes.lg, right: BessSizes.md, top: BessSizes.md, bottom: BessSizes.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              tableTitle,
              style: BessTextStyles.tableHeader,
            ),
            const Spacer(),
            BessRoundedContainer(
              showShadow: false,
              padding: EdgeInsets.zero,
              height: 45,
              radius: 100,
              backgroundColor: BessColors.background,
              child: Row(
                children: [
                  TableActionButton(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.fileUp),
                    toolTip: 'Import campers from file',
                  ),

                  TableActionButton(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.download),
                    toolTip: 'Export this roster as a spreadsheet or PDF',
                  ),

                  TableActionButton(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.printer),
                    toolTip: 'Print this roster',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
