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
  - `OverlayMenuItemStyle` — height, padding, borderRadius, textStyle, hover/splash/highlight/focus colors, mouseCursor
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
