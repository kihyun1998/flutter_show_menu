# Open Menu Registry and Close All

## What it is

The single app-wide set of live Open Menus, and `closeAllOverlayMenus()`,
which Closes every menu in it without the caller holding a Controller for
any of them.

## Governing decisions

- [ADR-0001 — global Close All via a static registry](../../adr/0001-global-close-all-registry.md#decision)
- `GLOSSARY.md`: **Open Menu Registry**, **Close All**.

## Design model

- One instance for the whole app, by design. It spans every Overlay and
  Navigator, and there is no variant scoped to a context.
- A menu joins when its lifetime object is constructed and leaves in
  teardown. A menu that is still animating out is therefore still in the
  set, so Close All reaches it.
- `closeAll` iterates over a copy, because tearing a menu down removes it
  from the set. Each menu gets an Instant Close with a `null` result. If a
  menu had already latched a selection, that selection is still delivered.
- The test seams are `length`, so a test can assert the registry is empty
  between cases (ADR-0001 asks for that), and `reset`, which empties the set
  without closing anything and is meant for `tearDown`.

## Code

- `lib/src/open_menu_registry.dart` — `OpenMenuRegistry`, `OpenMenuRegistry.instance`, `OpenMenuRegistry.closeAll`, `OpenMenuRegistry.length`, `OpenMenuRegistry.reset`, `closeAllOverlayMenus`
- `test/open_menu_registry_test.dart`

## Reference behaviour

**None.**

## Cross-cutting invariants

- [Result latched at Close request](../invariant/result-latched-at-request.md)
- [One Close path](../invariant/one-close-path.md)
- [Force decides Animated vs Instant](../invariant/close-force-decides-animation.md)

## Blast radius

- [Close lifecycle](close-lifecycle.md): register and deregister live there.
- [Route Auto-close](route-auto-close.md): the other Instant Close, and it
  should behave the same way on a menu.

## Known holes / open

**None.**
