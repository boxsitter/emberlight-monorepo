import 'package:bess_ui/src/common/constants/colors.dart';
import 'package:bess_ui/src/common/styles/text_styles.dart';
import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:flutter/material.dart';

import '../../constants/sizes.dart';

class InkwellButton extends StatelessWidget {
  const InkwellButton({
    super.key,
    this.text,
    required this.onTap,
    this.width,
    this.height,
    this.child,
    this.radius,
    this.padding,
  });

  final String? text;
  final void Function()? onTap;
  final double? width;
  final double? height;
  final Widget? child;
  final double? radius;
  final EdgeInsets? padding;

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
      padding: padding ?? EdgeInsets.all(BessSizes.md),
      backgroundColor: BessColors.element1,
      radius: radius ?? BessSizes.cardRadiusLg,
      child: Center(
        child: getChild(),
      ),
    );
  }
}