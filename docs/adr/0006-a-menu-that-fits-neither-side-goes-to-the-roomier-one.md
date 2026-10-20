# A menu that fits neither side goes to the roomier one

## Context

`MenuPositionDelegate` flipped a menu to the opposite side of its target whenever the requested side would overrun the safe area, without checking whether the opposite side fit either. When neither side fit, the menu flipped anyway and the clamp pulled it back over the target (#35).

When neither side fits, covering the target cannot be avoided: the menu is clamped into the safe area, and any position there overlaps the target. What the policy decides is how much it covers and which side the scale origin (ADR-0004) follows. The overlap is the menu's main-axis size minus the room on the side it lands on, so the side with more room always covers less.

Measured by reimplementing `_flipIfNeeded` and the clamp, on a 600px screen with a 50px target, 13,320 cases:

- The three options differ only when neither side fits.
- Always flipping covers more than necessary whenever the requested side was the roomier one. Flipping only when the other side fits covers more whenever the requested side was the tighter one. That is 549 cases each, by up to the whole target.
- Always flipping can leave the scale origin 100–180px away from the target, because the menu lands pinned to the far edge.

## Decision

When the requested side would overrun the safe area, the menu flips if the opposite side has more room than the requested side. Otherwise it stays, and the clamp applies. On a tie it stays on the requested side. Room on a side is the distance from the target's edge to the safe area's edge.

This is the same as "flip when the opposite side fits; when neither fits, take the side with more room". A requested side that overruns has less room than the menu plus its offset, and an opposite side that fits has at least that much, so it always has more room.

The policy was the maintainer's call (#35), a judgement made on the measurements above. The equivalence and the room definition are derived.

## Considered Options

- **Always flip, then clamp** (the behaviour before this change). Rejected: it covers more of the target than necessary whenever the requested side had more room, and its scale origin can point away from the target.
- **Flip only when the opposite side fits; otherwise stay and clamp.** This is what Material's `MenuAnchor` does (`_MenuLayout.getPositionForChild`, SDK 3.41.9). Rejected: it covers more of the target than necessary whenever the requested side was the tighter one.
- **Shrink the menu to the room on one side** so that it never covers the target. Not decided here; see #42.

Material's `showMenu` never flips.

## Consequences

- Positions change only when the menu fits on neither side and the requested side has at least as much room as the opposite one (2,184 of the 13,320 measured cases). Every case where the opposite side fits behaves as before.
- ADR-0005 still governs what a flip does to the offset.
- Side switches now also happen where the two sides have equal room. A relayout while the menu is open (a rotation, a padding change) can move it to the other side there. The other options switch sides at other points, and a switch is visible only during the entry animation.
- `test/menu_position_delegate_test.dart` covers all four directions, a tie, a flip to the roomier side and the scale origin.
- No public API changes.
