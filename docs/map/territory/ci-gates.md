# CI gates

## What it is

The checks every pull request and every push to `main` must pass: format,
analyze, the test suite, the coverage floor, and the map check.

## Governing decisions

**None.** The gates are described in
[theflow, Step 7](../../agents/theflow.md#step-7--gate-matrix) and in the
workflow's own comments.

## Design model

- Formatting is checked after `pub get`, because `dart format` reads the
  language version from the package config.
- `analyze` runs with `--fatal-infos --fatal-warnings`, so an info-level
  lint fails the build.
- The coverage floor is 100 and is set only in the workflow. A line wrapped
  in `coverage:ignore` leaves the denominator entirely, so every exception
  shows up in the diff.
- The Flutter version is pinned, so a new Flutter release cannot turn a
  green branch red.
- The map check runs over every note under `docs/map`, listed fresh each
  time.

## Code

- `.github/workflows/ci.yml`
- `tool/check_coverage.dart` — `main`, `_parse`
- `tool/check_map.dart` — `checkMap`, `slugsOf`, `territoryHeadings`, `invariantHeadings`
- `test/check_map_test.dart`

## Reference behaviour

**None.**

## Cross-cutting invariants

**None.**

## Blast radius

- [Release and publish](release-and-publish.md): the pinned SDK is not the
  floor.

## Known holes / open

- [lessons, Step 6/7](../../agents/lessons.md#step-67--정합성--게이트)
  measured why the floor is 100 and not 99: deleting one test file leaves
  exactly 99.0%, which a floor of 99 would pass.
