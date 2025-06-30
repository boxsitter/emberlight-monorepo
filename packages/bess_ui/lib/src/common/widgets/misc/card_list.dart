import 'package:ember_core/ember_core.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../styles/text_styles.dart';

class CardList<T extends Titled> extends StatelessWidget {
  const CardList({
    super.key,
    this.leadingBuilder,
    this.trailingBuilder,
    required this.items,
  });

  final Widget? Function(T item)? leadingBuilder;
  final Widget? Function(T item)? trailingBuilder;
  final List<T> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          tileColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BessSizes.cardRadiusLg),
            side: BorderSide.none,
          ),
          key: ValueKey(item),
          // Because T is guaranteed to extend Titled, you can directly access displayTitle.
          title: Text(item.displayTitle, style: BessTextStyles.standard),
          leading: leadingBuilder?.call(item),
          trailing: trailingBuilder?.call(item),
        );
      },
    );
  }
}
