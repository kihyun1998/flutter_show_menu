# Result latched at Close request

## The fact

An Open Menu's result is fixed by the **first** Close request. Nothing that
happens after it can change the value the caller's `await` receives: not a
second Close, not an Instant Close cutting the exit animation short, not a
side effect the selection set off.

## Why it is cross-cutting

A Close is not instantaneous. An Animated Close keeps the menu alive for the
length of the exit animation, and anything that runs inside that window can
reach the menu through another path. The sites below do not call one another
in a chain. Each one satisfies the fact on its own, by ordering or by
latching, so no territory-to-territory edge could carry it.

## Territories it holds in

- [Close lifecycle](../territory/close-lifecycle.md): `OpenMenu.close` stores
  the result on the first call and ignores the result argument of every
  later one.
- [Entry rendering](../territory/entry-rendering.md): an item reports its
  selection before it runs its own `onTap`, so an `onTap` that triggers a
  Close cannot get there first.
- [Controller](../territory/controller.md): `isClosed` turns true at the
  request, not when the animation ends.
- [Open Menu Registry and Close All](../territory/close-all-registry.md):
  Close All tears down a menu that is mid-exit and still delivers the
  selection it latched.
- [Route Auto-close](../territory/route-auto-close.md): a route change during
  the exit animation is an Instant Close, so it cuts the animation short and
  keeps the latched selection.

## What a violation looks like

`await showOverlayMenu(...)` returns `null` although the user picked an item.
It only shows when something Closes the menu while its exit animation is
playing. An item whose `onTap` pushes a route does this, and so does a
`closeAllOverlayMenus()` call that lands during the animation. A test that
selects and then awaits without triggering a second Close never sees it.

## Discovery history

- Two result-loss bugs, fixed together in 1.0.0: a navigating item returned
  `null`, and Close All during an exit animation overwrote the selection
  (`CHANGELOG.md`, 1.0.0 "Fixed"). Both are the context of
  [ADR-0002](../../adr/0002-latch-the-result-when-close-is-requested.md#context).
  Count: 2.

## Where it will recur

Any new Close trigger, and any callback that runs between a selection and
teardown. Ask: *if this fires during the exit animation, does it pass a
result?* If yes, it has to go through `OpenMenu.close`, which ignores it.
