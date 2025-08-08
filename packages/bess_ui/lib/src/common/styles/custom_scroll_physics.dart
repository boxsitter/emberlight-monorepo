import 'package:bess_ui/src/common/constants/motion.dart';
import 'package:flutter/material.dart';

/// A custom scroll physics that allows for snapping and less momentum.
class CustomScrollPhysics extends ScrollPhysics {
  final double itemHeight;

  const CustomScrollPhysics({required this.itemHeight, super.parent});

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(parent: buildParent(ancestor), itemHeight: itemHeight);
  }

  double _getTargetPixels(ScrollMetrics position, double velocity) {
    double page = position.pixels / itemHeight;

    final tolerance = toleranceFor(position);
    if (velocity.abs() > tolerance.velocity) {
      if (velocity < -tolerance.velocity) {
        page -= BessMotion.pageSnapDelta;
      } else {
        page += BessMotion.pageSnapDelta;
      }
    }

    final double targetPixels = page.round() * itemHeight;
    return targetPixels.clamp(position.minScrollExtent, position.maxScrollExtent);
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final tolerance = toleranceFor(position);
    final double target = _getTargetPixels(position, velocity);

    if (target == position.minScrollExtent || target == position.maxScrollExtent) {
      if (velocity.abs() > tolerance.velocity) {
        return super.createBallisticSimulation(position, velocity);
      }
    }

    if ((target - position.pixels).abs() < tolerance.distance) {
      return null;
    }

          return ScrollSpringSimulation(
        SpringDescription.withDampingRatio(
          mass: BessMotion.springMass,
          stiffness: BessMotion.springStiffness,
          ratio: BessMotion.springDampingRatio,
        ),
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }

  @override
  bool get allowImplicitScrolling => true;
}