import 'package:ember_core/ember_core.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../styles/text_styles.dart';

class CardList extends StatelessWidget {
  const CardList({
    super.key,
    this.leadingBuilder,
    this.trailingBuilder,
    required this.items,
  });

  final Widget? Function(Titled item)? leadingBuilder;
  final Widget? Function(Titled item)? trailingBuilder;
  final List<Titled> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          tileColor: BessColors.core,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BessSizes.cardRadiusLg),
            side: BorderSide.none,
          ),
          key: ValueKey(item),
          title: Text(item.displayTitle, style: BessTextStyles.standard),
          // The leading widget is now provided by the new leadingBuilder.
          leading: leadingBuilder?.call(item),
          trailing: trailingBuilder?.call(item),
        );
      },
    );
  }
}
