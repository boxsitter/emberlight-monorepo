import 'package:ember_core/ember_core_models.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../styles/text_styles.dart';

class VerticalListReorderer extends StatelessWidget {
  const VerticalListReorderer({
    super.key,
    this.trailingBuilder,
    required this.items,
    required this.onReorder,
  });

  final Widget? Function(Titled item)? trailingBuilder;
  final List<Titled> items;
  final Function(int, int) onReorder;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      buildDefaultDragHandles: false, // Use custom drag handles
      onReorder: onReorder,
      children: items.map((Titled field) {
        return ListTile(
          key: ValueKey(field),
          dense: true,
          title: Text(field.title, style: BessTextStyles.standard),
          leading: ReorderableDragStartListener(
            index: items.indexOf(field),
            child: MouseRegion(cursor: SystemMouseCursors.grab, child: const Icon(LucideIcons.gripVertical)),
          ),
          trailing: trailingBuilder?.call(field),
        );
      }).toList(),
    );
  }
}