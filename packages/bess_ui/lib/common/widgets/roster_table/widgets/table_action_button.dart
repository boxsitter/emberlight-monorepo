import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../constants/colors.dart';

class TableActionButton extends StatelessWidget {
  final void Function() onPressed;
  final Icon icon;
  final String toolTip;

  const TableActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.toolTip = '',
  });

  @override
  Widget build(BuildContext context) {
    if (toolTip.trim().isEmpty) {
      return buildShadIconButton();
    } else {
      return ShadTooltip(
        waitDuration: const Duration(milliseconds: 200),
        showDuration: const Duration(milliseconds: 200),
        builder: (context) => Text(toolTip),
        child: buildShadIconButton(),
      );
    }
  }

  ShadIconButton buildShadIconButton() {
    return ShadIconButton.secondary(
        hoverBackgroundColor: BessColors.element1,
        pressedBackgroundColor: BessColors.element3,
        height: 30,
        decoration: ShadDecoration(
            descriptionPadding: EdgeInsets.zero,
            border: ShadBorder(radius: BorderRadius.circular(100))
        ),

        icon: icon,
        onPressed: onPressed,
      );
  }
}