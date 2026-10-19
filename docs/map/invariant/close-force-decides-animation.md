# Force decides Animated vs Instant

## The fact

A Close a human asked for is an **Animated Close**. Force-cleanup is an
**Instant Close**. Who made the call does not decide which: the Controller
is caller-driven and animated, and Close All is caller-driven and instant.
The terms are defined in `GLOSSARY.md`.

## Why it is cross-cutting

Each trigger passes its own `animated:` flag to `OpenMenu.close`, so each
trigger site holds half of the rule. The lifetime only decides what happens
when two Closes overlap.

## Territories it holds in

- [Barrier](../territory/barrier.md): a tap passes `animated: true`.
- [Entry rendering](../territory/entry-rendering.md): a selection passes
  `animated: true`.
- [Controller](../territory/controller.md): `close()` passes
  `animated: true`.
- [Route Auto-close](../territory/route-auto-close.md): both listeners pass
  `animated: false`.
- [Open Menu Registry and Close All](../territory/close-all-registry.md):
  `closeAll` passes `animated: false`.
- [Close lifecycle](../territory/close-lifecycle.md): when an Animated Close is
  already playing, a second Instant Close tears down at once and a second
  Animated Close is ignored.
- [Enter/exit motion](../territory/enter-exit-motion.md): an Animated Close
  falls back to Instant when no exit animator is attached.

## What a violation looks like

After a route change or Close All, a menu lingers for about one animation
duration. Or a human action makes the menu vanish without its exit
animation.

## Discovery history

- [ADR-0001](../../adr/0001-global-close-all-registry.md#considered-options)
  considered an animated Close All and rejected it.
- `OverlayMenuController.close()` was instant until 1.0.0 made it animated
  (`CHANGELOG.md`, 1.0.0 "Breaking").
  Count: 2.

## Where it will recur

Any new trigger. Ask: *did a human ask for this?* If yes, pass
`animated: true`. If it is cleanup after the menu has stopped making sense,
pass `animated: false`.
