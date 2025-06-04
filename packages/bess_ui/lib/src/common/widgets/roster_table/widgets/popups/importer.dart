import 'package:bess_ui/bess_ui.dart';
import 'package:bess_ui/src/common/widgets/buttons/action_initiator.dart';
import 'package:bess_ui/src/common/widgets/roster_table/controllers/roster_table_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../constants/sizes.dart';

/// A widget to create a standardized popup for importing CSV files.
class Importer extends StatelessWidget {
  final RosterTableController controller;

  const Importer({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(BessSizes.defaultSpace),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Import Instructions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: BessSizes.spaceBtwItems),
          const Text(
            'This expects a spreadsheet export from UltraCamp. '
                'It must be a .csv file. UltraCamp will call it something like "export for excel".',
          ),
          const SizedBox(height: BessSizes.spaceBtwItems),
          const Text(
            'The exported UltraCamp report should be of the master roster for a single camp session and contain the fields:',
          ),
          const SizedBox(height: BessSizes.spaceBtwItems),
          const Text(
            '• "nameFirst"\n'
                '• "nameLast"\n'
                '• "Birthdate"\n'
                '• "nickname"\n'
                '• "idPerson"\n'
                '• "gender" or "expressionName"\n'
                '• "Cabin"',
          ),
          const SizedBox(height: BessSizes.spaceBtwItems),
          const Text(
            'The data for nickname, gender/expressionName, or cabin can be empty or incomplete, but Bessie expects the column to at least be included in the report.'
          ),
          const SizedBox(height: BessSizes.spaceBtwSections),
          Center(
            child: Obx( () {
              return ActionInitiator(
                enabledText: 'Add File',
                disabledText: 'Importing... (this may take a while)',
                onPressed: controller.importCsv,
                enabled: !controller.importingCampers.value,
              );
            }),
          ),
        ],
      ),
    );
  }
}