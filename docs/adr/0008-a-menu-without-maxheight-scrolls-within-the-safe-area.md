# A menu without maxHeight scrolls within the safe area

## Context

Without `style.maxHeight`, the menu body was a plain padded `Column`. `MenuPositionDelegate.getConstraintsForChild` limits the menu to the safe area, so a menu with more entries than fit overflowed: 30 items on an 800x600 screen overflowed by 848px (#46). Debug painted the overflow stripes. Release cut the entries off, and the ones past the cut could not be reached.

With `maxHeight`, the body was already a scrolling layout: padding, a pinned header, the items in a scroll view, a pinned footer. It centres `initialValue` in the real viewport (#5, see `docs/map/territory/entry-metrics.md`) and applies `scrollbarStyle`.

Measured with widget tests on a copy of the repository, Flutter 3.41.9, the full suite included:

- Using the `maxHeight` layout without `maxHeight` keeps short menus pixel-identical: the menu rect and every entry rect, with a header and footer, `width`, `constraints`, asymmetric padding and `scrollbarStyle`. Flip, clamp and the scale origin do not change. A 30-item menu scrolls, and its last item can be selected.
- Wrapping the whole body in a scroll view, as Material does, also fixes the overflow. But the header and footer scroll away, unlike with `maxHeight`, `initialValue` lands 4–53px off-centre because the offset counts only the items, and `scrollbarStyle` is ignored.
- A debug warning would only add "use `maxHeight`" to the overflow error Flutter already reports, and documenting the limit changes nothing at runtime. Both leave release truncating entries.

Material's `showMenu` and `MenuAnchor` always wrap their body in a `SingleChildScrollView` (`popup_menu.dart`, `menu_anchor.dart`, SDK 3.41.9). Neither has a header or footer.

## Decision

Without `maxHeight`, the body uses the same layout as with it, and the safe area the delegate allows is the limit. The header and footer stay pinned, and only the items scroll. The scroll controller always exists, and `initialValue` is brought into view whether or not `maxHeight` is set.

This was the maintainer's call (#46), a judgement made on the measurements above.

## Considered Options

- **Wrap the whole body in a scroll view, like Material.** Rejected: the header and footer behave differently with and without `maxHeight`, and the `initialValue` offset would need the padding and header added to it.
- **Warn in debug.** Rejected: Flutter already reports the overflow, and release still truncates.
- **Document that a long menu needs `maxHeight`.** Rejected: release still truncates.

## Consequences

- Only menus that overflowed before render differently: they scroll instead of being cut off. Menus that fit are unchanged.
- `scrollbarStyle` applies without `maxHeight` too.
- A widget test that finds by type now sees a `SingleChildScrollView` and a `Scrollbar` in every menu.
- Scroll physics and scrollbar behaviour on iOS and desktop were not measured.
- No public API changes.
