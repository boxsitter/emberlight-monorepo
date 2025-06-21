import 'package:bess_ui/src/common/styles/text_styles.dart';
import 'package:flutter/material.dart';

import '../../../../common/constants/sizes.dart';

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
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: BessSizes.md, vertical: BessSizes.sm),
      child: SizedBox(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            content,
            style: BessTextStyles.standard,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}