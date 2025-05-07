import 'package:bess_ui/src/common/constants/colors.dart';
import 'package:bess_ui/src/common/styles/text_styles.dart';
import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:bess_ui/src/common/widgets/context_switcher/context_switcher.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ContextDisplay extends StatelessWidget {
  const ContextDisplay({
    super.key,
    required this.top,
    required this.bottom,
  });

  final String top;
  final String bottom;

  @override
  Widget build(BuildContext context) {
    return BessRoundedContainer(
      backgroundColor: BessColors.crust,
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      height: 55,
      onTap: () => showContextSwitcher(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                top,
                style: BessTextStyles.tiny,
              ),
              Text(
                bottom,
                style: BessTextStyles.standardBold,
              )
            ],
          ),

          SizedBox(width: 15),

          const Icon(LucideIcons.folderCog),
        ],
      ),
    );
  }
}
