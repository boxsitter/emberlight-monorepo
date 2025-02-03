import 'package:flutter/material.dart';

import '../../../../common/styles/shadows.dart';
import '../../constants//colors.dart';
import '../../constants//sizes.dart';

/// A container widget with rounded corners and customizable properties.
class BessRoundedContainer extends StatelessWidget {
  /// Create a rounded container with customizable properties.
  ///
  /// Parameters:
  ///   - width: The width of the container.
  ///   - height: The height of the container.
  ///   - radius: The border radius for the rounded corners.
  ///   - padding: The padding inside the container.
  ///   - margin: The margin around the container.
  ///   - child: The widget to be placed inside the container.
  ///   - backgroundColor: The background color of the container.
  ///   - borderColor: The color of the container's border.
  ///   - showBorder: A flag to determine if the container should have a border.
  const BessRoundedContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.margin,
    this.showShadow = true,
    this.showBorder = false,
    this.padding = const EdgeInsets.all(BessSizes.md),
    this.borderColor = BessColors.borderPrimary,
    this.radius = BessSizes.cardRadiusLg,
    this.backgroundColor = BessColors.white,
    this.onTap,
    this.borderThickness = BessSizes.borderThicknessSm,
  });

  final Widget? child;
  final double radius;
  final double? width;
  final double? height;
  final bool showBorder;
  final bool showShadow;
  final Color borderColor;
  final EdgeInsets? margin;
  final EdgeInsets padding;
  final Color backgroundColor;
  final void Function()? onTap;
  final double borderThickness;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          width: width,
          height: height,
          margin: margin,
          padding: padding,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(

            color: backgroundColor,
            borderRadius: BorderRadius.circular(radius),
            border: showBorder ? Border.all(color: borderColor, width: borderThickness) : null,
            boxShadow: [if (showShadow) BessShadowStyle.defaultBoxShadow],
          ),
          child: child),
    );
  }
}
