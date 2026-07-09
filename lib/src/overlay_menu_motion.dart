import 'package:flutter/animation.dart';

/// How the menu animates in and out.
///
/// The exit animation plays when the menu Closes because a human acted on it —
/// an item was selected, the barrier was tapped, or an `OverlayMenuController`
/// closed it. A route change and `closeAllOverlayMenus()` tear the menu down at
/// once, and skip it.
class OverlayMenuMotion {
  const OverlayMenuMotion({
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.easeOutCubic,
  });

  /// Duration of the enter and exit animation.
  final Duration duration;

  /// Curve of the enter and exit animation.
  final Curve curve;

  OverlayMenuMotion copyWith({Duration? duration, Curve? curve}) {
    return OverlayMenuMotion(
      duration: duration ?? this.duration,
      curve: curve ?? this.curve,
    );
  }
}
