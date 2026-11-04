# Take flutter_smooth_wheel_scroll as the first runtime dependency

## Context

A scrolling menu applies a whole mouse wheel notch in one frame. Measured with a widget test on Flutter 3.41.9 and again on 3.47.1, `maxHeight: 245` and 30 items: one 60px wheel event moves the offset by 60.0 in the first frame, and it is still 60.0 after 16ms and once settled (#58). The body's `ScrollController` is private, so a caller cannot change this.

The sibling packages (flutter_folderview, flutter_table_plus, flutter_dropdown_button, just_sonner) animate wheel input through `flutter_smooth_wheel_scroll`, and default to `WheelMotion.spring()`. Its `SmoothScrollController` animates only mouse wheel input. `jumpTo`, drag, the scrollbar and the keyboard behave as with `ScrollController`, so the `initialValue` jump is unaffected.

`flutter_smooth_wheel_scroll` 0.1.5 requires `sdk: ^3.8.0` and `flutter: >=3.32.0`. This package declared `sdk: >=3.0.0` and `flutter: >=3.22.0`, and had no dependency besides Flutter. ADR-0007 had rejected `package:analyzer` partly because it would have been the first external dependency.

## Decision

Depend on `flutter_smooth_wheel_scroll` and raise the floor to Flutter 3.32 and Dart 3.8. `OverlayMenuStyle` gains a non-nullable `wheelMotion`, defaulting to `WheelMotion.spring()`. `WheelMotion.spring(duration: Duration.zero)` turns the animation off. The barrel re-exports `WheelMotion` only.

This was the maintainer's call (#58). The package has no consumers yet, and the siblings already share this floor and this type.

## Considered Options

- **Write the wheel animation in this package.** Rejected: the floor would stay, but the motion would differ from the siblings', and callers could not pass one `WheelMotion` value to all of them.
- **A nullable field where `null` means no animation, as the siblings do.** Rejected: `OverlayMenuStyle.copyWith` treats `null` as "keep the current value", so a style that starts from the spring default could never be switched to no animation through `copyWith`.
- **Do not re-export `WheelMotion`.** Rejected: every caller who sets the field would need a second import.

## Consequences

- Callers on Flutter 3.22–3.31 or Dart below 3.8 can no longer resolve the release that carries this.
- Scrolling menus animate wheel input by default. Menus that fit do not scroll and are unchanged.
- `WheelMotion` joins the public names `test/check_surface_test.dart` pins (ADR-0007).
- Dependabot opens a PR for each `flutter_smooth_wheel_scroll` release outside the caret; each one may raise the floor again.
