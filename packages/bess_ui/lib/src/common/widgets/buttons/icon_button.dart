import 'package:bess_ui/src/common/widgets/buttons/card_button.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../wrappers/tint.dart';

class BessIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool? selected;
  final bool enabled;
  final IconData iconData;
  final double? size;
  final double? margin;

  const BessIconButton({
    super.key,
    this.onPressed,
    this.selected,
    this.enabled = true,
    required this.iconData,
    this.size,
    this.margin = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final Widget widget = Padding(
      padding: margin != null ? EdgeInsets.all(margin!) : EdgeInsets.zero,
      child: CardButton(
        width: size,
        height: size,
        onPressed: onPressed,
        tintStates: [(selected == true, BessColors.primary)],
        showBorder: selected == true,
        borderThickness: 2,
        radius: 16,
        padding: EdgeInsets.zero,
        backgroundColor: BessColors.core,
        borderColor: BessColors.textPrimary,
        enabled: enabled,
        child: Center(
          child: Builder(builder: (context) {
            return Icon(iconData, color: Tint.of(context) != null ? Tint.of(context)?.foregroundColor : BessColors.textPrimary);
          }),
        ),
      ),
    );

    if (size == null) {
      return AspectRatio(
        aspectRatio: 1.0,
        child: widget,
      );
    } else {
      return widget;
    }
  }
}
