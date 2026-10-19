# Enter/exit motion

## What it is

The menu fades in from 0 to 1 and scales up from 0.9 to 1 when it opens,
and plays the same animation in reverse on an Animated Close. One
`AnimationController` drives both, with the duration and curve from
`OverlayMenuMotion`.

## Governing decisions

- [ADR-0002](../../adr/0002-latch-the-result-when-close-is-requested.md#decision)
  makes the exit animation part of an Animated Close and lets an Instant
  Close skip it.
- [ADR-0003](../../adr/0003-group-menu-configuration-by-cohesion.md#considered-options)
  keeps motion as its own object instead of folding it into the style.

## Design model

- The forward animation starts in `initState`. In the same place the widget
  registers its exit animator with the Open Menu, and it withdraws it in
  `dispose`. While no animator is registered, an Animated Close falls back to
  an Instant one. [ADR-0002](../../adr/0002-latch-the-result-when-close-is-requested.md#decision)
  says why that is correct.
- The exit animator is `reverse()`. If an Instant Close disposes the ticker
  mid-animation, the future it returned never completes and never errors, so
  there is nothing to catch.
- Enter and exit use the same duration and curve. There is no exit-specific
  setting.

## Code

- `lib/src/overlay_menu.dart` — `_OverlayMenuWidgetState.initState`, `_OverlayMenuWidgetState.dispose`, `_playExit`, `_opacity`, `_scale`
- `lib/src/overlay_menu_motion.dart` — `OverlayMenuMotion`
- `lib/src/open_menu.dart` — `ExitAnimator`, `OpenMenu.attachExitAnimator`, `OpenMenu.detachExitAnimator`
- `test/exit_animation_cancellation_test.dart`

## Reference behaviour

- [ADR-0002, Consequences](../../adr/0002-latch-the-result-when-close-is-requested.md#consequences)
  records how `TickerFuture` behaves on cancellation, which is why the
  animator has no `catch`.
  `test/exit_animation_cancellation_test.dart` pins that SDK behaviour.
- [theflow, Step 1](../../agents/theflow.md#step-1--reference-routing-table)
  lists it among the facts proven from source (#9).

## Cross-cutting invariants

- [Force decides Animated vs Instant](../invariant/close-force-decides-animation.md)

## Blast radius

- [Close lifecycle](close-lifecycle.md): depends on the animator completing
  only when the animation finishes.
- [Scale origin](scale-origin.md): it scales around whatever this animation
  outputs.
- [Configuration objects](configuration-objects.md): `OverlayMenuMotion`
  compares its curve by identity.

## Known holes / open

- If a future Flutter completes the primary `TickerFuture` on cancellation,
  the pin test fails and the exit animator has to be revisited.
