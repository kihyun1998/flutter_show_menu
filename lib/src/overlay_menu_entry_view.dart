import 'package:flutter/material.dart';

import 'overlay_menu_item.dart';
import 'overlay_menu_metrics.dart';
import 'overlay_menu_style.dart';

/// Renders one [OverlayMenuEntry], whichever kind it is.
///
/// The menu body, its header, and its footer all draw their entries through
/// this — the header and footer by passing their own [itemStyle]. It knows
/// nothing about the barrier, the open/close animation, or the scroll view, so
/// it can be pumped on its own.
class OverlayMenuEntryView<T> extends StatelessWidget {
  const OverlayMenuEntryView({
    super.key,
    required this.entry,
    required this.onSelected,
    this.itemStyle,
    this.dividerStyle,
    this.isSelected = false,
  });

  /// The entry to draw.
  final OverlayMenuEntry<T> entry;

  /// Called with the item's value when an enabled item is tapped, before the
  /// item's own `onTap` runs.
  final ValueChanged<T?> onSelected;

  /// Style for items. Header and footer entries pass their own.
  final OverlayMenuItemStyle? itemStyle;

  /// Style for dividers.
  final OverlayMenuDividerStyle? dividerStyle;

  /// Whether this entry is the selected one. Ignored for dividers.
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return switch (entry) {
      final OverlayMenuItem<T> item => _buildItem(context, item),
      final OverlayMenuDivider<T> divider => _buildDivider(divider),
    };
  }

  Widget _buildItem(BuildContext context, OverlayMenuItem<T> item) {
    final theme = Theme.of(context);
    final height = resolveEntryHeight(item, itemStyle: itemStyle);
    final borderRadius = itemStyle?.borderRadius;

    final mouseCursor = item.enabled
        ? (itemStyle?.mouseCursor ?? SystemMouseCursors.click)
        : SystemMouseCursors.basic;

    Widget content = item.child;
    if (!item.enabled) {
      content = DefaultTextStyle.merge(
        style: TextStyle(color: theme.disabledColor),
        child: content,
      );
    }

    final inkColor = isSelected
        ? itemStyle?.selectedBackgroundColor
        : itemStyle?.backgroundColor;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: inkColor,
          borderRadius: borderRadius,
        ),
        child: InkWell(
          onTap: item.enabled
              ? () {
                  // Select first, then run the item's side effect. The caller
                  // latches the result on select, so a side effect that closes
                  // the menu — pushing a route, say — cannot overtake it.
                  onSelected(item.value);
                  item.onTap?.call();
                }
              : null,
          mouseCursor: mouseCursor,
          borderRadius: borderRadius,
          hoverColor: itemStyle?.hoverColor,
          splashColor: itemStyle?.splashColor,
          highlightColor: itemStyle?.highlightColor,
          focusColor: itemStyle?.focusColor,
          child: Container(
            height: height,
            alignment: Alignment.centerLeft,
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(OverlayMenuDivider<T> divider) {
    return Divider(
      color: divider.color ?? dividerStyle?.color,
      thickness: resolveDividerThickness(divider, dividerStyle),
      indent: divider.indent ?? dividerStyle?.indent ?? 0,
      endIndent: divider.endIndent ?? dividerStyle?.endIndent ?? 0,
      height: resolveEntryHeight(divider, dividerStyle: dividerStyle),
    );
  }
}
