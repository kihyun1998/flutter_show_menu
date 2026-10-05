# flutter_show_menu

A Flutter package that shows menus through an `OverlayEntry` instead of a Navigator route, as a drop-in replacement for the framework's `showMenu`. This glossary fixes the language used when discussing menu behaviour.

## Language

**Overlay Menu**:
A menu rendered via an `OverlayEntry` rather than a pushed route.
_Avoid_: Popup, dropdown, dialog

**Open Menu**:
An Overlay Menu currently live in the Overlay (visible or animating).
_Avoid_: Active menu, showing menu

**Close**:
The canonical verb for taking an Open Menu away and delivering its result (a selected value, or null when none was chosen).
The result is fixed the moment a Close is **requested**, not when the menu finishes leaving the screen. A second Close arriving before the first has finished cannot change it.
_Avoid_: Dismiss, cancel, remove — these name internal steps or call sites, not the concept.

**Animated Close**:
A Close that plays the exit animation before the menu leaves. Every Close a human asked for is animated: selecting an item, tapping the barrier, calling `Controller.close()`.

**Instant Close**:
A Close that tears the menu down within the frame, skipping the exit animation. Reserved for force-cleanup, where a menu lingering ~150ms would be wrong: route Auto-close and Close All. An Instant Close arriving during an Animated Close cuts the animation short, and still delivers the result the first Close latched.

**Auto-close**:
A Close triggered by the library itself rather than by a caller. The only existing Auto-close trigger is a route change (push or pop). Always an Instant Close.

**Close All**:
Closing every Open Menu app-wide at once, without the caller holding a reference to any of them. Each affected menu takes an Instant Close, exactly as a route-change Auto-close does. Unlike Auto-close it is caller-driven.
_Avoid_: Dismiss all, clear menus

**Controller** (`OverlayMenuController`):
A handle bound to exactly one Open Menu, used to Close that one menu programmatically. Rebinding it to a later Open Menu is allowed; it then Closes only that one.

**Open Menu Registry**:
The single app-wide set of live Open Menus. An Open Menu joins it when shown and leaves when it tears down — never before, so a menu part-way through an Animated Close is still reachable by Close All. It is what lets Close All find menus the caller holds no Controller for.

## Relationships

- A **Close All** Closes zero or more **Open Menus** — the set may legitimately hold more than one, since multiple **Open Menus** are allowed at once.
- A **Controller** Closes exactly one **Open Menu**; **Close All** needs no **Controller**.
- **Auto-close** is the library acting on its own; route change is one such trigger, **Close All** is the explicit, caller-driven counterpart for non-route moments.
- Every Close — from any trigger — passes through one path, which is what keeps the **Open Menu Registry** accurate.
- The **Animated Close** / **Instant Close** split is about force, not about who asked: **Controller** is caller-driven yet animated, **Close All** is caller-driven yet instant.

## Example dialogue

> **Dev:** "On session expiry I need every menu gone, but I don't hold any **Controller** — can I rely on **Auto-close**?"
> **Maintainer:** "Only if a route changes. Session expiry without navigation is exactly the gap **Close All** fills — it Closes all **Open Menus** with a null result, no references needed."

## Flagged ambiguities

- The codebase uses _close_, _dismiss_, _cancel_, and _remove_ for the same idea. Resolved: **Close** is the public, canonical term; _dismiss_ refers to the internal animated step, _remove_ to OverlayEntry teardown, _cancel_ to "closed without a selection". Public API names use **Close**.
- "Closed" once had four representations in code, and the result was only decided once the exit animation ended. Resolved: an Open Menu is _open_, _closing_ (result latched, animation may still play), or _closed_. See ADR-0002.
