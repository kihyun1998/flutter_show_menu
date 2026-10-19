# Release and publish

## What it is

How the package gets to pub.dev: the version, the CHANGELOG, the tag, the
archive's file list and the Flutter floor it declares. These files rarely
change, and when one is wrong nothing fails locally. The failure only shows
up for the person who installs the package.

## Governing decisions

**None.** The process is written in
[theflow, Step 6](../../agents/theflow.md#step-6--behavior-describing-surfaces)
and [Step 7](../../agents/theflow.md#step-7--gate-matrix), not in a record.

## Design model

- Having a `.pubignore` turns off pub's git-based file listing, so git's
  ignore rules stop applying. `build/`, `.dart_tool/` and `coverage/` must be
  listed in it explicitly, unanchored, so they also match under `example/`.
- `docs/`, `tool/` and `.github/` are excluded too, so this map and its
  checker do not ship.
- Nothing gates the declared Flutter floor. CI builds against a pinned
  newer SDK, not the floor. The floor is checked by hand, with the
  `git log -S` method in
  [theflow, Step 1](../../agents/theflow.md#step-1--reference-routing-table)
  (#24).
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

- [Menu body layout](menu-body-layout.md): its use of
  `WidgetStatePropertyAll` is what sets the floor.
- [CI gates](ci-gates.md): CI's pinned SDK is not the floor, so a green
  build says nothing about the floor.

## Known holes / open

- No gate checks the floor, so a new SDK API used in `lib/` can make it
  dishonest again without any red build.
