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
    this.maxHeight,
    this.itemStyle,
    this.headerStyle,
    this.footerStyle,
    this.selectedStyle,
    this.dividerStyle,
    this.scrollbarStyle,
    this.prefixBuilder,
  });

  /// Background color of the menu surface.
  /// Falls back to `colorScheme.surfaceContainer`.
  final Color? backgroundColor;

  /// Border radius of the menu surface.
  /// Falls back to `BorderRadius.circular(8)`.
  final BorderRadius? borderRadius;

  /// Maximum height of the menu. When content exceeds this, the menu scrolls.
  final double? maxHeight;

  /// Default style for menu items.
  final OverlayMenuItemStyle? itemStyle;

  /// Style for header items. Overrides [itemStyle] for header entries.
  final OverlayMenuHeaderStyle? headerStyle;

  /// Style for footer items. Overrides [itemStyle] for footer entries.
  final OverlayMenuFooterStyle? footerStyle;

  /// Style for selected items.
  final OverlayMenuSelectedStyle? selectedStyle;

  /// Style for dividers.
  final OverlayMenuDividerStyle? dividerStyle;

  /// Scrollbar style. Only applies when [maxHeight] triggers scrolling.
  final OverlayMenuScrollbarStyle? scrollbarStyle;

  /// Default prefix widget builder for all items.
  /// Item-level [OverlayMenuItem.prefixBuilder] takes precedence.
  final Widget Function(BuildContext context, bool selected)? prefixBuilder;
}

/// Default style for individual menu items.
class OverlayMenuItemStyle {
  const OverlayMenuItemStyle({
    this.height,
    this.padding,
    this.borderRadius,
    this.textStyle,
    this.hoverColor,
    this.splashColor,
    this.highlightColor,
    this.focusColor,
    this.mouseCursor,
  });

  /// Default height. Falls back to `48.0`.
  final double? height;

  /// Default padding. Falls back to `EdgeInsets.symmetric(horizontal: 16)`.
  final EdgeInsets? padding;

  /// Border radius for the item's InkWell and selection decoration.
  final BorderRadius? borderRadius;

  /// Default text style.
  final TextStyle? textStyle;

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

/// Style applied to items marked as selected.
class OverlayMenuSelectedStyle {
  const OverlayMenuSelectedStyle({
    this.backgroundColor,
    this.textStyle,
    this.border,
  });

  /// Background color for selected items.
  final Color? backgroundColor;

  /// Text style override (merged on top of item textStyle).
  final TextStyle? textStyle;

  /// Border around selected items.
  final BorderSide? border;
}

/// Style for menu dividers.
class OverlayMenuDividerStyle {
  const OverlayMenuDividerStyle({
    this.color,
    this.thickness,
    this.indent,
    this.endIndent,
  });

  /// Divider color. Falls back to theme default.
  final Color? color;

  /// Divider thickness. Falls back to `1.0`.
  final double? thickness;

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
