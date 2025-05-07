import 'package:flutter/material.dart';


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
    return IconButton(
      onPressed: onPressed,
      icon: icon,
      tooltip: toolTip,
    );
  }
}