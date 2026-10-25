# Scale origin

## What it is

The point the menu grows from while it scales between 0.9 and 1. It is the
corner or edge nearest the anchor, on the side the menu actually landed on.

## Governing decisions

- [ADR-0004 — resolve the scale origin during layout, and read it at paint](../../adr/0004-resolve-the-scale-origin-during-layout.md#decision)

## Design model

- ADR-0004's Decision and Consequences hold the model: which side to use,
  the holder written in layout and read in paint, `applyPaintTransform`,
  hit testing, and no `updateRenderObject`. It is not repeated here.
- Not in the ADR: the holder starts at `Alignment.center`, which applies only
  before the first layout. The 0.9 starting scale belongs to
  [Enter/exit motion](enter-exit-motion.md).

## Code

- `lib/src/menu_scale_origin.dart` — `resolveScaleOrigin`, `MenuScaleOrigin`, `MenuScaleTransition`, `RenderMenuScale`, `RenderMenuScale.paint`, `RenderMenuScale.applyPaintTransform`, `RenderMenuScale.hitTestChildren`
- `lib/src/overlay_menu.dart` — `_scaleOrigin`
- `test/menu_scale_origin_test.dart`

## Reference behaviour

- [ADR-0004, Considered Options](../../adr/0004-resolve-the-scale-origin-during-layout.md#considered-options)
  explains why a late-resolving `AlignmentGeometry` is impossible: it
  declares private abstract members.
- [lessons, Step 3/4](../../agents/lessons.md#step-34--설계-확정--redgreen)
  names the seam to test at: which point the menu keeps fixed as it grows.

## Cross-cutting invariants

**None.**

## Blast radius

- [Placement and flip](placement-and-flip.md): writes the origin during
  layout.
- [Enter/exit motion](enter-exit-motion.md): supplies the scale animation.

## Known holes / open

**None.**
