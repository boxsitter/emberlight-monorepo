import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:bess_ui/src/common/widgets/roster_table/controllers/roster_table_controller.dart';
import 'package:bess_ui/src/common/widgets/roster_table/widgets/popups/importer.dart';
import 'package:bess_ui/src/common/widgets/roster_table/widgets/table_action_button.dart';
import 'package:ember_core/ember_core_debug.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../constants/colors.dart';

class ActionButtonRow extends StatelessWidget {
  final RosterTableController controller;

  const ActionButtonRow({
    required this.controller,
    super.key,
  });

  /// Actions available when no rows are selected.
  /// These methods now have access to the [controller].
  List<TableActionButton> _buildNoSelectionActions() {
    return [
      // TableActionButton(
      //   // You will need to implement the 'manuallyRegisterCamper' method in your controller.
      //   onPressed: () => controller.manuallyRegisterCamper(),
      //   icon: const Icon(LucideIcons.userRoundPlus),
      //   toolTip: 'Manually register a camper to this session',
      // ),
      TableActionButton(
        // You will need to implement the 'importFromFile' method in your controller.
        onPressed: () => controller.showPopup('Import Roster From UltraCamp', Importer(controller: controller)),
        icon: const Icon(LucideIcons.fileUp),
        toolTip: 'Import campers from file',
      ),
      // TableActionButton(
      //   // You will need to implement the 'exportRoster' method in your controller.
      //   onPressed: () => Debug.logInfo('Not implemented'),
      //   icon: const Icon(LucideIcons.download),
      //   toolTip: 'Export this roster as a spreadsheet or PDF',
      // ),
      // TableActionButton(
      //   // You will need to implement the 'printRoster' method in your controller.
      //   onPressed: () => Debug.logInfo('Not implemented'),
      //   icon: const Icon(LucideIcons.printer),
      //   toolTip: 'Print this roster',
      // ),
    ];
  }

  /// Actions available when a single row is selected.
  List<TableActionButton> _buildSingleSelectionActions() {
    return [
      TableActionButton(
        // You will need to implement the 'deleteSelected' method in your controller.
        onPressed: () => controller.deleteSelected(),
        icon: const Icon(LucideIcons.trash),
        toolTip: 'Delete this camper',
      ),
      // TableActionButton(
      //   // You will need to implement the 'editSelected' method in your controller.
      //   onPressed: () => Debug.logInfo('Not implemented'),
      //   icon: const Icon(LucideIcons.pencil),
      //   toolTip: 'Edit this camper\'s info',
      // ),
    ];
  }

  /// Actions available when multiple rows are selected.
  List<TableActionButton> _buildMultiSelectionActions() {
    return [
      TableActionButton(
        // This can call the same delete method.
        onPressed: () => controller.deleteSelected(),
        icon: const Icon(LucideIcons.trash),
        toolTip: 'Delete these campers',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> getChildren() {
      if (controller.selectedRowIds.isEmpty) {
        return _buildNoSelectionActions();
      } else if (controller.selectedRowIds.length == 1) {
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

      child: Obx(() {
        return Row(
          children: getChildren(),
        );}
      ),
    );
  }
}
