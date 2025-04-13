import 'package:flutter/material.dart';
// Make sure these paths are correct for your project structure
import '../../constants/colors.dart';
import '../../constants/sizes.dart';

/// A container widget with rounded corners and customizable properties.
class BessRoundedContainer extends StatelessWidget {
  final Widget? child;
  final double radius;
  final double? width;
  final double? height;
  final bool showBorder;
  final bool showShadow;
  final Color? borderColor;
  final EdgeInsets? margin;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final void Function()? onTap;
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
    this.padding = const EdgeInsets.all(BessSizes.md),
    this.borderColor,
    this.radius = BessSizes.cardRadiusLg,
    this.backgroundColor,
    this.onTap,
    this.borderThickness = BessSizes.borderThicknessSm,
    this.clipContent = true,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Define the shape (handles radius and border)
    final ShapeBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: showBorder // Apply border directly as part of the shape
          ? BorderSide(
        color: borderColor ?? BessColors.borderPrimary,
        width: borderThickness * 2,
        strokeAlign: 0,
      )
          : BorderSide.none,
    );

    // 2. Use Material for background, elevation, shape, and clipping
    Widget content = Material(
      shape: shape, // Use the defined shape
      color: backgroundColor ?? BessColors.core,
      elevation: showShadow ? 5.0 : 0.0, // Standard elevation value
      clipBehavior: clipContent ? Clip.antiAlias : Clip.none, // Handles clipping
      child: InkWell( // InkWell sits inside the Material shape
        onTap: onTap,
        customBorder: shape, // Let InkWell use the Material's shape for ripple effect boundary
        splashColor: BessColors.primary.withAlpha(35),
        child: Padding( // Padding is inside the InkWell
          padding: padding,
          child: SizedBox( // SizedBox applies optional explicit width/height
            width: width,
            height: height,
            child: child, // Your actual content goes here
          ),
        ),
      ),
    );

    // 3. Apply margin if specified (outside the Material widget)
    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    // 4. Return the final content (No separate CustomPaint needed)
    return content;
  }
}