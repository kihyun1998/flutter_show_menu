import 'overlay_menu_item.dart';
import 'overlay_menu_style.dart';

/// Height an item falls back to when neither the item nor its style sets one.
const double kDefaultItemHeight = 48.0;

/// Thickness a divider falls back to when neither the divider nor its style
/// sets one.
const double kDefaultDividerThickness = 1.0;

/// Resolves the thickness of [divider] against [style], then the package
/// default.
double resolveDividerThickness(
  OverlayMenuDivider divider,
  OverlayMenuDividerStyle? style,
) {
  return divider.thickness ?? style?.thickness ?? kDefaultDividerThickness;
}

/// The vertical space [entry] occupies once its style fallbacks are resolved.
///
/// The widgets that lay entries out and the arithmetic that predicts where
/// they land both read this, so the two cannot drift.
double resolveEntryHeight<T>(
  OverlayMenuEntry<T> entry, {
  OverlayMenuItemStyle? itemStyle,
  OverlayMenuDividerStyle? dividerStyle,
}) {
  return switch (entry) {
    OverlayMenuItem<T>() =>
      entry.height ?? itemStyle?.height ?? kDefaultItemHeight,
    OverlayMenuDivider<T>() => entry.height ??
        dividerStyle?.height ??
        resolveDividerThickness(entry, dividerStyle),
  };
}

/// Scroll offset that centres the item carrying [initialValue] in a viewport
/// of [viewportHeight].
///
/// Returns null when [initialValue] is null or no item carries it. The result
/// is unclamped — the caller bounds it against the real scroll extent, which
/// only exists once the menu has laid out.
double? resolveScrollOffsetToValue<T>({
  required List<OverlayMenuEntry<T>> entries,
  required T? initialValue,
  required double viewportHeight,
  OverlayMenuItemStyle? itemStyle,
  OverlayMenuDividerStyle? dividerStyle,
}) {
  if (initialValue == null) return null;

  var offset = 0.0;
  for (final entry in entries) {
    final height = resolveEntryHeight(
      entry,
      itemStyle: itemStyle,
      dividerStyle: dividerStyle,
    );
    if (entry is OverlayMenuItem<T> && entry.value == initialValue) {
      return offset - (viewportHeight / 2) + (height / 2);
    }
    offset += height;
  }
  return null;
}
