import 'package:flutter/widgets.dart';

/// The full-screen area behind the menu, and how it behaves.
class OverlayMenuBarrier {
  const OverlayMenuBarrier({
    this.dismissible = true,
    this.color,
    this.overlayChild,
  });

  /// Whether tapping outside the menu closes it.
  final bool dismissible;

  /// Color painted behind the menu. Transparent when null.
  final Color? color;

  /// Drawn above the barrier and below the menu — a drag-to-move area, say.
  final Widget? overlayChild;

  OverlayMenuBarrier copyWith({
    bool? dismissible,
    Color? color,
    Widget? overlayChild,
  }) {
    return OverlayMenuBarrier(
      dismissible: dismissible ?? this.dismissible,
      color: color ?? this.color,
      overlayChild: overlayChild ?? this.overlayChild,
    );
  }
}
