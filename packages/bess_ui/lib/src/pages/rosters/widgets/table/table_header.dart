import 'package:bess_ui/src/common/widgets/buttons/icon_button.dart';
import 'package:ember_core/ember_core.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../common/constants/colors.dart';
import '../../../../common/styles/text_styles.dart';
import '../../../../common/utils/helpers/helper_functions.dart';
import '../../../../common/widgets/buttons/checkbox.dart';

class BessTableHeader extends StatelessWidget {
  final bool isSingle;
  final VoidCallback onToggle;
  final VoidCallback onToggleGroupExpanded;
  final String headerTitle;
  final RosterGroup group;
  final bool? isSelected;
  final Color? separatorsColor;
  final bool isExpanded;

  const BessTableHeader({
    super.key,
    this.isSingle = true,
    required this.onToggle,
    this.isSelected,
    this.separatorsColor,
    required this.group,
    required this.onToggleGroupExpanded,
    required this.isExpanded,
    required this.headerTitle,
  });

  @override
  Widget build(BuildContext context) {
    String? fieldTitle = null;
    if (group.groupByField != null) {
      if (group.groupByField is AMABlock) {}
      fieldTitle = group.groupByField?.displayTitle;
    }
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected == true && isExpanded != true
            ? BessHelperFunctions.blendColors(BessColors.core, BessColors.primary, 30)
            : BessColors.core,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BessCheckbox(
            value: isSelected,
            tristate: true,
            onPressed: onToggle,
          ),
          SizedBox(width: 32),
          Text(
            headerTitle,
            style: BessTextStyles.tableHeader.copyWith(leadingDistribution: TextLeadingDistribution.even),
            maxLines: 1,
          ),
          Spacer(),
          if (group.items.length != 0) Icon(LucideIcons.usersRound),
          if (group.items.length != 0) SizedBox(width: 6),
          if (group.items.length != 0)
            Text(
              '${group.items.length}',
              style: BessTextStyles.tableHeaderSecondary.copyWith(leadingDistribution: TextLeadingDistribution.even),
              maxLines: 1,
            ),
          SizedBox(width: 16),
          if (!isSingle)
            BessIconButton(
              iconData: isExpanded ? LucideIcons.chevronsDownUp : LucideIcons.chevronsUpDown,
              onPressed: onToggleGroupExpanded,
              size: 47,
            ),
        ],
      ),
    );
  }
}
