import 'package:flutter/material.dart';

import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/containers/rounded_container.dart';

class CardButton extends StatelessWidget {
  const CardButton({
    super.key,
    required this.title,
    this.subtitle,
    required this.height,
    this.width,
    required this.onTap,
  });


  final String title;
  final String? subtitle;
  final double? height;
  final double? width;
  final Function()? onTap;



  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: BessRoundedContainer(
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