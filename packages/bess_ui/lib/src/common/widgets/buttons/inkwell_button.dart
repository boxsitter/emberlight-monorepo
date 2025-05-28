import 'package:bess_ui/src/common/constants/colors.dart';
import 'package:bess_ui/src/common/styles/text_styles.dart';
import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:flutter/material.dart';

class InkwellButton extends StatelessWidget {
  const InkwellButton({
    super.key,
    this.text,
    required this.onTap,
    this.width,
    this.height,
    this.child
  });

  final String? text;
  final void Function()? onTap;
  final double? width;
  final double? height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    Widget getChild() {
      if (child != null) {
        return child!;
      } else {
        return Text(
          text ?? '',
          style: BessTextStyles.standard,
        );
      }
    }

    return BessRoundedContainer(
      width: width,
      height: height,
      onTap: onTap,
      backgroundColor: BessColors.element1,
      child: Center(
        child: getChild(),
      ),
    );
  }
}