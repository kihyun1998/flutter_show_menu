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
_Avoid_: Dismiss, cancel, remove — these name internal steps or call sites, not the concept.

**Auto-close**:
A Close triggered by the library itself rather than by a user gesture. The only existing Auto-close trigger is a route change (push or pop).

**Close All**:
Closing every Open Menu app-wide at once, without the caller holding a reference to any of them. Each affected menu Closes with a null result, exactly as a route-change Auto-close does.
_Avoid_: Dismiss all, clear menus

**Controller** (`OverlayMenuController`):
A handle bound to exactly one Open Menu, used to Close that one menu programmatically.

## Relationships

- A **Close All** Closes zero or more **Open Menus** — the set may legitimately hold more than one, since multiple **Open Menus** are allowed at once.
- A **Controller** Closes exactly one **Open Menu**; **Close All** needs no **Controller**.
- **Auto-close** is the library acting on its own; route change is one such trigger, **Close All** is the explicit, caller-driven counterpart for non-route moments.

## Example dialogue

> **Dev:** "On session expiry I need every menu gone, but I don't hold any **Controller** — can I rely on **Auto-close**?"
> **Maintainer:** "Only if a route changes. Session expiry without navigation is exactly the gap **Close All** fills — it Closes all **Open Menus** with a null result, no references needed."

## Flagged ambiguities

- The codebase uses _close_, _dismiss_, _cancel_, and _remove_ for the same idea. Resolved: **Close** is the public, canonical term; _dismiss_ refers to the internal animated step, _remove_ to OverlayEntry teardown, _cancel_ to "closed without a selection". Public API names use **Close**.
