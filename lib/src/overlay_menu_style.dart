import 'package:flutter/material.dart';

/// Style for header items. Same shape as [OverlayMenuItemStyle].
typedef OverlayMenuHeaderStyle = OverlayMenuItemStyle;

/// Style for footer items. Same shape as [OverlayMenuItemStyle].
typedef OverlayMenuFooterStyle = OverlayMenuItemStyle;

/// How the menu surface looks and how large it is allowed to be.
class OverlayMenuStyle {
  const OverlayMenuStyle({
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.maxHeight,
    this.width,
    this.constraints,
    this.decoration,
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

  /// Fixed width of the menu. Sizes to its content when null.
  final double? width;

  /// Extra box constraints applied around the menu.
  final BoxConstraints? constraints;

  /// Extra decoration wrapped around the menu surface.
  final BoxDecoration? decoration;

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

  OverlayMenuStyle copyWith({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    double? maxHeight,
    double? width,
    BoxConstraints? constraints,
    BoxDecoration? decoration,
    OverlayMenuItemStyle? itemStyle,
    OverlayMenuHeaderStyle? headerStyle,
    OverlayMenuFooterStyle? footerStyle,
    OverlayMenuDividerStyle? dividerStyle,
    OverlayMenuScrollbarStyle? scrollbarStyle,
  }) {
    return OverlayMenuStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      maxHeight: maxHeight ?? this.maxHeight,
      width: width ?? this.width,
      constraints: constraints ?? this.constraints,
      decoration: decoration ?? this.decoration,
      itemStyle: itemStyle ?? this.itemStyle,
      headerStyle: headerStyle ?? this.headerStyle,
      footerStyle: footerStyle ?? this.footerStyle,
      dividerStyle: dividerStyle ?? this.dividerStyle,
      scrollbarStyle: scrollbarStyle ?? this.scrollbarStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is OverlayMenuStyle &&
        other.backgroundColor == backgroundColor &&
        other.borderRadius == borderRadius &&
        other.padding == padding &&
        other.maxHeight == maxHeight &&
        other.width == width &&
        other.constraints == constraints &&
        other.decoration == decoration &&
        other.itemStyle == itemStyle &&
        other.headerStyle == headerStyle &&
        other.footerStyle == footerStyle &&
        other.dividerStyle == dividerStyle &&
        other.scrollbarStyle == scrollbarStyle;
  }

  @override
  int get hashCode => Object.hash(
        backgroundColor,
        borderRadius,
        padding,
        maxHeight,
        width,
        constraints,
        decoration,
        itemStyle,
        headerStyle,
        footerStyle,
        dividerStyle,
        scrollbarStyle,
      );
}

/// Default style for individual menu items.
class OverlayMenuItemStyle {
  const OverlayMenuItemStyle({
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.selectedBackgroundColor,
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

  /// Background color for items. Painted on the ink layer so
  /// InkWell hover/splash renders on top of it.
  final Color? backgroundColor;

  /// Background color for the selected item (matched by [initialValue]).
  /// Painted on the ink layer so InkWell hover/splash renders on top of it.
  final Color? selectedBackgroundColor;

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

  OverlayMenuItemStyle copyWith({
    double? height,
    BorderRadius? borderRadius,
    Color? backgroundColor,
    Color? selectedBackgroundColor,
    Color? hoverColor,
    Color? splashColor,
    Color? highlightColor,
    Color? focusColor,
    MouseCursor? mouseCursor,
  }) {
    return OverlayMenuItemStyle(
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      hoverColor: hoverColor ?? this.hoverColor,
      splashColor: splashColor ?? this.splashColor,
      highlightColor: highlightColor ?? this.highlightColor,
      focusColor: focusColor ?? this.focusColor,
      mouseCursor: mouseCursor ?? this.mouseCursor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is OverlayMenuItemStyle &&
        other.height == height &&
        other.borderRadius == borderRadius &&
        other.backgroundColor == backgroundColor &&
        other.selectedBackgroundColor == selectedBackgroundColor &&
        other.hoverColor == hoverColor &&
        other.splashColor == splashColor &&
        other.highlightColor == highlightColor &&
        other.focusColor == focusColor &&
        other.mouseCursor == mouseCursor;
  }

  @override
  int get hashCode => Object.hash(
        height,
        borderRadius,
        backgroundColor,
        selectedBackgroundColor,
        hoverColor,
        splashColor,
        highlightColor,
        focusColor,
        mouseCursor,
      );
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

  OverlayMenuDividerStyle copyWith({
    Color? color,
    double? thickness,
    double? height,
    double? indent,
    double? endIndent,
  }) {
    return OverlayMenuDividerStyle(
      color: color ?? this.color,
      thickness: thickness ?? this.thickness,
      height: height ?? this.height,
      indent: indent ?? this.indent,
      endIndent: endIndent ?? this.endIndent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is OverlayMenuDividerStyle &&
        other.color == color &&
        other.thickness == thickness &&
        other.height == height &&
        other.indent == indent &&
        other.endIndent == endIndent;
  }

  @override
  int get hashCode => Object.hash(color, thickness, height, indent, endIndent);
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

  OverlayMenuScrollbarStyle copyWith({
    Color? thumbColor,
    double? thickness,
    Radius? radius,
    bool? thumbVisibility,
  }) {
    return OverlayMenuScrollbarStyle(
      thumbColor: thumbColor ?? this.thumbColor,
      thickness: thickness ?? this.thickness,
      radius: radius ?? this.radius,
      thumbVisibility: thumbVisibility ?? this.thumbVisibility,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is OverlayMenuScrollbarStyle &&
        other.thumbColor == thumbColor &&
        other.thickness == thickness &&
        other.radius == radius &&
        other.thumbVisibility == thumbVisibility;
  }

  @override
  int get hashCode =>
      Object.hash(thumbColor, thickness, radius, thumbVisibility);
}
