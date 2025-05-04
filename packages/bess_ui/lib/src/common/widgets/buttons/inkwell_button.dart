import 'package:bess_ui/src/common/constants/colors.dart';
import 'package:bess_ui/src/common/styles/text_styles.dart';
import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:flutter/material.dart';

class InkwellButton extends StatelessWidget {
  const InkwellButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.width,
    required this.height,
  });

  final String text;
  final void Function()? onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return BessRoundedContainer(
      width: width,
      height: height,
      onTap: onTap,
      backgroundColor: BessColors.element1,
      child: Center(
        child: Text(
          text,
          style: BessTextStyles.standard,
        ),
      ),
    );
  }
}