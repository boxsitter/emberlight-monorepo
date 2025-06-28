import 'package:flutter/material.dart';

/// The default blend mode for radiance effects.
const BlendMode kRadianceBlendMode = BlendMode.plus;

class Radiance extends StatelessWidget {
  const Radiance({
    super.key,
    this.child,
    required this.shapePath,
    required this.intensity,
    required this.spread,
    required this.color,
    this.blendMode = kRadianceBlendMode,
    this.clip = false,
  });

  /// The widget below this widget in the tree.
  final Widget? child;

  /// The [Path] that defines the shape of the radiance.
  final Path shapePath;

  /// The opacity of the radiance. Clamped between 0.0 and 1.0.
  final double intensity;

  /// The "spread" or blur radius of the radiance. In the context of the old
  /// painter, this is analogous to the radius.
  final double spread;

  /// The color of the radiance.
  final Color color;

  /// The [BlendMode] to use when drawing the radiance.
  final BlendMode blendMode;

  /// Whether to clip the radiance effect to the [shapePath].
  ///
  /// Defaults to `false`, allowing the glow to spread beyond the path's bounds.
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final painter = CustomPaint(
      painter: RadiancePainter(
        shapePath: shapePath,
        intensity: intensity,
        spread: spread,
        color: color,
        blendMode: blendMode,
      ),
      child: child,
    );

    if (clip) {
      return ClipPath(
        clipper: _PathClipper(shapePath),
        child: painter,
      );
    }

    return painter;
  }
}

/// A [CustomPainter] that draws the radiance effect.
class RadiancePainter extends CustomPainter {
  const RadiancePainter({
    required this.shapePath,
    required this.intensity,
    required this.spread,
    required this.color,
    required this.blendMode,
  });

  final Path shapePath;
  final double intensity;
  final double spread;
  final Color color;
  final BlendMode blendMode;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0.0 || spread <= 0.0) {
      return;
    }

    final paint = Paint()
      ..color = color.withOpacity(intensity.clamp(0.0, 1.0))
      // This replicates the old painter's logic where the blur sigma
      // was 75% of the radius. Here, 'spread' is used as the radius.
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, spread * 0.75)
      ..blendMode = blendMode;

    canvas.drawPath(shapePath, paint);
  }

  @override
  bool shouldRepaint(covariant RadiancePainter oldDelegate) {
    return oldDelegate.shapePath != shapePath ||
        oldDelegate.intensity != intensity ||
        oldDelegate.spread != spread ||
        oldDelegate.color != color ||
        oldDelegate.blendMode != blendMode;
  }
}

/// A custom clipper that uses a path to define the clip area.
class _PathClipper extends CustomClipper<Path> {
  const _PathClipper(this.path);

  final Path path;

  @override
  Path getClip(Size size) => path;

  @override
  bool shouldReclip(covariant _PathClipper oldClipper) => oldClipper.path != path;
}
