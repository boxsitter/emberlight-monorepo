import 'package:bess_ui/src/pages/rosters/widgets/searchbar.dart';
import 'package:flutter/material.dart';

import '../../../common/constants/colors.dart';
import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';
import 'menu_bar.dart';

class TableHeader extends StatelessWidget {
  final String title;
  final String pageControllerTag;
  final int count;
  final Set<String> selectedRowIds;
  final VoidCallback onImport;
  final VoidCallback onDelete;
  final void Function(String) onSearchChange;
  final bool noMatches;

  const TableHeader({
    super.key,
    required this.title,
    required this.pageControllerTag,
    required this.count,
    required this.selectedRowIds,
    required this.onImport,
    required this.onDelete,
    required this.onSearchChange,
    required this.noMatches,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BessColors.core,
        border: Border(bottom: BorderSide(width: 1, color: BessColors.borderPrimary)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: BessSizes.bg, left: BessSizes.bg, top: BessSizes.bg, bottom: BessSizes.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: BessTextStyles.tableHeader,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '($count)',
                      style: BessTextStyles.tableHeaderSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: BessSizes.sm),
                TableMenuBar(pageControllerTag: pageControllerTag),
              ],
            ),
            const Spacer(),
            searchbar(onSearchChange: onSearchChange, noMatches: noMatches),
          ],
        ),
      ),
    );
  }
}
