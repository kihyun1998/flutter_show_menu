# Menu body layout

## What it is

How the header, the items and the footer are arranged inside the menu
surface, and when the items scroll.

## Governing decisions

- [ADR-0008](../../adr/0008-a-menu-without-maxheight-scrolls-within-the-safe-area.md#decision)
  makes a menu without `maxHeight` scroll within the safe area, in the same
  layout as with it.
- [ADR-0009](../../adr/0009-take-flutter-smooth-wheel-scroll-as-the-first-runtime-dependency.md#decision)
  animates mouse wheel input through `flutter_smooth_wheel_scroll`.

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
- The scroll controller always exists. It is a `SmoothScrollController` from
  `flutter_smooth_wheel_scroll`, built with `style.wheelMotion`, or the
  default spring when no style is given
  ([ADR-0009](../../adr/0009-take-flutter-smooth-wheel-scroll-as-the-first-runtime-dependency.md#decision)).
  It animates only mouse wheel input. `jumpTo`, which brings `initialValue`
  into view, drag, the scrollbar and the keyboard move as with a plain
  `ScrollController`. The motion is read when the menu is built; nothing
  changes it while the menu is open.
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
- `test/menu_wheel_motion_test.dart`

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
  needs Flutter 3.22 (#24); the `flutter_smooth_wheel_scroll` dependency
  now sets the floor higher, at 3.32 (ADR-0009).
- [Entry rendering](entry-rendering.md): each entry is drawn by it, with the
  header and footer styles passed in.
- [Surface style](surface-style.md): supplies `padding` and `maxHeight`.

## Known holes / open

- No record says why header and footer dividers are dropped only when
  `items` is empty.
- A header and footer taller than the height limit leave the scroll
  viewport no room, and the column overflows.
