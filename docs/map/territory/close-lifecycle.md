# Close lifecycle

## What it is

The lifetime of one Open Menu, from `showOverlayMenu` to teardown. It owns
the overlay entry, the awaited result, the registry membership, the
Controller binding and the route listeners. It decides what happens when
two Closes overlap.

## Governing decisions

- [ADR-0002 — latch the result when Close is requested](../../adr/0002-latch-the-result-when-close-is-requested.md#decision)
  covers the phases, the latch and how overlapping Closes resolve.
- [ADR-0001 — global Close All registry](../../adr/0001-global-close-all-registry.md#consequences)
  requires registration to go through the single Close path.
- `GLOSSARY.md`: **Close**, **Animated Close**, **Instant Close**.

## Design model

- Every Close trigger calls `OpenMenu.close`: a barrier tap
  ([Barrier](barrier.md)), a selection
  ([Entry rendering](entry-rendering.md), through the menu widget's
  `_buildEntry`), `OverlayMenuController.close` ([Controller](controller.md)),
  the two route listeners ([Route Auto-close](route-auto-close.md)) and
  `closeAll` ([Open Menu Registry and Close All](close-all-registry.md)).
  `_teardown` is the only place the entry, the result, the registry
  membership, the Controller binding and the route listeners are released,
  and a second teardown does nothing. ADR-0001's Consequences require this.
  A trigger that released anything itself would leave a gone menu in the
  registry (its `length` reads non-zero after the menu has gone) or drop a
  menu still animating out, which Close All would then miss. Any new way to
  take a menu away — a timeout, a key binding, an app-lifecycle hook — calls
  `OpenMenu.close` and releases nothing outside `_teardown`.
- One phase variable, not a flag per collaborator: `open` → `closing`
  (result latched, exit animation may be playing) → `closed` (resources
  released, result delivered). "Closed" once had four representations
  (`GLOSSARY.md`, "Flagged ambiguities").
- The first Close stores the result and decides whether the exit animation
  plays. While `closing`, an Instant Close tears down at once and an
  Animated Close is ignored. While `closed`, every Close is ignored.
- Teardown runs once, in this order: leave the registry, stop listening to
  the route, drop the exit animator, remove the overlay entry, mark the
  Controller closed and unbind it if it is still bound to this menu (see
  [Controller](controller.md)), then complete the result with the latched
  value.
- When an Instant Close preempts an exit animation, the `whenComplete`
  attached to that animation never runs (see
  [Enter/exit motion](enter-exit-motion.md)). The preempting Close has
  already torn down, so nothing is lost.
- Construction does the joining: it binds the Controller, adds the route
  listeners and registers. `showOverlayMenu` gives it the entry only after
  creating the entry, which is why `entry` is a setter.

## Code

- `lib/src/open_menu.dart` — `OpenMenu`, `OpenMenu.close`, `OpenMenu.result`, `OpenMenu.entry`, `_teardown`, `_Phase`
- `lib/src/overlay_menu.dart` — `showOverlayMenu`
- `test/overlay_menu_close_test.dart`

## Reference behaviour

- [ADR-0002, Consequences](../../adr/0002-latch-the-result-when-close-is-requested.md#consequences)
  records the SDK behaviour that makes the missing `catch` safe: a cancelled
  `TickerFuture` never completes its primary future.
- Not compared with Material `showMenu`. That one is a route, and its result
  is decided by `Navigator.pop`.

## Cross-cutting invariants

- [Result latched at Close request](../invariant/result-latched-at-request.md)
- [Force decides Animated vs Instant](../invariant/close-force-decides-animation.md)

## Blast radius

- [Controller](controller.md): binding, `isClosed` and unbinding happen here.
- [Route Auto-close](route-auto-close.md): the listeners are added in the
  constructor and removed in teardown.
- [Open Menu Registry and Close All](close-all-registry.md): registers in
  the constructor and deregisters in teardown.
- [Enter/exit motion](enter-exit-motion.md): Close relies on the exit
  animator's contract (completes only when the animation finishes).
- [Entry rendering](entry-rendering.md) and [Barrier](barrier.md): the two
  triggers that come from widgets.

## Known holes / open

**None.**
