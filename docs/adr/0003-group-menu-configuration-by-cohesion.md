# Group menu configuration by cohesion, not by history

## Context

One set of menu configuration was declared three times: 18 parameters on `showOverlayMenu`, 18 fields on the internal menu widget, and 19 on `OverlayMenuButton`, which forwarded 15 of them by hand.

This was not a theoretical duplication cost. It had already drifted. The button renamed `constraints` to `menuConstraints` and `width` to `menuWidth`, and silently dropped `initialValue` and `controller` — so a caller who wanted a `Controller` could not use `OverlayMenuButton` at all, and nothing in the code said so.

The group boundaries that did exist were drawn by history rather than by cohesion. `OverlayMenuStyle` already held `maxHeight`, while its siblings `width` and `constraints` sat top-level next to `decoration` — whose own siblings `backgroundColor` and `borderRadius` were back inside the style. One concept family, two homes.

The package was heading for 1.0.0, after which the exported signature is effectively frozen.

## Decision

Fold the parameters into value objects grouped by what they cohere around, and have both entry points accept the same objects:

| Group | Holds |
| --- | --- |
| `OverlayMenuPlacement` | `position`, `alignment`, `offset` |
| `OverlayMenuBarrier` | `dismissible`, `color`, `overlayChild` |
| `OverlayMenuMotion` | `duration`, `curve` |
| `OverlayMenuStyle` | existing fields **plus** `width`, `constraints`, `decoration` |

`context`, `items`, `header`, `footer`, `initialValue`, and `controller` stay top-level: they are the anchor, the subject, and a handle — not configuration. `showOverlayMenu` drops from 18 parameters to 10.

Every group is const-constructible with defaults, so `showOverlayMenu(context: c, items: [...])` still compiles unchanged.

## Considered Options

- **One `OverlayMenuConfig` object** — shortest signature (4 parameters), but the grouping criterion becomes "everything else" rather than cohesion, and changing one `offset` means constructing a 15-field object. It moves the problem rather than solving it.
- **Fold `motion` into `OverlayMenuStyle`** — animation is arguably visual style. Rejected: the style object would reach 13 fields, which is the very ache being treated. ADR-0002 also made the exit animation a first-class distinction, so motion has room to grow (an exit-specific duration, say).
- **Additive with `@Deprecated`** — keep the 18 parameters, add the grouped path, remove the old one next major. Rejected: a release carrying two parallel call styles is *less* cohesive than either, and 1.0.0 was the moment to take the break.
- **Internal-only grouping** — apply the objects between the widget and the button, leave the public signature alone. Rejected once 1.0.0 was chosen: it fixes the drift but leaves the public interface unable to express the sizing family in one place.

## Consequences

- Breaking. Callers move `position`/`alignment`/`offset` into `placement:`, `barrierDismissible`/`barrierColor`/`overlayChild` into `barrier:`, `animationDuration`/`animationCurve` into `motion:`, and `width`/`constraints`/`decoration` into `style:`.
- `OverlayMenuButton` gains `initialValue` and `controller` as a consequence of sharing the configuration, not as a separate feature. The drift cannot recur: there are no individual parameters left to forward.
- Adding a menu feature now touches one field on one object instead of four declaration sites.
- The four objects are exported and are part of the 1.0.0 surface. Adding a field to any of them is non-breaking; moving a field between them is not.
