# theflow bindings (flutter_show_menu)

Project-specific data for the `theflow` skill. The skill holds the portable
*method*; this file holds the *bindings*. Per-incident evidence lives in
[`lessons.md`](lessons.md).

Identity and the domain language live in **`CONTEXT.md`** (Overlay Menu · Open
Menu · Close · Animated/Instant Close · Auto-close · Close All · Controller ·
Open Menu Registry). Decisions live in **`docs/adr/`** (0001 close-all registry,
0002 latch the result when Close is requested, 0003 group config by cohesion,
0004 resolve the scale origin during layout).

## Crate / module map

Single Flutter package, **no external dependencies**. An `OverlayEntry`-based
`showMenu` replacement. Public surface (barrel): `showOverlayMenu`,
`OverlayMenuController`, `closeAllOverlayMenus`, `MenuPosition`, `OverlayMenu*`
(`Button`/`Item`/`Barrier`/`Motion`/`Placement`/`Style`).

| Module (`lib/src/`) | Role |
|---|---|
| `overlay_menu.dart` | `showOverlayMenu` — builds the overlay; **guards the anchor `context` has a `RenderBox`** (#8) |
| `open_menu.dart` / `open_menu_registry.dart` | `OverlayMenuController` (one menu) / `closeAllOverlayMenus` + the app-wide **Open Menu Registry** (ADR-0001) |
| `menu_position*.dart` | `MenuPosition` + the position delegate (`getPositionForChild`) |
| `menu_scale_origin.dart` | the **custom render object** that resolves the scale origin **during layout** (ADR-0004 / #18) |
| `overlay_menu_motion.dart` | enter/exit animation; Close latches the result at **request** time (ADR-0002) |
| `overlay_menu_barrier` / `_button` / `_item` / `_entry_view` / `_metrics` / `_placement` / `_style` | chrome, hit target, layout metrics, styling |

**No consumers yet** (derive at Step 10; do not store a list). Until one exists,
theflow's downstream verification/migration steps are **N/A — no target**, not skipped.

## Step 1 — reference routing table

| Change type | Real source to read |
|---|---|
| **Layout / animation / painting** | Flutter SDK source directly. Precedents proven from source, not memory: `Ticker`/`TickerFuture` (`await controller.reverse()` **never** throws `TickerCanceled` — #9); `AlignmentGeometry` declares private abstract members so a paint-time custom alignment is **impossible** (#18, ADR-0004); `framework.dart` rebuild compares the **widget** not its config (#7); an unmounted element's `renderObject` throws only inside an `assert` (release returns stale — #8) |
| **API introduced-in version** | `cd /d/flutter && git log -S "<sig>"` + `git tag --contains`. The floor-vs-code mismatch this once hid (`WidgetStatePropertyAll` under a `>=3.10.0` floor) was proven and fixed to `>=3.22.0` this exact way (#24, Step 7) |
| **Published state** | `curl -s https://pub.dev/api/packages/flutter_show_menu` |

## Step 2 — boundary rule

- **`OverlayEntry`-based, not a Navigator route.** The library owns positioning,
  the scale-origin render object, the close/registry lifecycle, animation, and the
  barrier. The caller owns the items, the anchor widget, and result handling.
- **Fix at the layer where the invariant is decided.** #18/ADR-0004: the scale
  origin must be resolved in `getPositionForChild` (**layout**), because flip needs
  the menu's own size — a build-time prediction pushes the ordering problem onto
  the public API, and a one-frame-late `ValueNotifier` gets the *first* frame
  (scale 0.9, the largest error) wrong. The render object resolves it at layout and
  reads it at paint.
- **A defensive `catch` / null-guard is a workaround** — a confession you did not
  understand upstream. Prove reachability from SDK source before adding *or*
  removing one (#9: the `on TickerCanceled` catch was dead, proven from
  `scheduler/ticker.dart`).
- **Contract ≠ defect (#8).** An unmounted anchor makes Flutter throw `Cannot get
  renderObject of inactive element` — but that is an `assert` (silent in release),
  and the broken invariant was **ours**: `showOverlayMenu` cast to `RenderBox`
  without stating or checking the "anchor context has a `RenderBox`" contract. Fixed
  here with a `FlutterError` guard, not by treating the SDK as buggy.

## Step 4 — proof method per layer

- **Observe at the public seam — "which point does the menu pin as it grows",** not
  `ScaleTransition.alignment` (#18: 12 tests asserted the internal field and all
  broke on a render-object swap that changed no observable behavior). Cover all four
  flipped directions.
- **Throwaway probe** for real rect/coords (#5: `initialValue` centering was 4px
  off, 52px with a header/footer).
- **RED really RED** (#8: `throwsA(isA<FlutterError>())` is green from the start —
  Flutter already throws one; require the message to name `showOverlayMenu`).
- **Guard that the setup actually happened** (#18: origin-pinning tests pass even at
  a stuck scale of 1 unless `_expectItGrew` asserts the menu grew first).
- **Equality tests build values at runtime and assert `identical(a, b)` is false
  first** — Dart normalizes same-arg `const` to one instance (#7).

## Step 5 — test-trust (100% covered ≠ correct)

- **`lib/` at 100% did not catch the scale-origin bug** (#18) — those lines *ran*
  but were not *verified*.
- **`copyWith`'s `x ?? this.x` right operand is never evaluated** if you only test
  *replacing* each field (#7) — the property "argless `copyWith()` equals the
  original" covers all fields at once (all seven config classes).
- `// coverage:ignore-*` removes lines from the **denominator** (probe: `LF` 14→15,
  the wrapped line absent from the report).

## Step 6 — behavior-describing surfaces

- **`CHANGELOG.md`** — pub.dev snapshots at publish; open a new version. (1.0.0's
  section was written before its four user-visible changes and reconciled just
  before publishing.)
- **`README.md`** — kept claiming `copyWith` on three groups when it's all seven
  classes, and never mentioned `showOverlayMenu` throwing `FlutterError` or the
  return being latched at Close-request time.
- **`docs/adr/`** — an ADR's *Consequences* must be a **currently-true** sentence;
  flip it when the decision flips (#9 made a recorded "live guard" false).
- **`CONTEXT.md` glossary** — a concept the glossary leaves undefined is filled
  arbitrarily by code: **Close** said "delivers a result" but was silent on *when*
  it is fixed — that silence was where two result-loss bugs lived (ADR-0002).
- **`.pubignore`** — disables git-based listing when present; `coverage/` shipped
  despite being in `.gitignore`. The pub.dev archive cannot be un-published.

## Step 7 — gate matrix

`.github/workflows/ci.yml` runs on every PR:

```
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos --fatal-warnings
flutter test --coverage
dart run tool/check_coverage.dart --min 100 --report
```

- **A dishonest `flutter` floor is invisible to every gate — no CI catches a floor
  (#24, fixed).** `pubspec.yaml` once declared `flutter: ">=3.10.0"` while
  `lib/src/overlay_menu.dart:359,362,366` used `WidgetStatePropertyAll` — the
  `WidgetState*` rename that landed in **Flutter 3.22** (before that,
  `MaterialStatePropertyAll`), so a 3.10–3.21 user got a compile error. Raised to
  `>=3.22.0` after proving 3.22 is the earliest containing tag from SDK source
  (`git log -S "class WidgetStatePropertyAll"` → commit `6190c5eea1e`;
  `git tag --contains` → first stable `3.22.0`, none in 3.10–3.21). `analyze`,
  pub.dev, and CI all build against an *installed* SDK, never the declared floor —
  the honesty of a floor is a human contract, checked by hand.
- **Format runs after `pub get`** — `dart format` reads the language version from
  `package_config`; this only reproduces in a clean `git worktree`.
- **Coverage floor is 100** — deleting `test/menu_chrome_test.dart` yields exactly
  99.0% (518/523); a floor of 99 would pass (`99.0 < 99.0` is false).
  `// coverage:ignore-*` removes from the denominator.
- **`analyze` runs `--fatal-infos --fatal-warnings`** — an `info` reddens CI.
- Release: `flutter pub publish --dry-run` **0 warnings**, archive excludes
  `build/`/`.dart_tool/`/`coverage/`/`docs/`/`tool/`/`.github/`. A **tag is an
  immutable pointer** — 1.0.0 was tagged/released with 0 attachments while pub.dev
  still showed 0.7.0 as latest; the tag was *moved*, not abandoned for 1.0.1.
- `flutter pub publish` is irreversible — **the agent does not run it; the user does.**

## War-story index

The per-incident evidence (#5, #7, #8, #9, #18, #24, and the 1.0.0 release) lives
in [`lessons.md`](lessons.md), indexed by step.
