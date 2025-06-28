import 'package:ember_core/ember_core.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../styles/text_styles.dart';
import '../buttons/card_button.dart';
import '../wrappers/tint.dart';

class CardSelector extends StatelessWidget {
  const CardSelector({
    super.key,
    required this.items,
    required this.onSelectItem,
    this.cardHeight,
    this.cardWidth,
    this.maxLines,
    this.isHorizontal = false,
    this.selectedItem,
    this.completedItems,
  });

  /// The list of items to display in the selector.
  /// Each item must implement the 'Titled' mixin.
  final List<Titled> items;
  final Titled? selectedItem;
  final Set<Titled>? completedItems;

  /// A callback function that is invoked with the selected item when a card is tapped.
  final void Function(Titled) onSelectItem;

  final double? cardHeight;
  final double? cardWidth;
  final int? maxLines;
  final bool isHorizontal;

  @override
  Widget build(BuildContext context) {
    final List<Widget> cardItems = items.map((item) {
      final bool isSelected = selectedItem == item;
      final bool isCompleted = completedItems != null ? completedItems!.contains(item) : false;

      return Padding(
        padding: isHorizontal
            ? const EdgeInsets.symmetric(horizontal: BessSizes.spaceBtwItems / 2)
            : const EdgeInsets.symmetric(vertical: 6, horizontal: BessSizes.spaceBtwItems),
        child: CardButton(
          height: cardHeight,
          width: cardWidth,
          tintStates: [(isSelected, BessColors.primary), (isCompleted, BessColors.green)],
          onTap: () => onSelectItem(item),
          padding: EdgeInsets.all(8),
          child: Center(
            child: Builder(
              builder: (BuildContext context) {
                // This 'context' is now "under" the Tint widget and can find it.
                return Text(
                  item.title,
                  style: BessTextStyles.standard.copyWith(
                    // This will now correctly find the foregroundColor provided by Tint.
                    color: Tint.of(context)?.foregroundColor,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
        ),
      );
    }).toList();

    return SingleChildScrollView(
      scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
      child: isHorizontal ? Row(children: cardItems) : Column(children: cardItems),
    );
  }
}
