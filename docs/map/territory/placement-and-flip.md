# Placement and flip

## What it is

Where the menu box lands. It sits on one side of its anchor, aligned along
the other axis, shifted by an offset, flipped to the opposite side if it
would run off the screen, and finally clamped into the safe area.

## Governing decisions

- [ADR-0005 — a flip mirrors the main-axis offset](../../adr/0005-a-flip-mirrors-the-main-axis-offset.md#decision)
  decides what a flip does to the offset.
- [ADR-0006 — a menu that fits neither side goes to the roomier one](../../adr/0006-a-menu-that-fits-neither-side-goes-to-the-roomier-one.md#decision)
  decides when to flip. Nothing decides the clamp or the alignment.
- [ADR-0004](../../adr/0004-resolve-the-scale-origin-during-layout.md#decision)
  decides that the *scale origin* follows the side the menu landed on, not
  the flip rule itself.
- [ADR-0003](../../adr/0003-group-menu-configuration-by-cohesion.md#decision)
  groups `position`, `alignment` and `offset` into `OverlayMenuPlacement`
  without deciding the geometry.

## Design model

Read from the source; nothing in a record says it.

- The menu is loosely constrained to the screen size minus the
  `MediaQuery` padding.
- Main axis: `bottom` puts the top of the menu at the anchor's bottom, `top`
  puts its bottom at the anchor's top, and `left` and `right` do the same
  horizontally. The offset is added on that axis.
- Cross axis: `start`, `center` and `end` align to the anchor's left,
  centre or right (top, centre or bottom for `left`/`right`). The offset is
  added on this axis too. `start` and `end` are physical sides and ignore
  text direction.
- Flip: only along the main axis, only once, only to the opposite side, and
  only when the requested side would overrun the safe area on that side and
  the opposite side has more room. Room is the distance from the target's
  edge to the safe edge; a tie stays. The menu jumps sides instead of just
  being clamped, so as not to cover the widget it is anchored to. That is
  the intent, not a guarantee: a menu taller than the room on either side
  is clamped back over its anchor, by its size minus the room on the side
  it landed on. The menu is not shrunk to that side's room
  ([#42](https://github.com/kihyun1998/flutter_show_menu/issues/42), the
  maintainer's call): neither Material menu does so, and a header and
  footer can leave no room to scroll. A caller who must not cover the
  anchor sets a smaller `maxHeight`. The
  flipped position mirrors the main-axis offset, so a gap stays a gap and a
  deliberate overlap stays an overlap. The cross-axis offset is unchanged.
- Clamp: after any flip, both axes are clamped into the safe area. That is
  the only correction the cross axis gets, since flip never touches it. A
  menu larger than the safe area is pinned to its top-left corner. The
  `max()` in the clamp bounds keeps the lower limit at or below the upper
  one; without it `num.clamp` throws an `ArgumentError`.
- The side the menu landed on is written for [Scale origin](scale-origin.md)
  during layout, from `getPositionForChild`.
- `shouldRelayout` compares every geometric input. It does not compare the
  scale-origin holder, which is the same instance for the menu's whole life.

## Code

- `lib/src/menu_position_delegate.dart` — `MenuPositionDelegate`, `MenuPositionDelegate.getConstraintsForChild`, `MenuPositionDelegate.getPositionForChild`, `MenuPositionDelegate.shouldRelayout`, `_flipIfNeeded`, `_crossAxisHorizontal`, `_crossAxisVertical`
- `lib/src/menu_position.dart` — `MenuPosition`, `MenuAlignment`
- `lib/src/overlay_menu_placement.dart` — `OverlayMenuPlacement`
- `test/menu_position_delegate_test.dart`

## Reference behaviour

Read against the SDK at 3.41.9 for #28 (not pinned):

- Material `showMenu` never flips. It bakes the offset into the position and
  only clamps, so it can cover its anchor.
- `MenuAnchor` flips only when the other side fits, and otherwise pins the
  menu to the edge it overflowed; ADR-0006 departs from that. It mirrors the
  horizontal offset both ways, mirrors the vertical offset when flipping up,
  and drops it when flipping down.

## Cross-cutting invariants

**None.**

## Blast radius

- [Scale origin](scale-origin.md): the landed side becomes the origin, and
  it has to be decided in layout, before paint.
- [Anchor contract](anchor-contract.md): the anchor rectangle is the input.
- [Menu body layout](menu-body-layout.md): the body's height (`maxHeight`,
  header and footer) is the size the flip test uses.
- [Surface style](surface-style.md): `width` and `constraints` change the
  size the flip test uses.
- [Configuration objects](configuration-objects.md): `OverlayMenuPlacement`
  has value semantics.

## Known holes / open

- Text direction is never considered for `start` and `end`.
