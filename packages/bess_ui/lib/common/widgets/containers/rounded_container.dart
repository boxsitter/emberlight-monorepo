import 'package:flutter/material.dart';

import '../../constants//colors.dart';
import '../../constants//sizes.dart';

/// A container widget with rounded corners and customizable properties.
class BessRoundedContainer extends StatelessWidget {
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
    this.clipContent = true, // Clipping primarily handled by Material
  });

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

  @override
  Widget build(BuildContext context) {
    Widget content = Material(
      color: backgroundColor ?? BessColors.core,
      elevation: showShadow ? 5.0 : 0.0,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: clipContent ? Clip.antiAlias : Clip.none,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        splashColor: BessColors.primary.withAlpha(35),
        child: Padding(
          padding: padding,
          child: SizedBox(
            width: width,
            height: height,
            child: child,
          ),
        ),
      ),
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (showBorder) {
      return CustomPaint(
        // *** Use foregroundPainter to draw ON TOP ***
        foregroundPainter: _BorderPainter(
          color: borderColor ?? BessColors.borderPrimary,
          thickness: borderThickness,
          radius: Radius.circular(radius),
        ),
        // painter: null, // No background painter needed
        child: content, // The Material/InkWell/Child goes here
      );
    } else {
      return content;
    }
  }
}

// Custom painter for drawing the border overlay
class _BorderPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final Radius radius;

  _BorderPainter({
    required this.color,
    required this.thickness,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke; // Only draw the stroke

    // Create a rounded rectangle path inset by half the stroke width
    // to align the border correctly with the Material's edge.
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
          thickness / 2.0, thickness / 2.0,
          size.width - thickness, size.height - thickness
      ),
      radius,
    );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint only if border properties change
    return oldDelegate is! _BorderPainter ||
        oldDelegate.color != color ||
        oldDelegate.thickness != thickness ||
        oldDelegate.radius != radius;
  }
}
