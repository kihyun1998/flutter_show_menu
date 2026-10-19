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
- Nothing decides the export style: which lines use `show` and which export
  a whole file.

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
  later.
- Never exported: the position delegate, the scale-origin render object, the
  entry view and the metrics module. Tests reach them through
  `package:flutter_show_menu/src/...`, and callers should not.
- The library doc comment is written for a caller, so it stays complete when
  the map changes. `docs/` does not ship to pub.dev.

## Code

- `lib/flutter_show_menu.dart` — `showOverlayMenu`, `OverlayMenuController`, `closeAllOverlayMenus`, `OverlayMenuButton`, `OverlayMenuStyle`, `MenuPosition`

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

- Because seven files are exported whole, a public helper added to one of
  them becomes public API without the barrel changing. Nothing checks this.
  Whether to move those lines to `show` has not been decided.
