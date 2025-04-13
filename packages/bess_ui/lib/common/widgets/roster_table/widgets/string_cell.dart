import 'package:bessie/common/styles/text_styles.dart';
import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../../constants/sizes.dart';

class StringCell extends StatelessWidget {
  final String content;
  final double? width;

  const StringCell({
    super.key,
    this.content = '',
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: BessSizes.md, vertical: BessSizes.sm),
      decoration: BoxDecoration(border: Border(right: BorderSide(width: 1, color: BessColors.element3))),
      child: SizedBox(
        height:  BessTextStyles.standard.fontSize! * BessTextStyles.standard.height! * 2,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            content,
            style: BessTextStyles.standard,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}