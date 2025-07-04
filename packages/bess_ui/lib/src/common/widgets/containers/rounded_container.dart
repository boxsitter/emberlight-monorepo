import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../wrappers/tint.dart';

// Note: No longer implements Tintable
class BessRoundedContainer extends StatelessWidget {
  final Widget? child;
  final double? radius;
  final double? width;
  final double? height;
  final bool showBorder;
  final bool showShadow;
  final Color? borderColor;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double borderThickness;
  final bool clipContent;

  const BessRoundedContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.margin,
    this.showShadow = false,
    this.showBorder = false,
    this.padding,
    this.borderColor,
    this.radius,
    this.backgroundColor,
    this.borderThickness = BessSizes.borderThicknessSm,
    this.clipContent = true,
  });

  @override
  Widget build(BuildContext context) {
    // Look up the tree for tint information using the public static method.
    final tintInfo = Tint.of(context);

    // Use tint colors if available, otherwise fall back to the widget's
    // own properties, and finally to the hardcoded defaults.
    final effectiveBackgroundColor = tintInfo?.backgroundColor ?? backgroundColor ?? BessColors.core;
    final effectiveBorderColor = tintInfo?.borderColor ?? borderColor ?? BessColors.borderPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1),
      curve: Curves.easeOut,
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(BessSizes.md),
      clipBehavior: clipContent ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(radius ?? BessSizes.cardRadiusLg),
        border: showBorder
            ? Border.all(
                color: effectiveBorderColor,
                width: borderThickness,
              )
            : null,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: BessColors.shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
