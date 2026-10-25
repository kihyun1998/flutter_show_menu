# Configuration objects

## What it is

The const value objects that configure a menu: `OverlayMenuPlacement`,
`OverlayMenuBarrier`, `OverlayMenuMotion`, `OverlayMenuStyle`, and the style
classes nested in it. All of them have `==`, `hashCode` and `copyWith`.

## Governing decisions

- [ADR-0003 — group menu configuration by cohesion](../../adr/0003-group-menu-configuration-by-cohesion.md#decision)

## Design model

- Every group can be built as a const with defaults, so the shortest call,
  `showOverlayMenu(context: c, items: [...])`, needs none of them.
- Equality checks `runtimeType` first and then every field. `Curve` and
  `overlayChild` compare by identity, because their own types have no value
  equality. The const curves on `Curves` are canonicalised, so they still
  compare equal.
- `copyWith` resolves each field as `argument ?? this.field`, so it cannot
  set a field back to `null`.
- Calling `copyWith()` with no arguments must return an equal object. The
  value-semantics test checks this for all seven classes, which is what
  covers the right-hand side of each `??` (#7).
- An equality test builds its values at runtime and first asserts
  `identical(a, b)` is false. Dart canonicalises same-argument `const`
  values to one instance, so a const-built pair would pass on identity
  alone (#7).
- Adding a field is not a breaking change. Moving a field between objects
  is (ADR-0003, Consequences).
- Configuration equality does not make rebuilds cheaper. The framework
  compares the widget, not the objects inside it (#7).

## Code

- `lib/src/overlay_menu_placement.dart` — `OverlayMenuPlacement.copyWith`
- `lib/src/overlay_menu_barrier.dart` — `OverlayMenuBarrier.copyWith`
- `lib/src/overlay_menu_motion.dart` — `OverlayMenuMotion.copyWith`
- `lib/src/overlay_menu_style.dart` — `OverlayMenuStyle.copyWith`, `OverlayMenuItemStyle.copyWith`, `OverlayMenuDividerStyle.copyWith`, `OverlayMenuScrollbarStyle.copyWith`
- `test/configuration_value_semantics_test.dart`

## Reference behaviour

- [lessons, Step 1](../../agents/lessons.md#step-1--이슈-먼저-본문-근거도-실측-대상)
  records the `framework.dart` reading behind "equality does not
  short-circuit rebuilds" (#7).

## Cross-cutting invariants

**None.**

## Blast radius

- [OverlayMenuButton](overlay-menu-button.md): takes the same objects.
- [Placement and flip](placement-and-flip.md), [Barrier](barrier.md),
  [Enter/exit motion](enter-exit-motion.md),
  [Surface style](surface-style.md): each reads one of these objects. A new
  field there needs a field here, with equality and `copyWith`.

## Known holes / open

- `copyWith` cannot clear a nullable field.
