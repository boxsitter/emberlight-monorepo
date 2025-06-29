import 'package:bess_ui/src/common/utils/helpers/helper_functions.dart';
import 'package:bess_ui/src/common/widgets/wrappers/buttonize.dart';
import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../styles/text_styles.dart';
import '../containers/rounded_container.dart';
import '../wrappers/tint.dart';

/// A flexible, interactive card component that darkens on hover.
///
/// This widget is a "dumb" component, meaning its appearance is configured
/// entirely by the properties passed to it. The parent widget is responsible
/// for determining the style (e.g., colors) based on application state.
class CardButton extends StatelessWidget {
  const CardButton({
    super.key,
    required this.child,
    this.onTap,
    this.height,
    this.width,
    this.backgroundColor,
    this.borderColor,
    this.borderThickness = 2,
    this.radius,
    this.padding,
    this.showBorder = true,
    this.baseTint,
    this.tintStates,
  });

  /// The content displayed inside the card.
  final Widget child;

  /// The callback that is executed when the card is tapped.
  final VoidCallback? onTap;

  /// The height of the card.
  final double? height;

  /// The width of the card.
  final double? width;

  /// The background color of the card.
  final Color? backgroundColor;

  /// The border color of the card. If null, no border is shown.
  final Color? borderColor;

  /// The thickness of the border.
  final double borderThickness;

  final double? radius;

  final EdgeInsets? padding;

  final bool showBorder;

  final Color? baseTint;

  final List<TintState>? tintStates;

  @override
  Widget build(BuildContext context) {
    if (onTap != null) {
      return Buttonize(
        onTap: onTap!,
        baseBackgroundColor: backgroundColor,
        baseBorderColor: borderColor,
        baseForegroundColor: BessColors.textPrimary,
        tintStates: tintStates,
        tint: baseTint,
        borderRadius: BorderRadius.circular(radius ?? BessSizes.cardRadiusLg),
        child: BessRoundedContainer(
          height: height,
          width: width,
          borderThickness: borderThickness,
          padding: padding ?? EdgeInsets.all(8),
          radius: radius,
          showBorder: showBorder,
          showShadow: false,
          clipContent: false,
          child: child,
        ),
      );
    } else {
      return Tint(
        tint: BessColors.overlay1,
        darken: true,
        child: BessRoundedContainer(
          height: height,
          width: width,
          borderThickness: borderThickness,
          padding: padding ?? EdgeInsets.all(8),
          radius: radius,
          showBorder: showBorder,
          showShadow: false,
          clipContent: false,
          child: child,
        ),
      );
    }
  }
}
