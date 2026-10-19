# One Close path

## The fact

Every Close trigger calls `OpenMenu.close`. The resources an Open Menu holds
are the overlay entry, the awaited result, the registry membership, the
Controller binding and the route listeners. All of them are released in one
teardown, and running that teardown a second time does nothing.

## Why it is cross-cutting

The triggers live in different territories and know nothing about each
other: a gesture on the barrier, a tap on an entry, a method on the
Controller, a route's animation status and a top-level function. What they
share is the lifetime object they all reach. If one of them released
resources itself, the [Open Menu Registry](../territory/close-all-registry.md)
would hold a menu that is gone, or would lose one that is still on screen.

## Territories it holds in

- [Close lifecycle](../territory/close-lifecycle.md): `OpenMenu.close` and
  `_teardown`, the only place the resources are released.
- [Barrier](../territory/barrier.md): a barrier tap calls it.
- [Entry rendering](../territory/entry-rendering.md): selection calls it,
  through the menu widget's `_buildEntry`.
- [Controller](../territory/controller.md): `OverlayMenuController.close`
  calls it.
- [Route Auto-close](../territory/route-auto-close.md): both route listeners
  call it.
- [Open Menu Registry and Close All](../territory/close-all-registry.md):
  `closeAll` calls it once per live menu.

## What a violation looks like

A torn-down menu stays in the registry, so the `length` test seam reads
non-zero after the menu has gone and the next Close All touches a dead
menu. The other way round, a menu leaves the registry while it is still
animating out, and Close All misses it.

## Discovery history

- [ADR-0001](../../adr/0001-global-close-all-registry.md#consequences)
  required every Close to go through one `close()`, and at the time only a
  comment enforced it. "Closed" then had four representations, flagged in
  `GLOSSARY.md` under "Flagged ambiguities". The lifetime module that
  replaced them shipped in 1.0.0 (`CHANGELOG.md`, 1.0.0 "Internal").
  Count: 1.

## Where it will recur

Any new way to take a menu away, such as a timeout, a key binding or an
app-lifecycle hook. If it removes the overlay entry or completes the result
anywhere except `_teardown`, it breaks this.
