# CI gates

## What it is

The checks every pull request and every push to `main` must pass: format,
analyze, the test suite, the coverage floor, and the map check.

## Governing decisions

**None.** The gates are listed in
[theflow, Step 7](../../agents/theflow.md#step-7--gate-matrix). The
workflow's comments point here.

## Design model

- Formatting is checked after `pub get`, because `dart format` reads the
  package's language version from `.dart_tool/package_config.json`. Dart
  3.7's tall style applies only at language version 3.7 and above, and
  without the package config the formatter assumes the latest version and
  reformats the whole repo. The check still runs before the tests, so a
  formatting slip fails fast.
- `analyze` runs with `--fatal-infos --fatal-warnings`, so an info-level
  lint fails the build.
- The coverage floor is 100 and is set only in the workflow. `lib/` is
  fully covered, so anything less is a regression. A line wrapped
  in a `coverage:ignore-start` / `ignore-end` pair leaves the denominator
  entirely, and the pair itself keeps the exception visible in the diff.
- The Flutter version is pinned, so a new Flutter release cannot turn a
  green branch red.
- The map check runs over every note under `docs/map`, listed fresh each
  time. Run with no note named, as CI runs it, it also checks every
  `docs/map/...md` and `docs/adr/...md` path that a file under `lib/`,
  `test/` or `.github/` mentions, so renaming a note fails where a source
  comment still points at the old name. The checker's own test is skipped,
  because its paths are fixtures. The same run checks the markdown outside
  the map (the root `.md` files, `docs/agents` and `docs/adr`): its relative
  links and anchors must resolve, and a path written outside a link, such as
  a CHANGELOG entry's `docs/adr/...md`, must exist.
- The lcov report is uploaded even when an earlier step failed, so a
  coverage regression can be inspected rather than merely reported. A
  missing report is a warning, not an error: a failing test run has no lcov
  to upload, and the test failure is the message worth seeing.

## Code

- `.github/workflows/ci.yml`
- `tool/check_coverage.dart` — `main`, `_parse`
- `tool/check_map.dart` — `checkMap`, `checkPointers`, `checkDocLinks`, `docFiles`, `slugsOf`, `territoryHeadings`, `invariantHeadings`
- `test/check_map_test.dart`

## Reference behaviour

**None.**

## Cross-cutting invariants

**None.**

## Blast radius

- [Release and publish](release-and-publish.md): the pinned SDK is not the
  floor.

## Known holes / open

- The map check silently skips some link forms: nested brackets in the
  text, single-quote or parenthesised titles, angle-bracket targets, and
  reference-style links. A broken link written in one of those forms passes.
  A link inside a heading also leaks its target into that heading's slug.
  No current note uses any of them.

- [lessons, Step 6/7](../../agents/lessons.md#step-67--정합성--게이트)
  measured why the floor is 100 and not 99: deleting one test file leaves
  exactly 99.0%, which a floor of 99 would pass.
