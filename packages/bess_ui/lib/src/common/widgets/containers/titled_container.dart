import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:flutter/material.dart';
import '../../constants/sizes.dart';
import '../../styles/text_styles.dart';

class TitledContainer extends StatelessWidget {
  const TitledContainer({
    super.key,
    required this.title,
    this.width,
    this.height,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(8),
  });

  final String title;
  final double? width;
  final double? height;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          child: Row(
            children: [
              Text(title, style: BessTextStyles.tableHeaderSecondary),
              if (trailing != null)
                Spacer(),
              if (trailing != null)
                trailing!,
            ],
          ),
          height: 40,
          width: width,
        ),
        Expanded(
          child: BessRoundedContainer(
            width: width,
            height: height,
            padding: padding,
            clipContent: true,
            showBorder: true,
            child: child,
          ),
        ),
      ],
    );
  }
}
