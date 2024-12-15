import 'package:bessie/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../styles/spacing_styles.dart';

class BessCenterBox extends StatelessWidget {
  const BessCenterBox({super.key, required this.child,});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 550,
        child: SingleChildScrollView(
          child: Container(
            padding: BessSpacingStyle.paddingWithAppBarHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(BessSizes.cardRadiusLg),
              color: BessHelperFunctions.isDarkMode(context) ? BessColors.black : BessColors.white,
            ),
            child: child,
            ),
          ),
        ),
    );
  }
}