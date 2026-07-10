# Resolve the scale origin during layout, and read it at paint

## Context

An Open Menu scales open from 0.9, and it should grow out of the widget it is anchored to. The origin of that scale is the corner of the menu nearest its target: a menu below its target grows from its top edge, a menu to the left of its target grows from its right edge.

`MenuPositionDelegate` may **flip** a menu to the opposite side of its target when it would overrun the screen. The origin did not follow. Anchoring a menu at the bottom of the screen and asking for `MenuPosition.bottom` put it above the target while it still grew from `Alignment.topLeft` — the edge furthest from the target, so the menu appeared to grow *into* the widget rather than out of it. The bottom edge moved by 10% of the menu's height: 5.6px for a small menu, 30px for a 300px one.

The cause was structural, not a typo. `ScaleTransition` takes its alignment from the widget tree, which is built **before** layout. The flip is decided inside `getPositionForChild`, during **layout**, because it needs the menu's own size to know whether the menu overflows. The widget cannot know which corner to use at the moment it must choose one.

## Decision

Resolve the origin where the flip is decided, and apply it where the transform is applied.

- `_flipIfNeeded` returns the side the menu **landed on**, not the side it was asked for.
- `MenuPositionDelegate` writes `resolveScaleOrigin(landedOn, alignment)` into a `MenuScaleOrigin` holder during `getPositionForChild`.
- `MenuScaleTransition`, a `SingleChildRenderObjectWidget`, replaces `ScaleTransition`. Its render object reads the holder in `paint`, `applyPaintTransform`, and `hitTestChildren`.

Paint runs after layout in the same frame, so the value is always current. There is no extra rebuild and no wrong first frame.

`resolveScaleOrigin` is a pure function of `(MenuPosition, MenuAlignment)` and lives beside the geometry it belongs to.

## Considered Options

- **Report the flip back to the widget and rebuild.** A `ValueNotifier<bool>` the widget listens to. Rejected: the correction lands one frame late, and the first painted frame — at scale 0.9, where the error is largest — is the wrong one. Notifying during layout also risks `markNeedsBuild` being called during layout.
- **Predict the overflow in `build`.** Requires the menu's size before it is laid out, so it would need an API for callers to declare a fixed size. Rejected: constrains the interface to work around an internal ordering problem.
- **Give `ScaleTransition` a custom `AlignmentGeometry` that resolves late.** `RenderTransform` resolves its alignment during paint, so this would have worked. Rejected as impossible: `AlignmentGeometry` declares private abstract members (`_x`, `_start`, `_y`), so it cannot be implemented outside the Flutter framework.
- **Accept it and record why.** The artefact lasts one animation duration and only when the menu flips. Rejected: 30px on a tall menu reads as the menu emerging from the wrong place, and the fix costs one small render object.

## Consequences

- `ScaleTransition` is gone from the menu. Any test asserting on `ScaleTransition.alignment` breaks — and twelve did. Those tests were coupled to the implementation rather than to behaviour; they now assert that the origin corner of the rendered rect holds still while the menu scales, which is true of any correct implementation. That is the seam they should have used.
- The render object must override `applyPaintTransform`. Without it, `localToGlobal` would not account for the scale, and a test measuring the menu's rendered geometry would see the untransformed rect. `hitTestChildren` applies the same transform, so an entry stays tappable mid-animation.
- `MenuScaleOrigin` is mutable state written during layout. It is safe because it is read only during paint, which follows layout, and because when the animation has finished the scale is 1 and the origin has no effect.
- `RenderMenuScale` holds its animation and origin as `final`. The menu's `State` creates both once and never swaps them, so there is no `updateRenderObject`.
