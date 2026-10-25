# Entry rendering

## What it is

Drawing one entry, either an item or a divider, and turning a tap on an
enabled item into a selection. The menu body, the header and the footer all
draw their entries through the same view.

## Governing decisions

- [ADR-0002](../../adr/0002-latch-the-result-when-close-is-requested.md#decision)
  decides that the result latches on select. That is why selection runs
  before the item's own `onTap`.
- Nothing decides the rest: the entry model, disabled styling, ink layering
  or selected highlighting.

## Design model

- `OverlayMenuEntry` is sealed, with two kinds: `OverlayMenuItem` and
  `OverlayMenuDivider`.
- Tapping an enabled item reports the selection first and then runs
  `onTap`. If `onTap` pushes a route, the resulting Auto-close finds the
  result already latched.
- A disabled item has no tap handler, uses the basic cursor and draws its
  text in the theme's `disabledColor`.
- An item's background is painted with `Ink` inside a transparent
  `Material`, so hover and splash draw on top of it. The selected item uses
  `selectedBackgroundColor`. "Selected" means the menu's `initialValue` is
  non-null and the item's value `==` it.
- The header and footer pass their own item style. Dividers always use the
  menu's divider style.
- The view knows nothing about the barrier, the open/close animation or the
  scroll view, so it can be pumped on its own.
- Heights come from [Entry metrics](entry-metrics.md). The view does not
  compute any itself.

## Code

- `lib/src/overlay_menu_entry_view.dart` — `OverlayMenuEntryView`, `_buildItem`, `_buildDivider`
- `lib/src/overlay_menu_item.dart` — `OverlayMenuEntry`, `OverlayMenuItem`, `OverlayMenuDivider`
- `lib/src/overlay_menu.dart` — `_buildEntry`
- `test/overlay_menu_entry_view_test.dart`

## Reference behaviour

**None.**

## Cross-cutting invariants

- [Result latched at Close request](../invariant/result-latched-at-request.md)
- [Force decides Animated vs Instant](../invariant/close-force-decides-animation.md)

## Blast radius

- [Close lifecycle](close-lifecycle.md): selection is a Close trigger.
- [Entry metrics](entry-metrics.md): the item and divider heights drawn here
  must match the ones the scroll arithmetic uses.
- [Surface style](surface-style.md): reads the item and divider style
  fields.
- [Menu body layout](menu-body-layout.md): places these views in the body,
  header and footer.

## Known holes / open

- `OverlayMenuItem.value` may be `null`. Selecting such an item delivers
  `null`, which the caller cannot tell apart from a Close with no selection.
  [OverlayMenuButton](overlay-menu-button.md) calls `onCanceled` for it. No
  record says whether that is intended.
