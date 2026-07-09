import 'package:flutter/material.dart';

import 'open_menu.dart';
import 'overlay_menu.dart';
import 'overlay_menu_barrier.dart';
import 'overlay_menu_item.dart';
import 'overlay_menu_motion.dart';
import 'overlay_menu_placement.dart';
import 'overlay_menu_style.dart';

/// Wraps a child widget and shows an overlay menu when it is tapped.
///
/// A tap-to-open shortcut over [showOverlayMenu]; it takes the same
/// configuration and behaves identically.
class OverlayMenuButton<T> extends StatelessWidget {
  const OverlayMenuButton({
    super.key,
    required this.items,
    required this.child,
    this.header,
    this.footer,
    this.initialValue,
    this.placement = const OverlayMenuPlacement(),
    this.barrier = const OverlayMenuBarrier(),
    this.motion = const OverlayMenuMotion(),
    this.style,
    this.controller,
    this.onSelected,
    this.onCanceled,
    this.enabled = true,
  });

  /// Selectable entries displayed in the scrollable area.
  final List<OverlayMenuEntry<T>> items;

  /// The child widget that acts as the tap target.
  final Widget child;

  /// Entries pinned above the scrollable area.
  final List<OverlayMenuEntry<T>>? header;

  /// Entries pinned below the scrollable area.
  final List<OverlayMenuEntry<T>>? footer;

  /// Value of the item to scroll to when the menu opens.
  final T? initialValue;

  /// Where the menu sits relative to this button.
  final OverlayMenuPlacement placement;

  /// The area behind the menu and how it behaves.
  final OverlayMenuBarrier barrier;

  /// How the menu animates in and out.
  final OverlayMenuMotion motion;

  /// Colors, sizing, item styles, scrollbar.
  final OverlayMenuStyle? style;

  /// Optional controller for programmatic Close.
  final OverlayMenuController? controller;

  /// Called when an item is selected.
  final ValueChanged<T>? onSelected;

  /// Called when the menu Closes without a selection.
  final VoidCallback? onCanceled;

  /// Whether the button responds to taps.
  final bool enabled;

  Future<void> _show(BuildContext context) async {
    final result = await showOverlayMenu<T>(
      context: context,
      items: items,
      header: header,
      footer: footer,
      initialValue: initialValue,
      placement: placement,
      barrier: barrier,
      motion: motion,
      style: style,
      controller: controller,
    );

    if (result != null) {
      onSelected?.call(result);
    } else {
      onCanceled?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => _show(context) : null,
      child: child,
    );
  }
}
