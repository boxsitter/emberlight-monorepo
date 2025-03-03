import 'package:bessie/common/widgets/containers/rounded_container.dart';
import 'package:bessie/common/widgets/roster_table/widgets/table_action_button.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../constants/colors.dart';

class ActionButtonRow extends StatelessWidget {
  const ActionButtonRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BessRoundedContainer(
      showShadow: false,
      padding: EdgeInsets.zero,
      height: 46,
      radius: 100,
      backgroundColor: BessColors.background,
      child: Row(
        children: [
          TableActionButton(
            onPressed: () {},
            icon: const Icon(LucideIcons.userRoundPlus),
            toolTip: 'Manually register a camper to this session',
          ),

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
    );
  }
}
