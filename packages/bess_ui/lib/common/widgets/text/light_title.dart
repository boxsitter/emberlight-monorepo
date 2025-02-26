import 'package:flutter/material.dart';

import '../../styles/text_styles.dart';

class LightTitle extends StatelessWidget {
  const LightTitle({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: BessTextStyles.lightTitle,
      overflow: TextOverflow.clip,
      maxLines: 1,
    );
  }
}
