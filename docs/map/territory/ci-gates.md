# CI gates

## What it is

The checks every pull request and every push to `main` must pass: format,
analyze, the test suite and the coverage floor.

## Governing decisions

**None.** The gates are the steps of `.github/workflows/ci.yml`. The
workflow's comments point here.

## Design model

- Formatting is checked after `pub get`, because `dart format` reads the
  package's language version from `.dart_tool/package_config.json`. Dart
  3.7's tall style applies only at language version 3.7 and above, and
  without the package config the formatter assumes the latest version and
  reformats the whole repo. The check still runs before the tests, so a
  formatting slip fails fast. The misordering reproduces only in a clean
  `git worktree`, where no package config is left over.
- `analyze` runs with `--fatal-infos --fatal-warnings`, so an info-level
  lint fails the build.
- The coverage floor is 100 and is set only in the workflow. `lib/` is
  fully covered, so anything less is a regression. A line wrapped
  in a `coverage:ignore-start` / `ignore-end` pair leaves the denominator
  entirely, and the pair itself keeps the exception visible in the diff.
  A probe measured it: `LF` went from 14 to 15 and the wrapped line was
  absent from the report.
- The Flutter version is pinned, so a new Flutter release cannot turn a
  green branch red.
- The lcov report is uploaded even when an earlier step failed, so a
  coverage regression can be inspected rather than merely reported. A
  missing report is a warning, not an error: a failing test run has no lcov
  to upload, and the test failure is the message worth seeing.

## Code

- `.github/workflows/ci.yml`
- `tool/check_coverage.dart` — `main`, `_parse`

## Reference behaviour

**None.**

## Cross-cutting invariants

**None.**

## Blast radius

- [Release and publish](release-and-publish.md): the pinned SDK is not the
  floor.

## Known holes / open

- No gate checks a link in the repo's markdown. The map checker that did,
  for the map, the root `.md` files, `docs/agents` and `docs/adr`, and for
  `docs/map/...md` paths named in `lib/`, `test/` and `.github/`, was removed
  on 2026-10-25 (commit 3376eeb); the map is checked by reading it against
  the code instead.
- Nothing watches the pinned actions (`actions/checkout`,
  `subosito/flutter-action`, `actions/upload-artifact`) for new releases.
  Tracked: #51, which proposes a grouped monthly Dependabot update.

- [lessons, Step 6/7](../../agents/lessons.md#step-67--정합성--게이트)
  measured why the floor is 100 and not 99: deleting one test file leaves
  exactly 99.0%, which a floor of 99 would pass.
