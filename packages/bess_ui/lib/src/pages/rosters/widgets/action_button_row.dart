import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:bess_ui/src/pages/rosters/widgets/table_action_button.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../common/constants/colors.dart';

class ActionButtonRow extends StatelessWidget {
  final Set<String> selectedRowIds;
  final VoidCallback onImport;
  final VoidCallback onDelete;
  // Add other callbacks as needed, e.g., onEdit, onAddManually

  const ActionButtonRow({
    required this.selectedRowIds,
    required this.onImport,
    required this.onDelete,
    super.key,
  });

  List<TableActionButton> _buildNoSelectionActions() {
    return [
      TableActionButton(
        onPressed: onImport,
        icon: const Icon(LucideIcons.fileUp),
        toolTip: 'Import from CSV',
      ),
    ];
  }

  List<TableActionButton> _buildSingleSelectionActions() {
    return [
      TableActionButton(
        onPressed: onDelete,
        icon: const Icon(LucideIcons.trash),
        toolTip: 'Delete this camper',
      ),
    ];
  }

  List<TableActionButton> _buildMultiSelectionActions() {
    return [
      TableActionButton(
        onPressed: onDelete,
        icon: const Icon(LucideIcons.trash),
        toolTip: 'Delete these campers',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> getChildren() {
      if (selectedRowIds.isEmpty) {
        return _buildNoSelectionActions();
      } else if (selectedRowIds.length == 1) {
        return _buildSingleSelectionActions();
      } else {
        return _buildMultiSelectionActions();
      }
    }

    return BessRoundedContainer(
      showShadow: false,
      padding: EdgeInsets.zero,
      height: 36,
      radius: 100,
      backgroundColor: BessColors.background,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: getChildren(),
      ),
    );
  }
}
