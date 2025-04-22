import 'package:flutter/material.dart';

import '../../../common/constants/colors.dart';
import '../../../common/constants/sizes.dart';
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
  });


  final String title;
  final double? height;
  final double? width;
  final Function()? onTap;
  final bool isSelected;



  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: BessRoundedContainer(
          showBorder: true,
          borderThickness: isSelected ? 0 : 1,
          height: height,
          width: width,
          clipContent: false,
          onTap: onTap,
          showShadow: true,
          backgroundColor: isSelected ? BessColors.primary : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: isSelected ? BessTextStyles.standardInverted : BessTextStyles.standard,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}