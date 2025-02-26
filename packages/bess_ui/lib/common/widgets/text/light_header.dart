import 'package:flutter/material.dart';

import '../../styles/text_styles.dart';

class LightHeader extends StatelessWidget {
  const LightHeader({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: BessTextStyles.lightHeader,
      overflow: TextOverflow.clip,
      maxLines: 1,
    );
  }
}
