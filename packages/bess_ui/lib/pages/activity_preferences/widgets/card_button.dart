import 'package:bess_ui/common/constants/sizes.dart';
import 'package:flutter/material.dart';

import '../../../common/constants/colors.dart';
import '../../../common/styles/text_styles.dart';
import '../../../common/utils/helpers/helper_functions.dart';
import '../../../common/widgets/containers/rounded_container.dart';

class CardButton extends StatelessWidget {
  const CardButton({
    super.key,
    required this.title,
    this.subtitle,
    required this.height,
    this.width,
    required this.onTap,
    this.isCompleted = false,
    this.isInProgress = false,
  });


  final String title;
  final String? subtitle;
  final double? height;
  final double? width;
  final Function()? onTap;
  final bool isInProgress;
  final bool isCompleted;



  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    if (isInProgress) {
      backgroundColor = BessHelperFunctions.blendColors(BessColors.core, BessColors.yellow, 60);
    } else if (isCompleted) {
      backgroundColor = BessHelperFunctions.blendColors(BessColors.core, BessColors.green, 60);
    } else {
      backgroundColor = null;
    }

    Color? boarderColor;
    if (isInProgress) {
      boarderColor = BessHelperFunctions.blendColors(BessColors.borderPrimary, BessColors.yellow, 150);
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
          backgroundColor: backgroundColor,
          borderColor: boarderColor,
          showBorder: true,
          borderThickness: 2,
          height: height,
          width: width,
          clipContent: false,
          onTap: onTap,
          showShadow: true,
          child: Column(
            crossAxisAlignment: subtitle == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: BessTextStyles.boldCardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: BessTextStyles.largerLabel,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}