import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../styles/text_styles.dart';

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
            Expanded(
              child: Text(
                columnLabel,
                style: BessTextStyles.columnHeader,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}