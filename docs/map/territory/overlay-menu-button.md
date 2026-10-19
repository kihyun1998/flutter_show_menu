# OverlayMenuButton

## What it is

A widget that opens a menu when its child is tapped. It is a shortcut over
`showOverlayMenu` that takes the same configuration.

## Governing decisions

- [ADR-0003](../../adr/0003-group-menu-configuration-by-cohesion.md#consequences)
  makes the button take the same configuration objects as
  `showOverlayMenu`. As a result it gained `initialValue` and `controller`,
  and its configuration can no longer drift from the function's.

## Design model

- The button's own context is the anchor.
- A non-null result calls `onSelected`. A `null` result calls `onCanceled`.
- With `enabled` false, a tap does nothing.

## Code

- `lib/src/overlay_menu_button.dart` — `OverlayMenuButton`, `_show`
- `test/overlay_menu_button_test.dart`

## Reference behaviour

**None.**

## Cross-cutting invariants

**None.**

## Blast radius

- [Anchor contract](anchor-contract.md): its context has to meet the
  contract.
- [Configuration objects](configuration-objects.md): it forwards them
  unchanged.
- [Controller](controller.md): it passes the Controller through.
- [Entry rendering](entry-rendering.md): an item whose value is `null`
  reaches `onCanceled`.

## Known holes / open

- Selecting an item whose value is `null` calls `onCanceled`. See
  [Entry rendering](entry-rendering.md#known-holes--open).
