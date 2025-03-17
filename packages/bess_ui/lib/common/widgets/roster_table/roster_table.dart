import 'package:bessie/common/constants/colors.dart';
import 'package:bessie/common/constants/sizes.dart';
import 'package:bessie/common/widgets/containers/rounded_container.dart';
import 'package:bessie/common/widgets/roster_table/widgets/column_header.dart';
import 'package:bessie/common/widgets/roster_table/widgets/data_row.dart';
import 'package:bessie/common/widgets/roster_table/widgets/table_header.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/helpers/bess_id_functions.dart';
import 'controllers/roster_table_controller.dart';

class BessRosterTable extends StatelessWidget {
  final List<String> columns;
  final RosterTableController controller;
  final String tableTitle;
  static const double columnWidth = 250;

  const BessRosterTable({
    super.key,
    required this.columns,
    required this.controller,
    required this.tableTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      List<List<String>> data = controller.campers.values.map((camper) {
        return [
          camper.fullName,
          camper.preferredName,
          camper.gender,
          camper.age.toString(), // converting int to String
          BessIdFunctions.cabinNameFromId(camper.cabinId, 'none'),
        ];
      }).toList();

      return BessRoundedContainer(
        height: double.infinity,
        showShadow: false,
        showBorder: true,
        borderThickness: BessSizes.borderThicknessMd,
        backgroundColor: BessColors.core,
        padding: EdgeInsets.zero,
        clipContent: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TableHeader(tableTitle: tableTitle, controller: controller),

            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: columns.length * 250,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: columns.map((String column) => ColumnHeader(columnLabel: column, width: columnWidth)).toList(),
                        ),

                        Divider(
                          height: 1,
                          color: BessColors.borderPrimary,
                        ),

                        Expanded(
                          child: ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return BessDataRow(data: data[index], cellWidth: columnWidth,);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

