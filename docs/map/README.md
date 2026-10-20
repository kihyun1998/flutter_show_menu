# Territory map

The territory map: notes on what this package does, what else moves when
you touch each part, and what each part was decided on. A comment's why,
its trap and its measured value go to a note here (the rule is in
[`CLAUDE.md`](../../CLAUDE.md#comments)).

<!-- grill-map build stamp: b62786b -->

## The two questions

- **If I touch this, what else moves?** Open the territory for what you are
  changing and work through its `## Blast radius` and
  `## Cross-cutting invariants` as a checklist. Each edge says why it is
  there.
- **What was this decided on?** Open the territory's
  `## Governing decisions`. `**None.**` there is the answer: nobody decided
  it, and its `## Design model` was read from the source.

## Reading protocol

- **Before the change**, open the note for each territory you expect to
  touch, before settling on a design. Write that list down; the
  completion test below compares it with what you actually touched.
- **After the change**, bring those notes back in line. Then ask the
  promotion question: *is the fact this fix revealed also true outside this
  territory?* For this package that usually means: does it hold at every
  other Close trigger, or at every other reader of the same layout pass? If
  yes, it goes in an invariant note before the fix lands.
- Run `dart run tool/check_map.dart` (or pass it one note) after editing.
  CI runs it over the whole map.

## Why the layer exists

Two bugs in this package crossed territories that no file connected:

- Centring `initialValue` against `maxHeight` instead of the real viewport
  (#5). The viewport is decided in [menu body layout](territory/menu-body-layout.md),
  and the arithmetic lives in [entry metrics](territory/entry-metrics.md).
- The scale origin not following the flip (#18). The flip is decided in
  [placement and flip](territory/placement-and-flip.md) during layout, and
  the origin is applied in [scale origin](territory/scale-origin.md) during
  paint.

Each pair is now one hop apart.

## Conventions

- Territories overlap, and a fact that holds in several of them gets an
  invariant note rather than being forced into one.
- Every territory note has the same headings, and every invariant note has
  the same headings. `tool/check_map.dart` holds the two lists.
- An empty section keeps its heading and says `**None.**`. Do not delete it.
- `## Code` names symbols by file (`` - `file` — `Symbol`, `Type.member` ``),
  never line numbers. The first backticked name on a bullet is the file.
- Links are plain relative markdown links, so they work on GitHub and in
  Obsidian.
- A reference fact is linked to where it was proven, never restated.

## What the map cannot answer

- Issues and source files are not nodes. They appear as text inside notes.
- No reference fact is pinned to a Flutter SDK commit. Facts proven from SDK
  source live in [theflow, Step 1](../agents/theflow.md#step-1--reference-routing-table),
  in ADR text and in the pin test for `TickerFuture`, all unpinned. A note
  that links them inherits that.
- Material `showMenu`, the reference this package is an example against
  ([`thegraph.md`](../agents/thegraph.md)), has not been compared with any
  territory.

## Measurements (2026-10-19)

- Public surface: about twenty exported types and functions. Four ADRs
  govern them. ADR-0001 and ADR-0002 cover Close, the Controller and Close
  All. ADR-0003 covers the configuration objects. ADR-0004 covers one
  internal mechanism. Placement, the entry model, the body layout, the
  surface fallbacks and the anchor contract have no record. Since then,
  ADR-0005 (2026-10-20) covers what a flip does to the offset, and
  ADR-0006 (2026-10-20) covers when a menu flips.
- `lib/src/overlay_menu.dart` holds about a quarter of `lib/` and the most
  churn, and ten territory notes name it. The map
  splits it further than the module tree does.

To list the territories nobody decided, scope the query to its heading,
because the same sentinel marks several sections:

```sh
rg -lU '## Governing decisions\r?\n\r?\n\*\*None\.\*\*' docs/map/territory/
rg -lU '## Reference behaviour\r?\n\r?\n\*\*None\.\*\*' docs/map/territory/
rg -l 'lib/src/overlay_menu.dart' docs/map/territory/
```

## Coverage, and what an absent note means

The map covers the whole package as of the commit that added it, including
release and CI. So a part of the package with no note is a gap, not a
correct state. A new note is owed when a change adds behaviour that no
territory's `## What it is` covers.

## Completion test

This repo has no rediscovered bug yet, so the test predicts forward. Before
the next change that alters behaviour inside the mapped area, write down
from the map alone which territories it should touch. Afterwards, compare
that with what it actually touched. A miss is a missing blast edge, and it
is scored by recall.

## Notes

Territories: [public surface](territory/public-surface.md) ·
[anchor contract](territory/anchor-contract.md) ·
[placement and flip](territory/placement-and-flip.md) ·
[scale origin](territory/scale-origin.md) ·
[enter/exit motion](territory/enter-exit-motion.md) ·
[Close lifecycle](territory/close-lifecycle.md) ·
[Controller](territory/controller.md) ·
[route Auto-close](territory/route-auto-close.md) ·
[Open Menu Registry and Close All](territory/close-all-registry.md) ·
[barrier](territory/barrier.md) ·
[menu body layout](territory/menu-body-layout.md) ·
[entry metrics](territory/entry-metrics.md) ·
[entry rendering](territory/entry-rendering.md) ·
[configuration objects](territory/configuration-objects.md) ·
[surface style](territory/surface-style.md) ·
[OverlayMenuButton](territory/overlay-menu-button.md) ·
[release and publish](territory/release-and-publish.md) ·
[CI gates](territory/ci-gates.md)

Invariants: [result latched at Close request](invariant/result-latched-at-request.md) ·
[one Close path](invariant/one-close-path.md) ·
[force decides Animated vs Instant](invariant/close-force-decides-animation.md)
