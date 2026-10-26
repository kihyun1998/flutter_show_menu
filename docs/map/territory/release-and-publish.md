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
- Dependabot watches the root manifest with `increase-if-necessary`. The
  root commits no `pubspec.lock`, so a release the caret already allows
  changes nothing and opens no PR. Only a release outside the caret does:
  every major release from `1.0.0` on, and every minor release below it.
  For a runtime dependency such a PR raises the floor consumers resolve
  against; for the dev dependency `flutter_lints` it brings new lint
  rules. Either way it is a decision, not a chore, so root PRs are not
  grouped: one PR is one decision.
- The root is checked weekly. #51 asked for monthly; the maintainer chose
  weekly to match the sibling packages. That was their call, and it is
  theirs to reverse.
- `example/` is checked monthly and its updates come in one grouped PR,
  because nothing ships from it. It commits a `pubspec.lock`, so its PRs
  also move resolved versions inside the caret.
- The actions pinned in the workflows are checked monthly in one grouped
  PR, so `actions/checkout`, `actions/upload-artifact` and
  `subosito/flutter-action` move together.
- Every Dependabot PR is labelled `needs-triage`. Dependabot ignores a
  label the repository does not define, and this one is defined.

## Code

- `.pubignore`
- `pubspec.yaml`
- `CHANGELOG.md`
- `.github/dependabot.yml`

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

- No gate checks the floor, so a new SDK API used in `lib/` can make it
  dishonest again without any red build.
