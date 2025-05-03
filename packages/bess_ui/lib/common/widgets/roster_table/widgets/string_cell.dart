import 'package:bess_ui/common/styles/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../constants/sizes.dart';
import '../../../utils/device/device_utility.dart';

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