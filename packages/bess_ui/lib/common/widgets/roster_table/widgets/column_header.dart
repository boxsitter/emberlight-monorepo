import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../styles/text_styles.dart';

class ColumnHeader extends StatelessWidget {
  final String columnLabel;
  final double width;

  const ColumnHeader({
    super.key,
    required this.columnLabel,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: width,
      decoration: BoxDecoration(
        color: BessColors.background,
        border: Border.symmetric(vertical: BorderSide(color: BessColors.borderPrimary, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: BessSizes.md),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          columnLabel,
          style: BessTextStyles.columnHeader,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}