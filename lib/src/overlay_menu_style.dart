import 'package:flutter/material.dart';

/// Style for header items. Same shape as [OverlayMenuItemStyle].
typedef OverlayMenuHeaderStyle = OverlayMenuItemStyle;

/// Style for footer items. Same shape as [OverlayMenuItemStyle].
typedef OverlayMenuFooterStyle = OverlayMenuItemStyle;

/// Groups visual style options for [showOverlayMenu].
class OverlayMenuStyle {
  const OverlayMenuStyle({
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.maxHeight,
    this.itemStyle,
    this.headerStyle,
    this.footerStyle,
    this.dividerStyle,
    this.scrollbarStyle,
  });

  /// Background color of the menu surface.
  /// Falls back to `colorScheme.surfaceContainer`.
  final Color? backgroundColor;

  /// Border radius of the menu surface.
  /// Falls back to `BorderRadius.circular(8)`.
  final BorderRadius? borderRadius;

  /// Internal padding of the menu container.
  /// Falls back to `EdgeInsets.symmetric(vertical: 4)`.
  final EdgeInsets? padding;

  /// Maximum height of the menu. When content exceeds this, the menu scrolls.
  final double? maxHeight;

  /// Default style for menu items.
  final OverlayMenuItemStyle? itemStyle;

  /// Style for header items. Overrides [itemStyle] for header entries.
  final OverlayMenuHeaderStyle? headerStyle;

  /// Style for footer items. Overrides [itemStyle] for footer entries.
  final OverlayMenuFooterStyle? footerStyle;

  /// Style for dividers.
  final OverlayMenuDividerStyle? dividerStyle;

  /// Scrollbar style. Only applies when [maxHeight] triggers scrolling.
  final OverlayMenuScrollbarStyle? scrollbarStyle;
}

/// Default style for individual menu items.
class OverlayMenuItemStyle {
  const OverlayMenuItemStyle({
    this.height,
    this.borderRadius,
    this.hoverColor,
    this.splashColor,
    this.highlightColor,
    this.focusColor,
    this.mouseCursor,
  });

  /// Default height. Falls back to `48.0`.
  final double? height;

  /// Border radius for the item's InkWell and selection decoration.
  final BorderRadius? borderRadius;

  /// Hover highlight color for InkWell.
  final Color? hoverColor;

  /// Splash color for InkWell.
  final Color? splashColor;

  /// Highlight color for InkWell.
  final Color? highlightColor;

  /// Focus color for InkWell.
  final Color? focusColor;

  /// Mouse cursor when hovering over enabled items.
  /// Falls back to `SystemMouseCursors.click`.
  final MouseCursor? mouseCursor;
}

/// Style for menu dividers.
class OverlayMenuDividerStyle {
  const OverlayMenuDividerStyle({
    this.color,
    this.thickness,
    this.height,
    this.indent,
    this.endIndent,
  });

  /// Divider color. Falls back to theme default.
  final Color? color;

  /// Divider thickness. Falls back to `1.0`.
  final double? thickness;

  /// Total height occupied by the divider, including surrounding space.
  /// Falls back to [thickness].
  final double? height;

  /// Leading indent. Falls back to `0`.
  final double? indent;

  /// Trailing indent. Falls back to `0`.
  final double? endIndent;
}

/// Style for the menu scrollbar.
///
/// Only takes effect when [OverlayMenuStyle.maxHeight] is set and
/// the menu content exceeds that height.
class OverlayMenuScrollbarStyle {
  const OverlayMenuScrollbarStyle({
    this.thumbColor,
    this.thickness,
    this.radius,
    this.thumbVisibility,
  });

  /// Scrollbar thumb color.
  final Color? thumbColor;

  /// Scrollbar thickness.
  final double? thickness;

  /// Scrollbar thumb corner radius.
  final Radius? radius;

  /// Whether the scrollbar thumb is always visible.
  /// When `false` or `null`, the scrollbar only appears during scrolling.
  final bool? thumbVisibility;
}
