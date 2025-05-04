import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ImportCsv extends StatelessWidget {
  const ImportCsv({super.key, required this.popoverController});

  final ShadPopoverController popoverController;

  @override
  Widget build(BuildContext context) {
    final textTheme = ShadTheme.of(context).textTheme;
    return ShadPopover(
      controller: popoverController,
      popover: (context) => SizedBox(
        width: 288,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Dimensions',
              style: textTheme.h4,
            ),
            Text(
              'Set the dimensions for the layer.',
              style: textTheme.p,
            ),
          ],
        ),
      ),
      child: ShadButton.outline(
        onPressed: popoverController.toggle,
        child: const Text('Open popover'),
      ),
    );
  }
}
