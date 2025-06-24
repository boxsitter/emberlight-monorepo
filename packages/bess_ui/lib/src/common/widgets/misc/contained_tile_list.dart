import 'package:bess_ui/src/common/widgets/containers/rounded_container.dart';
import 'package:ember_core/ember_core_models.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../styles/text_styles.dart';

class ContainedTileList extends StatelessWidget {
  const ContainedTileList({
    super.key,
    this.leadingBuilder,
    this.trailingBuilder,
    required this.items,
    required this.width,
    this.height,
    required this.title,
    required this.headerTrailingWidget,
  });

  final String title;
  final double width;
  final double? height;
  final Widget? Function(Titled item)? leadingBuilder;
  final Widget? Function(Titled item)? trailingBuilder;
  final List<Titled> items;
  final Widget headerTrailingWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: BessSizes.xl,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: BessTextStyles.tableHeaderSecondary),
              headerTrailingWidget,
            ],
          ),
        ),
        const SizedBox(height: BessSizes.sm),
        BessRoundedContainer(
          width: width,
          height: height,
          clipContent: true,
          showBorder: true,
          padding: const EdgeInsets.symmetric(vertical: BessSizes.sm),
          // Replaced ReorderableListView with a standard ListView builder
          // to create a static list.
          child: ListView.builder(
            // shrinkWrap allows the ListView to size itself to its content,
            // which is essential inside another scrolling view or a Column.
            shrinkWrap: true,
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
          ),
        ),
      ],
    );
  }
}
