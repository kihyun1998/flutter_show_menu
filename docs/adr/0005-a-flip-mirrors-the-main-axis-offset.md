# A flip mirrors the main-axis offset

## Context

`OverlayMenuPlacement.offset` is an absolute shift in screen pixels on both axes. A `bottom` menu gets an 8px gap from `Offset(0, 8)`; a `top` menu needs `Offset(0, -8)` for the same gap.

`MenuPositionDelegate` flips a menu to the opposite side of its target when the requested side would overrun the screen. It re-added the offset unchanged, so the gap pointed the wrong way after the flip. Measured on an 800x600 screen with a 150x200 menu and an 8px main-axis gap, in all four directions, the flipped menu overlapped its target by 8px.

The caller cannot work around this. Whether a menu flips depends on its size and the anchor's position at layout time, so no single offset produces a gap on both sides.

## Decision

On a flip, the main-axis component of the offset is mirrored. A gap stays a gap, and a deliberate overlap stays an overlap. The cross-axis component is applied unchanged, flipped or not.

This was the maintainer's call (#28).

## Considered Options

- **Keep it, and document `offset` as an absolute shift.** No code change. Rejected: a gap the caller asked for turns into an overlap exactly when the menu flips, and nothing the caller can set prevents it.
- **Drop the main-axis offset on a flip.** The flipped menu sits flush against its target, with no overlap and no gap. This is what Material's `MenuAnchor` does when it flips a menu downward. Rejected: it loses the gap the caller asked for.
- **Redefine the main axis of `offset` as a distance away from the target.** A flip would then need no special case. Rejected: every `top` or `left` menu that uses a negative offset today would move to the other side, which is a breaking change to the 1.0 surface.

For reference, read against the Flutter SDK at 3.41.9: `showMenu` never flips and only clamps. `MenuAnchor` mirrors the horizontal offset in both directions, mirrors the vertical offset when flipping up, and drops it when flipping down. This decision agrees with three of `MenuAnchor`'s four cases and is the same in all four directions.

## Consequences

- Behaviour changes only when a menu flips and its main-axis offset is non-zero. Before this change, that case always rendered as an overlap.
- The decision to flip is unchanged. It is still made from the position with the offset applied, before mirroring.
- `test/menu_position_delegate_test.dart` covers the four flip directions with a non-zero offset on both axes.
- Whether to flip at all when the opposite side also overflows is a separate question. This record does not decide it.
