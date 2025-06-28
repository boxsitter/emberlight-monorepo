import 'dart:ui';
import 'package:bess_ui/src/common/widgets/wrappers/radiance_new/radiance_consts_new.dart';
import 'package:flutter/material.dart';

import '../../effects/radiance/radiance.dart';

enum _ExitDirection { top, right, bottom, left }

class RadianceRipple extends StatefulWidget {
  const RadianceRipple({
    super.key,
    required this.child,
    required this.isHeld,
    required this.isHovering,
    required this.tapPositionNotifier,
    this.borderRadius = BorderRadius.zero,
    this.color,
  });

  final Widget child;
  final bool isHeld;
  final bool isHovering;
  final ValueNotifier<Offset?> tapPositionNotifier;
  final BorderRadius borderRadius;
  final Color? color;

  @override
  State<RadianceRipple> createState() => _RadianceRippleState();
}

class _RadianceRippleState extends State<RadianceRipple> with TickerProviderStateMixin {
  late final AnimationController _hoverController;
  late final AnimationController _releaseController;
  late final AnimationController _holdController;
  late final AnimationController _exitTravelController;

  late Animation<double> _hoverIntensityAnimation;
  late Animation<double> _hoverSpreadAnimation;
  late Animation<double> _releaseSpreadAnimation;
  late Animation<double> _releaseIntensityAnimation;
  late Animation<Offset> _exitTravelAnimation;

  final GlobalKey _widgetKey = GlobalKey();
  Offset? _lastPosition;
  Offset? _releasePosition;
  Size? _widgetSize;
  double _charge = 0.0;
  DateTime? _holdStartTime;
  bool _isQuickBurst = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(vsync: this, duration: kHoverFadeDuration);
    _hoverIntensityAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: kHoverFadeCurve,
    ).drive(Tween<double>(begin: 0.0, end: kHoverIntensity));
    _hoverSpreadAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: kHoverFadeCurve,
    ).drive(Tween<double>(begin: kHoverSpread * kHoverSpreadBeginFactor, end: kHoverSpread));

    _releaseController = AnimationController(vsync: this, duration: kReleaseLifespan);
    _releaseSpreadAnimation = Tween<double>(begin: 0, end: 0).animate(_releaseController);
    _releaseIntensityAnimation = Tween<double>(begin: 0, end: 0).animate(_releaseController);
    _releaseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_isQuickBurst) {
          _isQuickBurst = false;
          _triggerQuickReleaseBurst();
        } else if (widget.isHovering) {
          _hoverController.duration = kRecoveryFadeInDuration;
          _hoverController.forward(from: 0.0);
          _hoverController.duration = kHoverFadeDuration;
        }
      }
    });

    _holdController = AnimationController(vsync: this, duration: kHoldChargeDuration);

    _exitTravelController = AnimationController(vsync: this, duration: kExitTravelDuration);
    _exitTravelAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_exitTravelController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final context = _widgetKey.currentContext;
      if (context != null) {
        final renderBox = context.findRenderObject() as RenderBox;
        if (renderBox.hasSize) {
          _widgetSize = renderBox.size;
        }
      }
    });
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _releaseController.dispose();
    _holdController.dispose();
    _exitTravelController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RadianceRipple oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isHovering != oldWidget.isHovering) {
      if (widget.isHovering) {
        _exitTravelController.stop();
        if (!widget.isHeld) {
          _hoverController.forward();
        }
      } else {
        _triggerExitAnimation();
      }
    }

    if (widget.isHeld != oldWidget.isHeld) {
      if (widget.isHeld) {
        _holdStartTime = DateTime.now();
        _releaseController.stop();
        _hoverController.reverse();
        _holdController.forward(from: 0.0);
      } else {
        final holdDuration = DateTime.now().difference(_holdStartTime!);
        _charge = _holdController.value;
        _holdController.reset();

        if (widget.isHovering) {
          if (holdDuration < kQuickClickThreshold) {
            _isQuickBurst = true;
            _triggerQuickReleaseMorph();
          } else {
            _triggerChargedRelease();
          }
        } else {
          _triggerCancelAnimation();
        }
      }
    }
  }

  void _triggerExitAnimation() {
    if (_lastPosition == null || _widgetSize == null) return;

    _hoverController.reverse();

    final center = _widgetSize!.center(Offset.zero);
    final exitVector = _lastPosition! - center;

    _ExitDirection direction;
    if (exitVector.dx.abs() > exitVector.dy.abs()) {
      direction = exitVector.dx > 0 ? _ExitDirection.right : _ExitDirection.left;
    } else {
      direction = exitVector.dy > 0 ? _ExitDirection.bottom : _ExitDirection.top;
    }

    Offset targetPosition;
    switch (direction) {
      case _ExitDirection.top:
        targetPosition = Offset(_lastPosition!.dx, _lastPosition!.dy - kExitTravelDistance);
        break;
      case _ExitDirection.right:
        targetPosition = Offset(_lastPosition!.dx + kExitTravelDistance, _lastPosition!.dy);
        break;
      case _ExitDirection.bottom:
        targetPosition = Offset(_lastPosition!.dx, _lastPosition!.dy + kExitTravelDistance);
        break;
      case _ExitDirection.left:
        targetPosition = Offset(_lastPosition!.dx - kExitTravelDistance, _lastPosition!.dy);
        break;
    }

    _exitTravelAnimation = CurvedAnimation(parent: _exitTravelController, curve: kExitTravelCurve)
        .drive(Tween<Offset>(begin: _lastPosition, end: targetPosition));

    _exitTravelController.forward(from: 0.0);
  }

  void _triggerChargedRelease() {
    _releasePosition = _lastPosition;
    if (_releasePosition == null) return;

    final chargedSpread = lerpDouble(kReleaseSpreadMax, kReleaseSpreadMax + kChargedReleaseSpreadBonus, _charge)!;
    final chargedLifespan = Duration(
        milliseconds: lerpDouble(kReleaseLifespan.inMilliseconds,
                kReleaseLifespan.inMilliseconds + kChargedReleaseLifespanBonus.inMilliseconds, _charge)!
            .toInt());
    final initialIntensity = lerpDouble(kHoverIntensity, kHoldIntensityMax, _charge)!;
    final initialSpread = lerpDouble(kHoverSpread, kHoldSpreadMin, _charge)!;

    _releaseController.duration = chargedLifespan;

    _releaseSpreadAnimation = CurvedAnimation(parent: _releaseController, curve: Curves.easeOut)
        .drive(Tween<double>(begin: initialSpread, end: chargedSpread));
    _releaseIntensityAnimation = CurvedAnimation(parent: _releaseController, curve: kReleaseFadeOutCurve)
        .drive(Tween<double>(begin: initialIntensity, end: 0.0));

    _releaseController.forward(from: 0.0);
  }

  void _triggerQuickReleaseMorph() {
    _releasePosition = _lastPosition;
    if (_releasePosition == null) return;

    final scaleDownProgress =
        (_charge * kHoldChargeDuration.inMilliseconds / kHoldScaleDownDuration.inMilliseconds).clamp(0.0, 1.0);
    final initialSpread = lerpDouble(kHoverSpread, kHoldSpreadMin, scaleDownProgress)!;
    final initialIntensity = lerpDouble(kHoverIntensity, kHoldIntensityMax, _charge)!;

    _releaseController.duration = kQuickClickMorphDuration;

    _releaseSpreadAnimation = CurvedAnimation(parent: _releaseController, curve: Curves.easeOut)
        .drive(Tween<double>(begin: initialSpread, end: kQuickClickStartSpread));
    _releaseIntensityAnimation = CurvedAnimation(parent: _releaseController, curve: Curves.easeOut)
        .drive(Tween<double>(begin: initialIntensity, end: kQuickClickStartIntensity));

    _releaseController.forward(from: 0.0);
  }

  void _triggerQuickReleaseBurst() {
    _releaseController.duration = kQuickClickBurstDuration;

    _releaseSpreadAnimation = CurvedAnimation(parent: _releaseController, curve: Curves.easeOut)
        .drive(Tween<double>(begin: kQuickClickStartSpread, end: kQuickClickEndSpread));
    _releaseIntensityAnimation = CurvedAnimation(parent: _releaseController, curve: kReleaseFadeOutCurve)
        .drive(Tween<double>(begin: kQuickClickStartIntensity, end: 0.0));

    _releaseController.forward(from: 0.0);
  }

  void _triggerCancelAnimation() {
    _releasePosition = _lastPosition;
    if (_releasePosition == null) return;

    final scaleDownProgress =
        (_charge * kHoldChargeDuration.inMilliseconds / kHoldScaleDownDuration.inMilliseconds).clamp(0.0, 1.0);
    final initialSpread = lerpDouble(kHoverSpread, kHoldSpreadMin, scaleDownProgress)!;
    final initialIntensity = lerpDouble(kHoverIntensity, kHoldIntensityMax, _charge)!;

    _releaseController.duration = const Duration(milliseconds: 150);

    _releaseSpreadAnimation = CurvedAnimation(parent: _releaseController, curve: Curves.easeOut)
        .drive(Tween<double>(begin: initialSpread, end: initialSpread * 0.8));
    _releaseIntensityAnimation = CurvedAnimation(parent: _releaseController, curve: Curves.easeOut)
        .drive(Tween<double>(begin: initialIntensity, end: 0.0));

    _releaseController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: _widgetKey,
      borderRadius: widget.borderRadius,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _hoverController,
                _releaseController,
                _holdController,
                _exitTravelController,
                widget.tapPositionNotifier,
              ]),
              builder: (context, child) {
                final currentPosition = widget.tapPositionNotifier.value;
                if (currentPosition != null) {
                  _lastPosition = currentPosition;
                }

                final bool isExiting = _exitTravelController.isAnimating;
                final paintPosition = isExiting ? _exitTravelAnimation.value : _lastPosition;

                final bool isReleasing = _releaseController.isAnimating;

                final bool shouldPaint = widget.isHovering ||
                    widget.isHeld ||
                    _hoverController.isAnimating ||
                    _holdController.isAnimating ||
                    isReleasing ||
                    isExiting;

                if (!shouldPaint || (paintPosition == null && !isReleasing)) {
                  return const SizedBox.shrink();
                }

                // Determine the radiance properties based on the current state
                double intensity = 0.0;
                double spread = 0.0;
                Offset? position = paintPosition;
                Path path = Path();

                if (widget.isHeld && position != null) {
                  final scaleDownProgress =
                      (_holdController.value * kHoldChargeDuration.inMilliseconds / kHoldScaleDownDuration.inMilliseconds)
                          .clamp(0.0, 1.0);
                  spread = lerpDouble(kHoverSpread, kHoldSpreadMin, scaleDownProgress)!;
                  intensity = lerpDouble(kHoverIntensity, kHoldIntensityMax, _holdController.value)!;
                  path.addOval(Rect.fromCircle(center: position, radius: spread));
                } else if (isReleasing && _releasePosition != null) {
                  intensity = _releaseIntensityAnimation.value;
                  spread = _releaseSpreadAnimation.value;
                  path.addOval(Rect.fromCircle(center: _releasePosition!, radius: spread));
                } else if ((widget.isHovering || _hoverController.isAnimating || isExiting) && position != null) {
                  intensity = _hoverIntensityAnimation.value;
                  spread = _hoverSpreadAnimation.value;
                  path.addOval(Rect.fromCircle(center: position, radius: spread));
                }

                return Radiance(
                  shapePath: path,
                  intensity: intensity,
                  spread: spread,
                  color: widget.color ?? Colors.white,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
