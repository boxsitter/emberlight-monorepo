import 'dart:ui';

import 'package:bess_ui/src/common/widgets/containers/titled_container.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../common/styles/text_styles.dart';
import '../../../common/widgets/containers/rounded_container.dart';
import '../controllers/activity_preferences_controller.dart';

class ActivityReorderableGrid extends StatelessWidget {
  const ActivityReorderableGrid({
    super.key,
    required this.orderedItemIds,
    required this.displayInfo,
    required this.itemIdsToNames,
    required this.onReorder,
    required this.title,
  });

  final List<String> orderedItemIds;
  final Map<String, String> itemIdsToNames;
  final void Function(String) displayInfo;
  final void Function(int, int) onReorder;

  final String title;

  @override
  Widget build(BuildContext context) {
    return TitledContainer(
      title: title,
      child: ReorderableGridView.builder(
        // These two lines are the important change!
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        dragEnabled: true,

        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          mainAxisExtent: 60,
          maxCrossAxisExtent: 450,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: orderedItemIds.length,
        itemBuilder: (context, index) {
          final activityId = orderedItemIds[index];
          final activityName = itemIdsToNames[activityId] ?? 'Unknown Activity';

          return BessRoundedContainer(
              key: ValueKey(activityId), // Key is crucial for reordering.
              borderThickness: 2,
              showBorder: true,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '#${index + 1}    $activityName',
                      style: BessTextStyles.standard,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.info),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => displayInfo(activityId),
                  ),
                  const SizedBox(width: 8),
                  MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(LucideIcons.gripVertical),
                    ),
                  ),
                ],
              ),
          );
        },
        dragWidgetBuilderV2: DragWidgetBuilderV2(
          isScreenshotDragWidget: false,
          builder: (index, child, screenshot) {
          return Material(
            color: Colors.transparent,
            child: child,
          );
        },
        ),
        onReorder: onReorder,
      ),
    );
  }
}
