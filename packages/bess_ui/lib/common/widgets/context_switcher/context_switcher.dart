import 'package:flutter/cupertino.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final profile = [
  (title: 'Name', value: 'Alexandru'),
  (title: 'Username', value: 'nank1ro'),
];

class ContextSwitcher extends StatelessWidget {
  const ContextSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadButton.outline(
      child: const Text('Edit Profile'),
      onPressed: () {
        showShadDialog(
          context: context,
          builder: (context) => ShadDialog(
            title: const Text('Edit Profile'),
            description: const Text(
                "Make changes to your profile here. Click save when you're done"),
            actions: const [ShadButton(child: Text('Save changes'))],
            child: Container(
              width: 375,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: profile
                    .map(
                      (p) => Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.title,
                          textAlign: TextAlign.end,
                          style: theme.textTheme.small,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: ShadInput(initialValue: p.value),
                      ),
                    ],
                  ),
                )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}