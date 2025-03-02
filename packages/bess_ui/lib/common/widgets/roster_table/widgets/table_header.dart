import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
        border: Border(bottom: BorderSide(width: 1, color: BessColors.borderPrimary)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: BessSizes.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              tableTitle,
              style: BessTextStyles.tableHeader,
            ),
            BessCircularIcon(
              backgroundColor: BessColors.core,
              icon: Iconsax.menu_1,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}