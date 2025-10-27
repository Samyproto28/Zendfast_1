import 'package:flutter/material.dart';

/// Zendfast animation system
/// Provides consistent animation durations and curves throughout the application
class ZendfastAnimations {
  // Private constructor to prevent instantiation
  ZendfastAnimations._();

  // Animation Durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 700);

  // Animation Curves
  static const Curve standardCurve = Curves.easeInOut;
  static const Curve decelerateCurve = Curves.easeOut;
  static const Curve accelerateCurve = Curves.easeIn;
  static const Curve emphasizedCurve = Curves.easeInOutCubic;
  static const Curve emphasizedDecelerateCurve = Curves.easeOutCubic;
  static const Curve emphasizedAccelerateCurve = Curves.easeInCubic;

  // Common Transitions

  /// Fade transition with standard duration and curve
  static Widget fadeIn({
    required Widget child,
    Duration duration = standard,
    Curve curve = standardCurve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Scale transition with standard duration and curve
  static Widget scaleIn({
    required Widget child,
    Duration duration = standard,
    Curve curve = emphasizedCurve,
    double begin = 0.8,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Slide transition with standard duration and curve
  static Widget slideIn({
    required Widget child,
    Duration duration = standard,
    Curve curve = emphasizedDecelerateCurve,
    Offset begin = const Offset(0, 0.2),
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: begin, end: Offset.zero),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value.dx * 50, value.dy * 50),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Combined fade and slide transition
  static Widget fadeSlideIn({
    required Widget child,
    Duration duration = standard,
    Curve curve = emphasizedDecelerateCurve,
  }) {
    return fadeIn(
      duration: duration,
      curve: curve,
      child: slideIn(
        duration: duration,
        curve: curve,
        child: child,
      ),
    );
  }
}
