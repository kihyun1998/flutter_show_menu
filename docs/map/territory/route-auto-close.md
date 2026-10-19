# Route Auto-close

## What it is

The menu Closes itself, instantly, when the route it was opened from is
popped or when another route is pushed on top of it.

## Governing decisions

- `GLOSSARY.md`: **Auto-close**. Route change is the only Auto-close
  trigger, and it is always an Instant Close.
- [ADR-0002](../../adr/0002-latch-the-result-when-close-is-requested.md#decision)
  covers what an Instant Close does to a Close already in progress.

## Design model

- The route is `ModalRoute.of(context)` for the **anchor** context, taken
  when the menu is shown. An anchor with no enclosing `ModalRoute` gets no
  Auto-close at all.
- A pop shows up as the route's `animation` going into `reverse`. A push on
  top shows up as its `secondaryAnimation` going `forward`. Both call
  `OpenMenu.close(null, animated: false)`.
- The listeners are removed in teardown inside a `try`/`catch` that swallows
  any error, on the assumption that the route may already be disposed.

## Code

- `lib/src/open_menu.dart` — `OpenMenu`, `_onRouteStatus`, `_onSecondaryRouteStatus`, `_stopListeningToRoute`
- `lib/src/overlay_menu.dart` — `showOverlayMenu`
- `test/overlay_menu_close_test.dart`

## Reference behaviour

**None.** The listener-removal `catch` has not been checked against the SDK.
See the hole below.

## Cross-cutting invariants

- [Result latched at Close request](../invariant/result-latched-at-request.md)
- [One Close path](../invariant/one-close-path.md)
- [Force decides Animated vs Instant](../invariant/close-force-decides-animation.md)

## Blast radius

- [Close lifecycle](close-lifecycle.md): owns the listeners' add and remove.
- [Anchor contract](anchor-contract.md): the route comes from the same
  context as the anchor box.
- [Open Menu Registry and Close All](close-all-registry.md): the other
  Instant Close, and it should behave the same way on a menu.

## Known holes / open

- **The `catch` around listener removal is unproven.** `CLAUDE.md` requires a
  defensive `catch` to be shown reachable from SDK source. Read against the
  local SDK checkout at 3.41.9: `ModalRoute.animation` is a `ProxyAnimation`,
  and `removeStatusListener` on `AnimationLocalStatusListenersMixin` and on
  the `kAlways*` animations neither asserts nor throws. That is not yet a
  proof that nothing in the chain throws, so the `catch` stays until someone
  proves it either way.
