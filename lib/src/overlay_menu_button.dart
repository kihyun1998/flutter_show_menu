import 'package:flutter/material.dart';
import 'menu_position.dart';
import 'overlay_menu.dart';
import 'overlay_menu_item.dart';
import 'overlay_menu_style.dart';

/// A widget that wraps a child widget and shows an overlay menu when tapped.
class OverlayMenuButton<T> extends StatelessWidget {
  const OverlayMenuButton({
    super.key,
    required this.items,
    this.header,
    this.footer,
    required this.child,
    this.position = MenuPosition.bottom,
    this.alignment = MenuAlignment.start,
    this.offset = Offset.zero,
    this.onSelected,
    this.onCanceled,
    this.barrierDismissible = true,
    this.barrierColor,
    this.decoration,
    this.menuPadding,
    this.menuConstraints,
    this.menuWidth,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationCurve = Curves.easeOutCubic,
    this.enabled = true,
    this.style,
  });

  /// List of menu items.
  final List<OverlayMenuEntry<T>> items;

  /// List of entries fixed at the top of the scroll area.
  final List<OverlayMenuEntry<T>>? header;

  /// List of entries fixed at the bottom of the scroll area.
  final List<OverlayMenuEntry<T>>? footer;

  /// The child widget that acts as the tap target.
  final Widget child;

  /// Menu display direction.
  final MenuPosition position;

  /// Menu cross-axis alignment.
  final MenuAlignment alignment;

  /// Fine-tuning offset for positioning.
  final Offset offset;

  /// Callback when an item is selected.
  final ValueChanged<T>? onSelected;

  /// Callback when the menu is closed without a selection.
  final VoidCallback? onCanceled;

  /// Whether tapping outside the menu dismisses it.
  final bool barrierDismissible;

  /// Barrier background color.
  final Color? barrierColor;

  /// Menu container decoration.
  final BoxDecoration? decoration;

  /// Internal padding of the menu.
  final EdgeInsets? menuPadding;

  /// Menu size constraints.
  final BoxConstraints? menuConstraints;

  /// Fixed menu width.
  final double? menuWidth;

  /// Animation duration.
  final Duration animationDuration;

  /// Animation curve.
  final Curve animationCurve;

  /// Whether the button is enabled.
  final bool enabled;

  /// Visual style options for the menu.
  final OverlayMenuStyle? style;

  Future<void> _show(BuildContext context) async {
    final result = await showOverlayMenu<T>(
      context: context,
      items: items,
      header: header,
      footer: footer,
      position: position,
      alignment: alignment,
      offset: offset,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      decoration: decoration,
      padding: menuPadding,
      constraints: menuConstraints,
      width: menuWidth,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      style: style,
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
