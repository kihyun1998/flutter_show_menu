# Surface style

## What it is

The menu surface itself: its background, corner radius, padding, extra
decoration and size limits, and what each falls back to when the caller
leaves it out.

## Governing decisions

- [ADR-0003](../../adr/0003-group-menu-configuration-by-cohesion.md#decision)
  moved `width`, `constraints` and `decoration` into `OverlayMenuStyle`, next
  to `maxHeight`. Nothing decides the fallback values.

## Design model

- The surface is a `Material` with elevation 8 (not configurable) and
  anti-aliased clipping. Its colour falls back to the theme's
  `colorScheme.surfaceContainer`, its radius to 8 and its padding to 4
  vertically.
- Wrapping order, from the inside out: the `Material`, then the decoration,
  then `width`, then `constraints`.
- The header and footer styles are type aliases of the item style.

## Code

- `lib/src/overlay_menu.dart` — `_buildMenu`
- `lib/src/overlay_menu_style.dart` — `OverlayMenuStyle`, `OverlayMenuItemStyle`, `OverlayMenuDividerStyle`, `OverlayMenuHeaderStyle`, `OverlayMenuFooterStyle`
- `test/menu_chrome_test.dart`

## Reference behaviour

**None.** The fallbacks have never been compared with Material `showMenu`'s
defaults.

## Cross-cutting invariants

**None.**

## Blast radius

- [Placement and flip](placement-and-flip.md): `width` and `constraints`
  change the size the flip test uses.
- [Menu body layout](menu-body-layout.md): `padding` and `maxHeight` shape
  the body.
- [Entry rendering](entry-rendering.md) and
  [Entry metrics](entry-metrics.md): read the item and divider styles.
- [Configuration objects](configuration-objects.md): every style class has
  value semantics.

## Known holes / open

- Elevation is fixed at 8.
