# Controller

## What it is

`OverlayMenuController`, the caller's handle for one Open Menu. It can Close
that menu and report whether it is already closed.

## Governing decisions

- [ADR-0002](../../adr/0002-latch-the-result-when-close-is-requested.md#decision)
  says when `isClosed` turns true and that `close()` is an Animated Close.
- `GLOSSARY.md`: **Controller**, including rebinding.

## Design model

- `close()` is an Animated Close with a `null` result. Calling it is safe
  when the menu is already closed and when no menu was ever shown. In the
  second case it just marks the Controller closed.
- `isClosed` turns true when a Close is *requested*, by any trigger, not
  when the exit animation ends.
- Showing a new menu with the same Controller rebinds it and resets
  `isClosed` to false. A menu marks the Controller closed (on its Close
  request and again at teardown) and unbinds it only while the Controller
  is still bound to that menu. So an old menu, whether still open or
  animating out, cannot close or unbind a Controller that has moved on to a
  newer one (#27).

## Code

- `lib/src/open_menu.dart` — `OverlayMenuController`, `OverlayMenuController.close`, `OverlayMenuController.isClosed`, `_bind`, `_unbind`, `_markClosed`
- `test/overlay_menu_close_test.dart`

## Reference behaviour

**None.**

## Cross-cutting invariants

- [Result latched at Close request](../invariant/result-latched-at-request.md)
- [One Close path](../invariant/one-close-path.md)
- [Force decides Animated vs Instant](../invariant/close-force-decides-animation.md)

## Blast radius

- [Close lifecycle](close-lifecycle.md): binds, marks and unbinds the
  Controller.
- [OverlayMenuButton](overlay-menu-button.md): passes a Controller through
  unchanged.

## Known holes / open

**None.**
