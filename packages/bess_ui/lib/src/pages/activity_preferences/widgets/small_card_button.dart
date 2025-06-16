import 'package:bess_ui/src/common/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

import '../../../common/constants/colors.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/containers/rounded_container.dart';

class SmallCardButton extends StatelessWidget {
  const SmallCardButton({
    super.key,
    required this.title,
    required this.height,
    this.width,
    required this.onTap,
    this.isSelected = false,
    this.isCompleted = false,
    this.maxLines = 2,
  });

  final String title;
  final double? height;
  final double? width;
  final Function()? onTap;
  final bool isSelected;
  final bool isCompleted;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    if (isSelected) {
      backgroundColor = BessColors.primary;
    } else if (isCompleted) {
      backgroundColor = BessHelperFunctions.blendColors(BessColors.core, BessColors.green, 60);
    } else {
      backgroundColor = null;
    }

    Color? boarderColor;
    if (isSelected) {
      boarderColor = BessColors.primary;
    } else if (isCompleted) {
      boarderColor = BessHelperFunctions.blendColors(BessColors.borderPrimary, BessColors.green, 150);
    } else {
      boarderColor = null;
    }


    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: BessRoundedContainer(
          showBorder: true,
          borderThickness: 1,
          borderColor: boarderColor,
          height: height,
          width: width,
          clipContent: false,
          onTap: onTap,
          showShadow: true,
          backgroundColor: backgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: isSelected ? BessTextStyles.standardInverted : BessTextStyles.standard,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}