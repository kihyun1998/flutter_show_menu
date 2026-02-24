import 'package:flutter/material.dart';

/// Base type for entries in an overlay menu.
///
/// An entry is either an [OverlayMenuItem] (selectable row) or an
/// [OverlayMenuDivider] (visual separator).
sealed class OverlayMenuEntry<T> {
  const OverlayMenuEntry();
}

/// Defines an individual item in the overlay menu.
class OverlayMenuItem<T> extends OverlayMenuEntry<T> {
  const OverlayMenuItem({
    this.value,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.height,
    this.padding,
    this.selected = false,
    this.prefixBuilder,
  });

  /// The value to return when this item is selected.
  final T? value;

  /// The content widget of the menu item.
  final Widget child;

  /// Callback when the item is tapped (fires independently of value return).
  final VoidCallback? onTap;

  /// Whether the item is enabled.
  final bool enabled;

  /// Item height (null → [OverlayMenuItemStyle.height] → 48.0).
  final double? height;

  /// Internal padding of the item.
  final EdgeInsets? padding;

  /// Whether this item is marked as selected.
  final bool selected;

  /// Optional prefix widget builder for this item.
  /// Takes precedence over [OverlayMenuStyle.prefixBuilder].
  final Widget Function(BuildContext context, bool selected)? prefixBuilder;
}

/// A horizontal divider line inside an overlay menu.
class OverlayMenuDivider<T> extends OverlayMenuEntry<T> {
  const OverlayMenuDivider({
    this.color,
    this.thickness,
    this.indent,
    this.endIndent,
  });

  /// Divider color (null → [OverlayMenuDividerStyle.color] → theme default).
  final Color? color;

  /// Divider thickness (null → [OverlayMenuDividerStyle.thickness] → 1.0).
  final double? thickness;

  /// Leading indent.
  final double? indent;

  /// Trailing indent.
  final double? endIndent;
}
