# Pin the public names the barrel exports

## Context

`lib/flutter_show_menu.dart` has ten export lines. Three use `show`, which keeps `OpenMenu`, `OpenMenuRegistry` and `ExitAnimator` private. The other seven export whole files, so a public name added to one of those files becomes public API without the barrel changing. Nothing in analyze, the tests or review noticed, and taking a name back is a breaking change (#37).

The public surface is 18 names. A source scan, the analyzer's export namespace and `dart doc`'s index.json agree on that count.

Measured with `flutter analyze --fatal-infos --fatal-warnings` on a copy of the repository, Flutter 3.41.9:

- Turning every line into a `show` stops accidental exposure but adds accidental hiding. A new type used as the type of a public field, but left out of `show`, passes analyze, `dart doc` and `publish --dry-run` silently, and callers cannot name it. A new subtype of the sealed `OverlayMenuEntry` left out of `show` breaks a caller's exhaustive switch with a case the caller cannot write. A rename of a shown name is caught (`undefined_shown_name`).
- `package:analyzer` can list the export namespace exactly. It would be this repository's first external dependency, its version is bound by `flutter_test`'s pins (10.0.1 at the time), it adds about 11s to the suite, and it needs an `sdkPath` workaround inside `flutter test`.
- A text scan of the barrel and the files it exports matched the analyzer exactly on the tree at the time. It cannot read `part` files, re-exports inside `lib/src`, or old-style typedefs, none of which the tree uses.

Flutter's own `material.dart` exports all of its files whole and uses `show` only to re-export from other layers.

## Decision

Keep the whole-file exports. `test/check_surface_test.dart` pins the full list of public names, so adding, removing or renaming one fails the suite. The names come from `tool/check_surface.dart`, a dependency-free source scan. A top-level line it cannot read, a `part` file, `hide`, or an export inside an exported file is a finding, so a form it does not know fails instead of being skipped.

This was the maintainer's call (#37), a judgement made on the measurements above.

## Considered Options

- **`show` on every export line.** Rejected: it trades a silent exposure for a silent hiding, and the hiding cannot be worked around by a caller.
- **Pin the names through `package:analyzer`.** Rejected: an external dependency and a slower suite for a list the source scan reads exactly. It is the way to extend the pin to class members, if that is ever wanted.
- **Leave it.** Rejected: an addition is caught by nobody, except by accident when a new function body trips the coverage floor.

## Consequences

- Making a name public means adding it to the pinned list in the same change, where review sees it.
- Members added to a class that is already public are not pinned. ADR-0003 allows them as non-breaking.
- A new declaration form that the scan cannot read fails the suite until the scan learns it.
- `test/check_surface_test.dart` imports `tool/`, so it is listed in `.pubignore` with the map check's test.
