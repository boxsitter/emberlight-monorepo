import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../styles/text_styles.dart';
import '../../icons/t_circular_icon.dart';

class ColumnHeader extends StatelessWidget {
  const ColumnHeader({
    super.key,
    required this.columnLabel,
  });

  final String columnLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: BessColors.background,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: BessSizes.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              columnLabel,
              style: BessTextStyles.columnHeader,
            ),
          ],
        ),
      ),
    );
  }
}