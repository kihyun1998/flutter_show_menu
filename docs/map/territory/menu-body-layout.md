# Menu body layout

## What it is

How the header, the items and the footer are arranged inside the menu
surface, and when the items scroll.

## Governing decisions

- [ADR-0008](../../adr/0008-a-menu-without-maxheight-scrolls-within-the-safe-area.md#decision)
  makes a menu without `maxHeight` scroll within the safe area, in the same
  layout as with it.

## Design model

Read from the source, except where a record is linked.

- Only the items scroll. The column is: the top padding, the header, the
  scrolling items, the footer, the bottom padding. Horizontal padding is
  applied to each header and footer entry and inside the scroll view. The
  scroll viewport is therefore the menu's height limit minus the vertical
  padding, the header and the footer. That viewport is what
  [Entry metrics](entry-metrics.md) centres `initialValue` against.
- The height limit is `maxHeight`, or the safe area the
  [placement](placement-and-flip.md) delegate allows when `maxHeight` is
  null (ADR-0008). A menu that fits is sized by its entries either way.
- The scroll controller always exists.
- When `items` is empty, dividers are dropped from the header and the
  footer.
- The scroll view always has a `Scrollbar`. It is themed only when
  `scrollbarStyle` is given, and the theming uses `WidgetStatePropertyAll`.
- The body sits inside `IntrinsicWidth`. The surface around it belongs to
  [Surface style](surface-style.md).

## Code

- `lib/src/overlay_menu.dart` — `_buildScrollableBody`, `_scrollController`
- `lib/src/overlay_menu_style.dart` — `OverlayMenuScrollbarStyle`
- `test/menu_header_footer_pinning_test.dart`
- `test/menu_max_height_test.dart`
- `test/menu_scrollbar_test.dart`

## Reference behaviour

**None.**

## Cross-cutting invariants

**None.**

## Blast radius

- [Entry metrics](entry-metrics.md): the viewport this layout produces is
  what `initialValue` centres against. Centring against `maxHeight` instead
  was #5.
- [Placement and flip](placement-and-flip.md): the body's height is what
  the flip test measures.
- [Release and publish](release-and-publish.md): `WidgetStatePropertyAll`
  is what sets the Flutter floor at 3.22 (#24).
- [Entry rendering](entry-rendering.md): each entry is drawn by it, with the
  header and footer styles passed in.
- [Surface style](surface-style.md): supplies `padding` and `maxHeight`.

## Known holes / open

- No record says why header and footer dividers are dropped only when
  `items` is empty.
- A header and footer taller than the height limit leave the scroll
  viewport no room, and the column overflows.
