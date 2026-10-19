# Anchor contract

## What it is

What `showOverlayMenu` needs from the `context` it is given. The context
must be mounted and must own a `RenderBox`. The menu takes the anchor
rectangle, the Overlay and the route from it, once, when it is shown.

## Governing decisions

**None.** The contract is stated in
[`CLAUDE.md`](../../../CLAUDE.md#identity--invariants-the-boundary) and
nowhere in a decision record.
[ADR-0003](../../adr/0003-group-menu-configuration-by-cohesion.md#decision)
keeps `context` as a top-level parameter ("the anchor") but does not decide
what the anchor must be.

## Design model

- An unmounted context, or one whose render object is not a `RenderBox`,
  throws a `FlutterError` that names `showOverlayMenu` and says what to pass
  instead. It is checked rather than cast because the failure is a
  programming error, and the caller needs to be told which context is
  wrong. The check runs in release builds too, because Flutter's own check
  for an inactive element is an `assert`. Without ours, release would read a
  stale render object and open the menu where a widget used to be.
- The anchor rectangle is read once, in global coordinates, when the menu is
  shown. The menu does not follow its anchor if the anchor later moves or
  resizes.
- `Overlay.of(context)` picks the overlay the entry goes into.
  `ModalRoute.of(context)` picks the route that drives Auto-close.
- Derived from the source; there is no design record above it.

## Code

- `lib/src/overlay_menu.dart` — `_anchorBoxOf`, `showOverlayMenu`
- `test/anchor_context_test.dart`

## Reference behaviour

- [theflow, Step 1](../../agents/theflow.md#step-1--reference-routing-table)
  records that an unmounted element's `renderObject` throws only inside an
  `assert` (#8).

## Cross-cutting invariants

**None.**

## Blast radius

- [Placement and flip](placement-and-flip.md): the anchor rectangle is the
  delegate's main input.
- [Route Auto-close](route-auto-close.md): the route comes from the same
  context.
- [OverlayMenuButton](overlay-menu-button.md): passes its own context as
  the anchor.

## Known holes / open

- Because the anchor rectangle is read only once, a menu stays where it
  opened if its anchor scrolls away underneath it. No record says whether
  that is intended.
