# CLAUDE.md

## Working discipline — thegraph

Substantive changes (bug fix / feature / behavior change) run through
**`/thegraph`**. The outside sources this package is read against are in
**`docs/agents/thegraph.md`**; what each part does and what moves with it is the
territory map under [`docs/map/`](docs/map/README.md); the per-incident evidence
(#5, #7, #8, #9, #18 …) is in **`docs/agents/lessons.md`**. Read the territory
notes you will touch and lessons before starting; add new war-stories to lessons.

## Identity & invariants (the boundary)

`flutter_show_menu` shows menus through an **`OverlayEntry`** (not a Navigator
route) — a drop-in `showMenu` replacement that positions a menu top/bottom/left/
right of any widget with start/center/end alignment. The full domain language
lives in **`GLOSSARY.md`**; decisions in **`docs/adr/`**.

- **`Close` latches its result the moment it is *requested*** (ADR-0002), not when
  the exit animation ends; a second Close arriving first cannot change it. Every
  human-asked Close is **Animated**; force-cleanup (route-change **Auto-close**,
  **Close All**) is **Instant**.
- **The `Open Menu Registry` is app-wide** (ADR-0001) — `closeAllOverlayMenus`
  finds menus the caller holds no `OverlayMenuController` for. A menu part-way
  through an Animated Close is still in the registry.
- **The scale origin is resolved during *layout*** (ADR-0004) by a custom render
  object, because flip needs the menu's own size — a build-time prediction or a
  one-frame-late notifier gets the first (largest-scale) frame wrong (#18).
- **Fix at the layer where the invariant is decided**, and prove a defensive
  `catch`/guard's reachability from SDK source before adding or removing it (#9).
- **`showOverlayMenu` requires the anchor `context` to have a `RenderBox`** — this
  package's *contract*, guarded with a `FlutterError`. An unmounted anchor makes
  Flutter throw inside an `assert` (silent in release); that is not the SDK's
  defect but ours to state and check (#8).

There are **no consumers yet** — downstream verification and migration are N/A
(no target), not skipped.

## Comments

A comment says what the code is. Why it is this way, what it deliberately leaves
out, the trap and the measured value go to the territory note under
[`docs/map/`](docs/map/README.md).
Where none seems to hold it, search the folder and the code symbol first; only
then start a new note, named for what the system does there, not for the file.
History goes to the commit message. Comments written before this rule still carry
the rest: never delete one whose content the map does not yet hold — move it
first (`decant`). A doc-comment on an exported symbol keeps the behaviour a caller
depends on, even where it reads like a why: `docs/` does not ship, so pub.dev
users cannot read the map.

## Agent skills

### Issue tracker
Issues are tracked as GitHub issues in `kihyun1998/flutter_show_menu`, managed via
the `gh` CLI. Pull requests are not a triage surface. See `docs/agents/issue-tracker.md`.

### Triage labels
Canonical label vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`,
`ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs
Single-context: one `GLOSSARY.md` + `docs/adr/` at the repo root. See
`docs/agents/domain.md`.
