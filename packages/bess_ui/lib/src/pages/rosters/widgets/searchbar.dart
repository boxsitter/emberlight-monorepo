import 'package:bess_ui/src/common/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

import '../../../common/constants/colors.dart';
import '../../../common/constants/sizes.dart';
import '../../../common/styles/text_styles.dart';

class searchbar extends StatelessWidget {
  const searchbar({
    super.key,
    required this.onSearchChange,
    required this.noMatches,
  });

  final void Function(String p1) onSearchChange;
  final bool noMatches;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 38,
      child: TextField(
        onChanged: onSearchChange,
        style: BessTextStyles.standard,
        decoration: InputDecoration(
          hintText: 'Search names...',
          prefixIcon: Icon(Icons.search, size: 18, color: !noMatches ? BessColors.textPrimary : BessColors.red),
          contentPadding: const EdgeInsets.symmetric(horizontal: BessSizes.md),
          filled: true,
          fillColor: !noMatches ? BessColors.crust : BessHelperFunctions.blendColors(BessColors.core, BessColors.red, 30),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(90),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(90),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(90),
            borderSide: BorderSide(color: !noMatches ? BessColors.primary : BessColors.red),
          ),
        ),
      ),
    );
  }
}
