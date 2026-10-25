# Release and publish

## What it is

How the package gets to pub.dev: the version, the CHANGELOG, the tag, the
archive's file list and the Flutter floor it declares. These files rarely
change, and when one is wrong nothing fails locally. The failure only shows
up for the person who installs the package.

## Governing decisions

**None.** The process is written here and in
[lessons, Step 6/7](../../agents/lessons.md#step-67--정합성--게이트), not in a record.

## Design model

- Having a `.pubignore` turns off pub's git-based file listing, so git's
  ignore rules stop applying. `build/`, `.dart_tool/` and `coverage/` must be
  listed in it explicitly, unanchored, so they also match under `example/`.
- `docs/`, `tool/` and `.github/` are excluded too, so this map and its
  checker do not ship. A published archive cannot be withdrawn, so a file
  this list misses ships for good.
- Nothing gates the declared Flutter floor. CI builds against a pinned
  newer SDK, not the floor. The floor is checked by hand, with the
  `git log -S` and `git tag --contains` method in
  [lessons, Step 6/7](../../agents/lessons.md#step-67--정합성--게이트)
  (#24), run in the Flutter SDK tree that
  [`thegraph.md`](../../agents/thegraph.md) names.
- pub.dev snapshots `CHANGELOG.md` at publish, so each release opens a new
  version section rather than editing a published one.
- `flutter pub publish --dry-run` must report 0 warnings before a release.
  What pub.dev currently has is read from
  `https://pub.dev/api/packages/flutter_show_menu`.
- A tag is an immutable pointer. For 1.0.0 the tag was moved rather than
  skipping to a new version.
- An agent never runs `flutter pub publish`; the maintainer does.

## Code

- `.pubignore`
- `pubspec.yaml`
- `CHANGELOG.md`

## Reference behaviour

**None.**

## Cross-cutting invariants

**None.**

## Blast radius

- [Public surface](public-surface.md): what the barrel exports is what a
  version number promises.
- [Menu body layout](menu-body-layout.md): its use of
  `WidgetStatePropertyAll` is what sets the floor.
- [CI gates](ci-gates.md): CI's pinned SDK is not the floor, so a green
  build says nothing about the floor.
- [Example app](example-app.md): it ships in the archive, and what
  `.pubignore` leaves out of `example/` decides what pub.dev shows.

## Known holes / open

- Nothing tells the maintainer when `flutter_lints`, the one non-SDK
  dependency (dev), publishes outside its caret. Tracked: #51, which
  proposes Dependabot at the root with `increase-if-necessary`, one PR per
  dependency, because such a release is a floor decision for consumers.
- No gate checks the floor, so a new SDK API used in `lib/` can make it
  dishonest again without any red build.
