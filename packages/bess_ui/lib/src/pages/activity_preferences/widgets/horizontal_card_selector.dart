import 'package:flutter/material.dart';

import '../../../common/constants/sizes.dart';
import 'small_card_button.dart';

class HorizontalCardSelector extends StatelessWidget {
  const HorizontalCardSelector({
    super.key,
    required this.itemIdsToNames,
    required this.selectedId,
    required this.completedIds,
    required this.selectItem,
    this.cardHeight = 35,
    this.cardWidth = 120,
    this.maxLines = 2,
  });

  final Map<String, String> itemIdsToNames;
  final String? selectedId;
  final Set<String> completedIds;
  final void Function(String, String) selectItem;

  final double? cardHeight;
  final double? cardWidth;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: itemIdsToNames.keys.map((camperId) {
          final name = itemIdsToNames[camperId] ?? 'Unknown';
          final bool isSelected = selectedId == camperId;
          final bool isCompleted = completedIds.contains(camperId);

          return Padding(
            padding: EdgeInsets.symmetric(vertical: BessSizes.spaceBtwItems, horizontal: BessSizes.spaceBtwItems / 2),
            child: SmallCardButton(
              title: name,
              height: cardHeight,
              width: cardWidth,
              isSelected: isSelected,
              isCompleted: isCompleted,
              onTap: () => selectItem(camperId, name),
              maxLines: maxLines,
            ),
          );
        }).toList(),
      ),
    );
  }
}
