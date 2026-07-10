# Latch the result when Close is requested, not when the animation ends

## Context

An Open Menu could be Closed from five places: selecting an item, tapping the barrier, an `OverlayMenuController`, a route change (Auto-close), and `closeAllOverlayMenus()` (Close All). "Closed" was represented four ways — a `removed` flag guarding `entry.remove()`, `_isClosed` on the Controller, `completer.isCompleted`, and `_dismissed` inside the menu widget — and the awaited result was only handed to the completer *after* the exit animation had finished.

For those ~150ms the menu was live with an undecided result, so whichever Close reached the completer first won. Two bugs followed, both reachable by ordinary use:

- An item whose `onTap` pushed a route lost its value. The push fired a route Auto-close that completed the future with null before the reverse animation ended, so `await showOverlayMenu(...)` returned null instead of the selection. Menu items that navigate are a common pattern.
- `closeAllOverlayMenus()` called during a dismiss animation overwrote the selection with null, for the same reason.

Separately, the animated Close (`_dismiss`) and the instant Close (`close`) were distinct code paths that raced. Their collision was caught as `on TickerCanceled` — an exception used as control flow across a seam. And `close()` maintained the Controller's invariant by writing its private fields from outside.

ADR-0001 already required that every Close funnel through one path so the registry stays accurate. That requirement lived in a comment.

## Decision

Give an Open Menu's lifetime a module (`OpenMenu`). It owns the overlay entry, the completer, the registry membership, the Controller binding, and the route listeners, behind **one** state variable with three phases: `open`, `closing`, `closed`.

`close(result, {required bool animated})` is the only way through:

- The **first** Close latches the result and moves to `closing`. Whether the exit animation plays is decided here.
- A later **instant** Close preempts a running exit animation and tears down at once. It cannot change the latched result.
- A later **animated** Close is ignored.

Which Closes animate is decided by force, not by who asked: selection, barrier tap, and `Controller.close()` animate; route Auto-close and Close All are instant. `Controller.close()` previously skipped the exit animation, which contradicted the README's documented enter/exit animation.

The menu widget registers an exit-animation capability with the lifetime on `initState` and drops it on `dispose`. An animated Close with no animator registered degrades to an instant one — which is the correct behaviour when the widget is not mounted, obtained without a special case.

## Considered Options

- **Last Close wins** — let a late Close overwrite the result with null. Rejected: a user who selected "Save" and then hit a session-expiry Close All would have their selection silently discarded. It also preserves the bug rather than fixing it.
- **First Close wins entirely; no preemption** — treat Close as purely idempotent, so an instant Close during an animation is a no-op. Rejected: Close All would then take ~150ms to remove a menu, contradicting ADR-0001's "closes each Open Menu immediately".
- **Widget owns the ordering; the lifetime reacts to a signal** — expose `closing` as a listenable and let the widget report back when its exit animation finished. Rejected: teardown would depend on a report from a widget that may be unmounted first, so a menu could leak into the registry — the exact failure ADR-0001 warns about.
- **Lifetime owns the `AnimationController`** — most cohesive, but `vsync` only comes from a `TickerProvider`, which would tie the lifetime back to a widget's lifecycle and forfeit testing it without an `Overlay`.

## Consequences

- `Controller.close()` now plays the exit animation. `isClosed` still flips immediately, so the state is observable before the widget has gone; the widget lingers for the animation's duration.
- A menu in `closing` is still in the Open Menu Registry, by design — Close All must be able to reach it. Deregistration happens only at teardown.
- The old `on TickerCanceled` handler is gone, and nothing replaced it. `TickerFuture` delegates `then`/`whenComplete` to its primary completer, while `Ticker.dispose()` and `Ticker.stop(canceled: true)` complete only the secondary one, behind `orCancel`. Awaiting the future the exit animation returns therefore never yields a `TickerCanceled`; when an instant Close disposes the ticker, that future simply never resolves. The handler was unreachable. `test/exit_animation_cancellation_test.dart` pins this behaviour so a future Flutter cannot change it silently.
- A consequence worth stating: when an instant Close preempts the exit animation, the `whenComplete(_teardown)` attached to the animator **never runs**. Teardown is correct anyway because the instant Close performed it synchronously, and the phase variable makes teardown idempotent. The suspended `await` is not a leak — the unresolved completer, its future, and the waiting continuation reference only one another.
- The result of a Close is now a fact from the instant it is requested. Any code that assumed the completer was still open during the exit animation would be wrong; nothing in the library does.
- Selecting an item requests the Close *before* running the item's own `onTap`, so a side effect in `onTap` cannot overtake the selection with a null Close. `onTap` therefore runs after the exit animation has started.
