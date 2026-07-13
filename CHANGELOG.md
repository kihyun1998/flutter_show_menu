## 1.0.1

### Fixed

- **fix**: The declared Flutter floor was dishonest. `pubspec.yaml` allowed `flutter: ">=3.10.0"`, but the code uses `WidgetStatePropertyAll` (in `Scrollbar` theming), which is the Flutter 3.22 rename of `MaterialStatePropertyAll` and does not exist before 3.22. A user on 3.10–3.21 could resolve this package and then hit a compile error. The floor is now `>=3.22.0`, the real minimum the code requires.

## 1.0.0

### Breaking

- **BREAKING**: `showOverlayMenu` and `OverlayMenuButton` take grouped configuration objects instead of 18 loose parameters. See the migration table below.
- **BREAKING**: `width`, `constraints`, and `decoration` moved onto `OverlayMenuStyle`, rejoining `maxHeight`.
- **BREAKING**: `OverlayMenuButton` no longer has `menuWidth` and `menuConstraints`. Use `style: OverlayMenuStyle(width: ..., constraints: ...)`.
- **BREAKING**: `OverlayMenuController.close()` now plays the exit animation, as selecting an item and tapping the barrier already did. `isClosed` still becomes true immediately; the widget leaves after the animation. Route changes and `closeAllOverlayMenus()` remain instant.

| Was | Now |
| --- | --- |
| `position:`, `alignment:`, `offset:` | `placement: OverlayMenuPlacement(...)` |
| `barrierDismissible:`, `barrierColor:`, `overlayChild:` | `barrier: OverlayMenuBarrier(dismissible: ..., color: ..., overlayChild: ...)` |
| `animationDuration:`, `animationCurve:` | `motion: OverlayMenuMotion(duration: ..., curve: ...)` |
| `width:`, `constraints:`, `decoration:` | `style: OverlayMenuStyle(width: ..., constraints: ..., decoration: ...)` |

All groups are const-constructible with defaults, so `showOverlayMenu(context: c, items: [...])` is unchanged.

### Fixed

- **fix**: An item whose `onTap` pushed a route returned `null` instead of its value. The push triggered a route auto-close that completed the future before the exit animation ended. The result is now fixed when the close is requested, so a navigating item still returns its selection.
- **fix**: `closeAllOverlayMenus()` called during a menu's exit animation overwrote the selected value with `null`. It now tears the menu down immediately, as documented, while still delivering the value the user chose.
- **fix**: Reusing one `OverlayMenuController` across two menus silently rebound it. Rebinding is now explicit and closes only the menu it is bound to.
- **fix**: `initialValue` centred its item against `maxHeight` rather than against the scroll viewport, which is smaller — the menu's padding and any header or footer sit outside it. The entry was pushed down by half the difference: 4px with default padding, 52px with a 48px header and footer. It now centres against the real viewport.
- **fix**: A menu flipped to the opposite side of its target — because it would have overrun the screen — still scaled open from the corner it would have used unflipped. It appeared to grow *into* the widget it was anchored to rather than out of it, by 10% of its height: 5.6px for a small menu, 30px for a 300px one. The scale origin now follows the side the menu actually landed on. See `docs/adr/0004-resolve-the-scale-origin-during-layout.md`.

### Changed

- **change**: Passing a `context` that is unmounted, or whose render object is not a `RenderBox`, now fails with a `FlutterError` naming `showOverlayMenu` and what to pass instead. It previously threw `type 'Null' is not a subtype of type 'RenderBox'`, or — in release builds, where Flutter's own check is an assert — silently opened the menu at the position of a widget that was gone.

### Added

- **feat**: `OverlayMenuButton` gains `initialValue` and `controller`, which `showOverlayMenu` had but the button had silently dropped.
- **feat**: `OverlayMenuPlacement`, `OverlayMenuBarrier`, and `OverlayMenuMotion`.
- **feat**: Value semantics — `==`, `hashCode`, and `copyWith` — on all four configuration objects and on `OverlayMenuItemStyle`, `OverlayMenuDividerStyle`, and `OverlayMenuScrollbarStyle`. Equality composes, so two styles differing only in a nested field compare unequal. `OverlayMenuMotion.curve` and `OverlayMenuBarrier.overlayChild` compare by identity, as their own types do.

### Internal

- An open menu's lifetime is now a single module. "Closed" had four representations; it has one. Every close path — selection, barrier, controller, route change, close-all — goes through it, which is what `docs/adr/0001-global-close-all-registry.md` required and only a comment enforced.
- Entry height and the initial-value scroll offset resolve in one pure module, so the arithmetic that predicts an item's position and the widget that lays it out can no longer disagree.
- The exit animator no longer catches `TickerCanceled`. It was unreachable: `TickerFuture` delivers that error to `orCancel`, never to the future the animation returns.
- Tests: 9 → 148, and `lib/` is at 100% line coverage. CI runs formatting, analysis, the suite, and a coverage floor on every pull request.
- See `docs/adr/0002-latch-the-result-when-close-is-requested.md` and `docs/adr/0003-group-menu-configuration-by-cohesion.md`.

## 0.7.0

- **feat**: `closeAllOverlayMenus()` — closes every open overlay menu app-wide at once, immediately and with a null result, without needing an `OverlayMenuController` reference. For non-route moments (session expiry, app backgrounding, event-driven cleanup); route changes already auto-close menus

## 0.6.1

- **feat**: `backgroundColor` and `selectedBackgroundColor` on `OverlayMenuItemStyle` — painted on the ink layer so InkWell hover/splash renders on top
- **fix**: Wrap each item in `Material` + `Ink` so hover/splash work correctly with item background colors
- **fix**: Scrollbar now hugs the right edge of the menu regardless of `padding`

## 0.6.0

- **BREAKING**: Remove `padding` and `textStyle` from `OverlayMenuItemStyle` — handle padding and text styling directly in the item's `child` widget
- **BREAKING**: Remove `padding` from `OverlayMenuItem` — use `Padding` widget inside `child` instead

## 0.5.0

- **BREAKING**: Remove `selected` from `OverlayMenuItem` — use `initialValue` on `showOverlayMenu` instead
- **BREAKING**: Remove `OverlayMenuSelectedStyle` and `selectedStyle` from `OverlayMenuStyle`
- **BREAKING**: Remove `prefixBuilder` from `OverlayMenuItem` and `OverlayMenuStyle`
- **BREAKING**: Remove `prefixSpacing` from `OverlayMenuStyle`
- **feat**: `initialValue` parameter for `showOverlayMenu` — auto-scrolls to the matching item when the menu opens

## 0.4.1

- **feat**: `height` parameter for `OverlayMenuDivider` and `OverlayMenuDividerStyle` — control total divider height independently from line thickness
- **feat**: `prefixSpacing` parameter for `OverlayMenuStyle` — configurable gap between prefix widget and item child (default `12.0`)

## 0.4.0

- **BREAKING**: Move `padding` from `showOverlayMenu` top-level parameter into `OverlayMenuStyle.padding`
- **BREAKING**: Remove `menuPadding` from `OverlayMenuButton` (use `style: OverlayMenuStyle(padding: ...)` instead)
- **feat**: `overlayChild` parameter — full-screen overlay above the barrier (e.g. drag-to-move area)

## 0.3.1

- **feat**: Hide header/footer dividers when the items list is empty
- **docs**: Translate all comments and doc comments to English
- **docs**: Add library-level doc comment for pub.dev API docs
- **docs**: Add doc comments to `MenuPosition` and `MenuAlignment` enum values
- **docs**: Add parameter descriptions to `showOverlayMenu`
- **fix**: Resolve broken dartdoc references (`OverlayMenuStyle.itemHeight`, `dividerColor`, `dividerThickness`)

## 0.3.0

- **feat**: Auto-close menu on route pop or new route push — no more orphaned overlays on navigation
- **feat**: `OverlayMenuController` — programmatically close a menu with safe idempotent `close()` / `isClosed` check
- **feat**: `controller` parameter for `showOverlayMenu`

## 0.2.0

- **feat**: `header`/`footer` fixed entries for `showOverlayMenu` and `OverlayMenuButton` — pinned above/below the scrollable items area
- **feat**: `OverlayMenuHeaderStyle`/`OverlayMenuFooterStyle` — independent styling for header/footer items (same options as `OverlayMenuItemStyle`)
- **feat**: `OverlayMenuDividerStyle` now supports `indent`/`endIndent`

## 0.1.1

- **feat**: Auto-scroll to selected item when menu opens (applies when `maxHeight` is set)

## 0.1.0

- **feat**: `showOverlayMenu` — imperative function API replacing Flutter's `showMenu`
- **feat**: `OverlayMenuButton` — declarative widget wrapper for tap-to-show menus
- **feat**: `OverlayMenuEntry` sealed class — base type for menu entries (`OverlayMenuItem`, `OverlayMenuDivider`)
- **feat**: `OverlayMenuItem` — menu item with value, child, enabled, onTap, selected state, prefixBuilder
- **feat**: `OverlayMenuDivider` — horizontal divider entry with color, thickness, indent
- **feat**: `OverlayMenuStyle` — grouped style options for menu container, items, selection, dividers, scrollbar
  - `OverlayMenuItemStyle` — height, borderRadius, hover/splash/highlight/focus colors, mouseCursor
  - `OverlayMenuSelectedStyle` — backgroundColor, textStyle, border for selected items
  - `OverlayMenuDividerStyle` — color, thickness
  - `OverlayMenuScrollbarStyle` — thumbColor, thickness, radius, thumbVisibility
- **feat**: `MenuPosition` (top, bottom, left, right) — controls which side of the target the menu appears
- **feat**: `MenuAlignment` (start, center, end) — controls cross-axis alignment
- **feat**: `maxHeight` with automatic scroll when content overflows
- **feat**: `prefixBuilder` — per-item or style-level prefix widget with selected state
- **feat**: Fade + scale enter/exit animation with configurable duration and curve
- **feat**: Automatic screen-edge flip when menu overflows viewport
- **feat**: Barrier dismiss support with optional barrier color
