# Barrier

## What it is

The full-screen layer behind the menu. It can be tinted, a tap on it can
Close the menu, and it can hold a caller widget between itself and the menu.

## Governing decisions

- [ADR-0003](../../adr/0003-group-menu-configuration-by-cohesion.md#decision)
  groups `dismissible`, `color` and `overlayChild` into
  `OverlayMenuBarrier`. It decides the grouping, not how the barrier
  behaves.

## Design model

- The menu's overlay entry is a `Stack` of three layers: the barrier, then
  the overlay child if there is one, then the positioned menu.
- With `dismissible` true, a tap on the barrier is an Animated Close with a
  `null` result. With it false, a tap on the barrier does nothing.
- `color` paints the barrier and defaults to transparent.
- `overlayChild` fills the screen above the barrier and below the menu. The
  use it was added for is a drag-to-move area on desktop. It comes before
  the barrier in hit-test order, so a pointer the child hits never reaches
  the barrier. A pointer the child does not hit still does.

## Code

- `lib/src/overlay_menu.dart` — `_OverlayMenuWidgetState.build`
- `lib/src/overlay_menu_barrier.dart` — `OverlayMenuBarrier`
- `test/menu_overlay_child_test.dart`
- `test/menu_chrome_test.dart`

## Reference behaviour

**None.**

## Cross-cutting invariants

- [One Close path](../invariant/one-close-path.md)
- [Force decides Animated vs Instant](../invariant/close-force-decides-animation.md)

## Blast radius

- [Close lifecycle](close-lifecycle.md): a barrier tap is a Close trigger.
- [Configuration objects](configuration-objects.md): `overlayChild` is
  compared by identity.

## Known holes / open

- Nothing here checks whether a non-dismissible barrier still stops taps
  from reaching widgets underneath it.
