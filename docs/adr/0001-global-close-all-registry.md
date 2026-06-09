# Global Close All via a static open-menu registry

## Context

The library auto-closes Open Menus on route changes (push/pop), but there is no way to Close menus for non-route moments — session expiry, app backgrounding, event-driven cleanup — when the caller does not hold a `OverlayMenuController` reference to each Open Menu. Flutter's `Overlay` holds the entries but gives no way to tell ours apart from others', so the library cannot discover its own Open Menus after the fact.

## Decision

Introduce a public top-level `closeAllOverlayMenus()` backed by a single app-wide static registry of Open Menus. `showOverlayMenu` registers each menu's close callback on insert and deregisters it inside `close()` (so every existing close path — selection, barrier, controller, route Auto-close — keeps the registry accurate). `closeAllOverlayMenus()` iterates a copy of the registry (closing mutates it) and Closes each Open Menu **immediately with a null result**, mirroring route Auto-close rather than playing the per-menu reverse animation.

## Considered Options

- **Caller-managed controllers** — make callers keep a `Set<OverlayMenuController>` and loop over it. Rejected: the motivating case is closing menus whose references the caller does not have; this pushes a registry to every call site.
- **Animated close** — reverse-animate each menu before removal. Rejected: for force-cleanup it leaves N menus half-alive for ~150ms and forces an async/awaitable API, inconsistent with the existing instant route Auto-close.

## Consequences

- The library now carries **global mutable state** (a static registry). Registration/deregistration must funnel through the single `close()` path or menus leak into the registry; tests must ensure the registry empties between cases.
- App-global scope means `closeAllOverlayMenus()` Closes menus across every Overlay/Navigator, by design — there is no context-scoped variant.
