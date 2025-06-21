import 'package:flutter/material.dart';

import '../../../../common/constants/sizes.dart';

class CheckboxCell extends StatelessWidget {
  final bool isSelected;
  final ValueChanged<bool?>? onChanged;

  const CheckboxCell({
    super.key,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 40,
      padding: const EdgeInsets.symmetric(
          horizontal: BessSizes.md, vertical: BessSizes.xs),
      child: SizedBox(
        child: Align(
          alignment: Alignment.center,
          child: Checkbox(
            value: isSelected,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}