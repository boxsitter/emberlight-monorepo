import 'package:flutter/material.dart';

// --- Radiance CONSTANTS ---

// -- HOVER PHASE --
/// The spread of the glow when hovering.
const double kHoverSpread = 50.0;
/// A factor to determine the initial spread of the hover glow when it starts
/// animating in. e.g., 0.8 means it starts at 80% of kHoverSpread.
const double kHoverSpreadBeginFactor = 0.7;
/// The intensity (opacity) of the glow when hovering.
const double kHoverIntensity = 0.15;
/// The duration of the fade-in/out when entering/exiting the hover state.
const Duration kHoverFadeDuration = Duration(milliseconds: 200);
/// The curve for the hover fade animation.
const Curve kHoverFadeCurve = Curves.decelerate;

// -- CLICK AND HOLD PHASE --
/// The minimum spread the glow shrinks to when held.
const double kHoldSpreadMin = 30.0;
/// The maximum intensity the glow reaches at full charge.
const double kHoldIntensityMax = 1.0;
/// The time it takes to reach full charge when holding.
const Duration kHoldChargeDuration = Duration(milliseconds: 1200);
/// The time it takes for the glow to shrink to its minimum size when a hold begins.
const Duration kHoldScaleDownDuration = Duration(milliseconds: 1200);

// -- QUICK CLICK PHASE --
/// If a click is released within this duration, it's a "quick click".
const Duration kQuickClickThreshold = Duration(milliseconds: 250);
/// The duration of the morph animation to the quick burst's start state.
const Duration kQuickClickMorphDuration = Duration(milliseconds: 0);
/// The starting spread of the quick click burst (after the morph).
const double kQuickClickStartSpread = 35.0;
/// The starting intensity of the quick click burst (after the morph).
const double kQuickClickStartIntensity = 0.35;
/// The final spread of the quick click burst.
const double kQuickClickEndSpread = 150.0;
/// The duration of the final quick click burst animation.
const Duration kQuickClickBurstDuration = Duration(milliseconds: 450);

// -- CHARGED RELEASE AFTER HOLDING PHASE --
/// The base maximum spread of the release burst (at zero charge).
const double kReleaseSpreadMax = 150.0;
/// The base lifespan of the release burst (at zero charge).
const Duration kReleaseLifespan = Duration(milliseconds: 450);
/// The curve for the release burst's fade-out animation.
const Curve kReleaseFadeOutCurve = Curves.decelerate;
/// How much extra spread the burst gets at full charge.
const double kChargedReleaseSpreadBonus = 50.0;
/// How much extra lifespan the burst gets at full charge.
const Duration kChargedReleaseLifespanBonus = Duration(milliseconds: 400);

// -- RELEASE RECOVERY PHASE --
/// The fade-in duration for the hover glow after a release burst.
const Duration kRecoveryFadeInDuration = Duration(milliseconds: 200);

// -- EXIT TRAVEL PHASE --
/// The duration of the exit travel animation.
const Duration kExitTravelDuration = Duration(milliseconds: 250);
/// The distance the glow travels off-screen.
const double kExitTravelDistance = 100.0;
/// The curve for the exit travel animation.
const Curve kExitTravelCurve = Curves.linear;

// -- MISC --
/// The blend mode for the effect, creating an additive glow.
const BlendMode kRadianceBlendMode = BlendMode.plus;