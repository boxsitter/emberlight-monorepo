import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:bess_ui/src/common/widgets/roster_table/controllers/roster_table_controller.dart';
import 'package:bess_ui/src/common/widgets/roster_table/widgets/table_action_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../constants/colors.dart';

final List<TableActionButton> noSelectionActions = [
    TableActionButton(
      onPressed: () => print('Not implemented'),
      icon: const Icon(LucideIcons.userRoundPlus),
      toolTip: 'Manually register a camper to this session',
    ),

    TableActionButton(
      onPressed: () => print('Not implemented'),
      icon: const Icon(LucideIcons.fileUp),
      toolTip: 'Import campers from file',
    ),

    TableActionButton(
      onPressed: () => print('Not implemented'),
      icon: const Icon(LucideIcons.download),
      toolTip: 'Export this roster as a spreadsheet or PDF',
    ),

    TableActionButton(
      onPressed: () => print('Not implemented'),
      icon: const Icon(LucideIcons.printer),
      toolTip: 'Print this roster',
    ),
];

final List<TableActionButton> singleSelectionActions = [
  TableActionButton(
    onPressed: () => print('Not implemented'),
    icon: const Icon(LucideIcons.trash),
    toolTip: 'Delete this camper',
  ),

  TableActionButton(
    onPressed: () => print('Not implemented'),
    icon: const Icon(LucideIcons.pencil),
    toolTip: 'Edit this camper\'s info',
  ),
];

final List<TableActionButton> multiSelectionActions = [
  TableActionButton(
    onPressed: () => print('Not implemented'),
    icon: const Icon(LucideIcons.trash),
    toolTip: 'Delete these campers',
  ),
];

class ActionButtonRow extends StatelessWidget {
  final RosterTableController controller;

  const ActionButtonRow({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> getChildren() {
      if (controller.selectedRowIds.isEmpty) {
        return noSelectionActions;
      } else if (controller.selectedRowIds.length == 1) {
        return singleSelectionActions;
      } else {
        return multiSelectionActions;
      }
    }

    return BessRoundedContainer(
      showShadow: false,
      padding: EdgeInsets.zero,
      height: 36,
      radius: 100,
      backgroundColor: BessColors.background,

      child: Obx(() {
        return Row(
          children: getChildren(),
        );}
      ),
    );
  }
}
