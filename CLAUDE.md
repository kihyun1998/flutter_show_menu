# CLAUDE.md

## Working discipline — theflow

Substantive changes (bug fix / feature / behavior change) follow the **`theflow`**
skill — run `/theflow` at the start. This repo's bindings (module map, reference
routing, boundary rule, proof methods, surfaces, gate matrix) live in
**`docs/agents/theflow.md`**; the per-incident evidence (#5, #7, #8, #9, #18 …)
in **`docs/agents/lessons.md`**. Read both before starting; add new war-stories
to lessons.

## Identity & invariants (the boundary)

`flutter_show_menu` shows menus through an **`OverlayEntry`** (not a Navigator
route) — a drop-in `showMenu` replacement that positions a menu top/bottom/left/
right of any widget with start/center/end alignment. The full domain language
lives in **`CONTEXT.md`**; decisions in **`docs/adr/`**.

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

There are **no consumers yet** — theflow's downstream steps are N/A (no target),
not skipped.

## Agent skills

### Issue tracker
Issues are tracked as GitHub issues in `kihyun1998/flutter_show_menu`, managed via
the `gh` CLI. Pull requests are not a triage surface. See `docs/agents/issue-tracker.md`.

### Triage labels
Canonical label vocabulary (`needs-triage`, `needs-info`, `ready-for-agent`,
`ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs
Single-context: one `CONTEXT.md` + `docs/adr/` at the repo root. See
`docs/agents/domain.md`.
