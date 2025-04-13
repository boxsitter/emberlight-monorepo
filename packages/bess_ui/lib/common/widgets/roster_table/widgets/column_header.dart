import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';
import '../../../styles/text_styles.dart';

class ColumnHeader extends StatelessWidget {
  final String columnLabel;
  final double? width;

  const ColumnHeader({
    super.key,
    required this.columnLabel,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: BessSizes.md, vertical: BessSizes.sm),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          columnLabel,
          style: BessTextStyles.columnHeader,
          maxLines: 1,
          overflow: TextOverflow.clip,
        ),
      ),
    );
  }
}