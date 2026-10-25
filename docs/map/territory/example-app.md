# Example app

## What it is

The playground under `example/`: a Flutter app that depends on this package
by path and lets a person try every parameter of a menu — position,
alignment, offset, styling, animation and theme — on a live anchor. pub.dev
shows its `lib/` as the package's example.

## Governing decisions

**None.** The README's "Example" section describes it; no record decides
what it covers.

## Design model

Read from the source; nothing in a record says it.

- It depends on the package as `flutter_show_menu: path: ../`
  (`example/pubspec.yaml`), so it always builds against the working tree,
  never a published version.
- `PlaygroundApp` holds the theme (light or dark, and a seed colour);
  `PlaygroundPage` holds a `PlaygroundConfig` and opens menus with
  `showOverlayMenu`, from the controls in `widgets/`.
- `.pubignore` drops the generated platform runners (`example/android/`,
  `ios/`, `linux/`, `macos/`, `windows/`, `web/`), so the archive carries
  only what the pub.dev example needs.
- Its one test checks that the app renders. CI does not run it:
  `flutter test` runs at the root only (`.github/workflows/ci.yml`).

## Code

- `example/lib/main.dart` — `PlaygroundApp`
- `example/lib/playground_page.dart` — `PlaygroundConfig`, `PlaygroundPage`
- `example/lib/widgets/control_panel.dart` — `ControlPanel`
- `example/pubspec.yaml`
- `example/test/widget_test.dart`

## Reference behaviour

**None.**

## Cross-cutting invariants

**None.**

## Blast radius

- [Public surface](public-surface.md): it calls the public API, so a renamed
  or removed name breaks it.
- [Configuration objects](configuration-objects.md): its controls build
  these objects, so a field moved between them breaks it.
- [Release and publish](release-and-publish.md): it is shipped in the
  archive as the example.

## Known holes / open

- No gate builds `example/` or runs its test. Whether the root
  `flutter analyze` step reaches it was not checked (no Flutter SDK in the
  session that wrote this note, 2026-10-25). If it does not, an API change
  can break the shipped example with every check green.
