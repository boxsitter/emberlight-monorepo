import 'package:bessie/common/styles/text_styles.dart';
import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class StringCell extends StatelessWidget {
  final String content;
  final double width;

  const StringCell({
    super.key,
    this.content = '',
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: BessColors.core,
          border: Border.symmetric(vertical: BorderSide(color: BessColors.borderPrimary, width: 1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: BessSizes.md),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            content,
            style: BessTextStyles.standard,
            maxLines: 2,
          ),
        ),
      ),
    );
  }
}