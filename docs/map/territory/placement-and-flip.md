# Placement and flip

## What it is

Where the menu box lands. It sits on one side of its anchor, aligned along
the other axis, shifted by an offset, flipped to the opposite side if it
would run off the screen, and finally clamped into the safe area.

## Governing decisions

**None.** The flip's offset rule was the maintainer's call on #28, chosen
over keeping it absolute, dropping it on a flip, or redefining `offset`
relative to the target; no record holds it.
[ADR-0004](../../adr/0004-resolve-the-scale-origin-during-layout.md#decision)
decides that the *scale origin* follows the side the menu landed on, not
the flip rule itself.
[ADR-0003](../../adr/0003-group-menu-configuration-by-cohesion.md#decision)
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
  only when the requested side would overrun the safe area on that side. The
  menu jumps sides instead of just being clamped, so as not to cover the
  widget it is anchored to. That is the intent, not a guarantee: a menu
  taller than the room on either side is clamped back over its anchor. The
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
- `MenuAnchor` flips only when the other side fits. It mirrors the
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

- The delegate flips even when the opposite side would overrun the screen
  too, and then the clamp decides. Material's `MenuAnchor` flips only when
  the other side fits.
- Text direction is never considered for `start` and `end`.
