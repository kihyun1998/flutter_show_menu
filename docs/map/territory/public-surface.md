# Public surface

## What it is

What a caller can import. The barrel `lib/flutter_show_menu.dart` decides
which names are public API, and its library doc comment is the text pub.dev
shows on the package's API landing page.

## Governing decisions

- [ADR-0003](../../adr/0003-group-menu-configuration-by-cohesion.md#consequences)
  makes the four configuration objects part of the 1.0.0 surface. Adding a
  field to one is not breaking; moving a field between them is.
- [ADR-0001](../../adr/0001-global-close-all-registry.md#decision) makes
  `closeAllOverlayMenus()` a public top-level function.
- [ADR-0007](../../adr/0007-pin-the-public-names-the-barrel-exports.md#decision)
  keeps the whole-file exports and pins the full list of public names in a
  test.

## Design model

Read from the source; nothing in a record says it.

- Three export lines use `show`, and that is what keeps the lifetime and the
  registry private. `open_menu.dart` exports only `OverlayMenuController`,
  hiding `OpenMenu` and `ExitAnimator`. `open_menu_registry.dart` exports only
  `closeAllOverlayMenus`, hiding `OpenMenuRegistry`. `overlay_menu.dart`
  exports only `showOverlayMenu`.
- The other seven lines export whole files. These are the position enums, the
  barrier, the button, the entry types, motion, placement and style. Every
  public name declared in those files is public API, including names added
  later, so the test pins all 18 names. Adding one means adding it to the
  pinned list in the same change.
- Never exported: the position delegate, the scale-origin render object, the
  entry view and the metrics module. Tests reach them through
  `package:flutter_show_menu/src/...`, and callers should not.
- The library doc comment is written for a caller, so it stays complete when
  the map changes. `docs/` does not ship to pub.dev.

## Code

- `lib/flutter_show_menu.dart` — `showOverlayMenu`, `OverlayMenuController`, `closeAllOverlayMenus`, `OverlayMenuButton`, `OverlayMenuStyle`, `MenuPosition`
- `tool/check_surface.dart` — `scanSurface`
- `test/check_surface_test.dart` — `_publicNames`

## Reference behaviour

**None.**

## Cross-cutting invariants

**None.**

## Blast radius

- [Release and publish](release-and-publish.md): any change to what is
  exported is a version decision. Removing or renaming a name is breaking.
- [Configuration objects](configuration-objects.md): all four groups and the
  nested styles are exported whole.
- [Close lifecycle](close-lifecycle.md),
  [Controller](controller.md) and
  [Open Menu Registry and Close All](close-all-registry.md): each exports one
  name through `show`, and its lifetime type has to stay hidden.
- [Placement and flip](placement-and-flip.md): `MenuPosition` and
  `MenuAlignment` are exported. The delegate is not.
- [Entry rendering](entry-rendering.md): the entry types are exported. The
  view that draws them is not.
- [OverlayMenuButton](overlay-menu-button.md): exported whole.

## Known holes / open

- Members added to a class that is already public are not pinned.
- The scan reads only what `dart format` leaves at column 0. A form it does
  not know fails the test rather than passing.
