# Entry metrics

## What it is

One pure module that works out how tall each entry is and which scroll
offset centres the item carrying `initialValue`.

## Governing decisions

**None.** The single-module shape was shipped as an internal change in 1.0.0
(`CHANGELOG.md`, 1.0.0 "Internal"), not decided in a record.

## Design model

- Item height: the item's `height`, else the item style's `height`, else
  48.
- Divider height: the divider's `height`, else the divider style's
  `height`, else its thickness. Thickness is the divider's `thickness`, else
  the style's, else 1.
- [Entry rendering](entry-rendering.md) and the scroll arithmetic read the
  same functions, so the height a widget is drawn at and the height the
  arithmetic assumes cannot drift apart.
- The offset that centres an item is the sum of the heights before it, minus
  half the viewport, plus half the item. The result is not clamped; the
  caller clamps it to the real scroll extent.
- The jump happens after the first frame, because only then does the scroll
  position know how tall the viewport is. It is not `maxHeight`: the menu's
  padding and any header or footer are pinned outside the scrollable area
  (see [Menu body layout](menu-body-layout.md)), and centring against
  `maxHeight` would push the entry down by half of what they occupy (#5).
- Only `items` count toward the offset. The header and footer are outside
  the scroll view.

## Code

- `lib/src/overlay_menu_metrics.dart` — `kDefaultItemHeight`, `kDefaultDividerThickness`, `resolveDividerThickness`, `resolveEntryHeight`, `resolveScrollOffsetToValue`
- `lib/src/overlay_menu.dart` — `_jumpToInitialValue`
- `test/overlay_menu_metrics_test.dart`
- `test/menu_initial_value_scroll_test.dart`

## Reference behaviour

- [lessons, Step 2](../../agents/lessons.md#step-2--추측-금지-sdk-소스가-진실)
  records the probe that measured #5: 4px off with default padding, 52px
  with a header and footer.

## Cross-cutting invariants

**None.**

## Blast radius

- [Entry rendering](entry-rendering.md): draws entries at the heights
  computed here.
- [Menu body layout](menu-body-layout.md): produces the viewport the offset
  is centred in.
- [Surface style](surface-style.md): supplies the item and divider style
  heights.

## Known holes / open

- If several items carry `initialValue`, the first one wins for scrolling,
  while every one of them is drawn highlighted (see
  [Entry rendering](entry-rendering.md)).
