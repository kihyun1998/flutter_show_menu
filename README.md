# flutter_show_menu

[![pub package](https://img.shields.io/pub/v/flutter_show_menu.svg)](https://pub.dev/packages/flutter_show_menu)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A drop-in replacement for Flutter's built-in `showMenu` using `OverlayEntry`.

Position menus relative to any widget with full control over direction, alignment, animation, and styling.

## Features

- **OverlayEntry-based** — no Navigator route pushed, no context limitations
- **Directional positioning** — place the menu on top, bottom, left, or right of the target
- **Cross-axis alignment** — align start, center, or end along the opposite axis
- **Auto flip** — automatically flips to the opposite side when overflowing the screen edge
- **Smooth animation** — fade + scale with configurable duration and curve
- **Two API styles** — imperative function (`showOverlayMenu`) and declarative widget (`OverlayMenuButton`)
- **Barrier support** — dismiss on outside tap with optional backdrop color
- **Rich styling** — `OverlayMenuStyle` with grouped sub-classes for item, divider, and scrollbar styles
- **Divider support** — `OverlayMenuDivider` entries between items
- **Scrollable menu** — `maxHeight` with automatic scrolling and scrollbar theming
- **Auto-scroll via `initialValue`** — when reopening a scrollable menu, the matching item is automatically centered in the viewport
- **Header / Footer** — fixed entries pinned above/below the scrollable area with independent styling
- **Auto-close on navigation** — menu automatically dismisses when the route is popped or a new route is pushed
- **Overlay child** — full-screen overlay above the barrier (e.g. drag-to-move area)
- **Programmatic close** — `OverlayMenuController` for explicit dismissal with safe idempotent `close()`

## Install

```yaml
dependencies:
  flutter_show_menu: ^1.0.1
```

## Basic Usage

### Imperative — `showOverlayMenu`

```dart
import 'package:flutter_show_menu/flutter_show_menu.dart';

final result = await showOverlayMenu<String>(
  context: context,
  items: [
    OverlayMenuItem(value: 'edit', child: Text('Edit')),
    OverlayMenuItem(value: 'delete', child: Text('Delete')),
  ],
  placement: OverlayMenuPlacement(
    position: MenuPosition.bottom,
    alignment: MenuAlignment.start,
  ),
);

if (result != null) {
  print('Selected: $result');
}
```

### Declarative — `OverlayMenuButton`

```dart
OverlayMenuButton<String>(
  placement: OverlayMenuPlacement(
    position: MenuPosition.right,
    alignment: MenuAlignment.center,
  ),
  items: [
    OverlayMenuItem(value: 'edit', child: Text('Edit')),
    OverlayMenuItem(value: 'share', child: Text('Share')),
    OverlayMenuItem(value: 'delete', child: Text('Delete')),
  ],
  onSelected: (value) => print('Selected: $value'),
  onCanceled: () => print('Dismissed'),
  child: Icon(Icons.more_vert),
)
```

### With Styling, Dividers, and Initial Value

```dart
final result = await showOverlayMenu<String>(
  context: context,
  initialValue: 'home',
  items: [
    OverlayMenuItem(value: 'home', child: Text('Home')),
    OverlayMenuDivider(),
    OverlayMenuItem(value: 'settings', child: Text('Settings')),
    OverlayMenuItem(value: 'logout', child: Text('Logout')),
  ],
  style: OverlayMenuStyle(
    backgroundColor: Colors.white,
    borderRadius: BorderRadius.circular(12),
    maxHeight: 300,
    itemStyle: OverlayMenuItemStyle(
      height: 44,
      borderRadius: BorderRadius.circular(8),
      hoverColor: Colors.blue.withValues(alpha: 0.08),
    ),
    dividerStyle: OverlayMenuDividerStyle(color: Colors.grey.shade300),
  ),
);
```

### With Header and Footer

```dart
final result = await showOverlayMenu<String>(
  context: context,
  header: [
    OverlayMenuItem(value: 'search', child: Text('Search...')),
    OverlayMenuDivider(),
  ],
  items: [
    OverlayMenuItem(value: 'home', child: Text('Home')),
    OverlayMenuItem(value: 'settings', child: Text('Settings')),
    OverlayMenuItem(value: 'profile', child: Text('Profile')),
  ],
  footer: [
    OverlayMenuDivider(),
    OverlayMenuItem(value: 'create', child: Text('Create New')),
  ],
  style: OverlayMenuStyle(
    maxHeight: 250,
    headerStyle: OverlayMenuHeaderStyle(height: 40),
    footerStyle: OverlayMenuFooterStyle(height: 40),
  ),
);
```

## Position & Alignment

`MenuPosition` determines **which side** of the target the menu appears on.
`MenuAlignment` determines how the menu is aligned on the **cross axis**.

```
            start   center    end
              ↓       ↓        ↓
            ┌──────────────────────┐
            │     top menu         │
            └──────────────────────┘
            ┌──────────────────────┐
left menu   │     Target Widget    │   right menu
            └──────────────────────┘
            ┌──────────────────────┐
            │    bottom menu       │
            └──────────────────────┘
```

| Position | Alignment | Result |
|----------|-----------|--------|
| `bottom` | `start` | Below target, left-aligned |
| `bottom` | `center` | Below target, centered |
| `bottom` | `end` | Below target, right-aligned |
| `top` | `start` | Above target, left-aligned |
| `right` | `center` | Right of target, vertically centered |
| `left` | `end` | Left of target, aligned to bottom edge |

When the menu overflows the screen edge, it automatically **flips** to the opposite side.

## API Reference

### `showOverlayMenu<T>`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `context` | `BuildContext` | **required** | BuildContext of the target widget. Must be mounted and have a `RenderBox` — the menu is anchored to its box |
| `items` | `List<OverlayMenuEntry<T>>` | **required** | List of menu entries (items and dividers) |
| `header` | `List<OverlayMenuEntry<T>>?` | `null` | Fixed entries pinned above the scrollable area |
| `footer` | `List<OverlayMenuEntry<T>>?` | `null` | Fixed entries pinned below the scrollable area |
| `initialValue` | `T?` | `null` | Value of the item to auto-scroll to when the menu opens |
| `placement` | `OverlayMenuPlacement` | `const OverlayMenuPlacement()` | Where the menu sits relative to the target |
| `barrier` | `OverlayMenuBarrier` | `const OverlayMenuBarrier()` | The area behind the menu and how it behaves |
| `motion` | `OverlayMenuMotion` | `const OverlayMenuMotion()` | How the menu animates in and out |
| `style` | `OverlayMenuStyle?` | `null` | Colors, sizing, item styles, scrollbar |
| `controller` | `OverlayMenuController?` | `null` | Controller for programmatic close |

**Returns** `Future<T?>` — the selected item's value, or `null` if dismissed. The value is
fixed the moment the close is requested, so an item whose `onTap` navigates still returns
its selection.

**Throws** a `FlutterError` when `context` is unmounted, or when its render object is not a
`RenderBox` — a context taken from above a sliver, for instance. Wrap the anchor in a
`Builder` that sits below any sliver and pass that `Builder`'s context.

### Configuration groups

#### `OverlayMenuPlacement`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `position` | `MenuPosition` | `bottom` | Which side of the target the menu appears on |
| `alignment` | `MenuAlignment` | `start` | Cross-axis alignment of the menu |
| `offset` | `Offset` | `Offset.zero` | Pixel offset applied after positioning |

#### `OverlayMenuBarrier`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `dismissible` | `bool` | `true` | Whether tapping outside the menu closes it |
| `color` | `Color?` | `null` | Backdrop color behind the menu |
| `overlayChild` | `Widget?` | `null` | Drawn above the barrier and below the menu (e.g. drag-to-move area) |

#### `OverlayMenuMotion`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `duration` | `Duration` | `150ms` | Duration of the enter and exit animation |
| `curve` | `Curve` | `Curves.easeOutCubic` | Curve of the enter and exit animation |

Every configuration class — the three above, `OverlayMenuStyle`, and its nested
`OverlayMenuItemStyle`, `OverlayMenuDividerStyle`, and `OverlayMenuScrollbarStyle` — is
const-constructible with defaults and provides `copyWith`, `==`, and `hashCode`. Equality
composes, so two styles differing only in a nested field compare unequal.

Two fields compare by identity, because their own types do: `OverlayMenuMotion.curve`
(`Curve` defines no `==`) and `OverlayMenuBarrier.overlayChild` (`Widget` compares by
identity).

### `OverlayMenuController`

Controller for programmatically closing an open menu. Safe to call `close()` multiple times.

| Property / Method | Type | Description |
|-------------------|------|-------------|
| `isClosed` | `bool` | Whether a close has been requested. True immediately, before the exit animation ends |
| `close()` | `void` | Closes the menu, playing the exit animation. No-op if already closed |

```dart
final controller = OverlayMenuController();

showOverlayMenu<String>(
  context: context,
  items: [...],
  controller: controller,
);

// Later — safe even if the menu was already dismissed:
controller.close();
```

> **Note:** The menu also auto-closes when the current route is popped or a new route is pushed on top — no controller needed for navigation scenarios.

### `closeAllOverlayMenus()`

Closes **every** open overlay menu app-wide at once — immediately and with a `null` result — without needing an `OverlayMenuController` reference to each one.

```dart
import 'package:flutter_show_menu/flutter_show_menu.dart';

// e.g. on session expiry, deep inside a service that holds no menu references:
closeAllOverlayMenus();
```

Use it for **non-route** moments when every menu must disappear but you can't reach the controllers — session expiry, app backgrounding, an incoming event that resets the UI. It closes any number of open menus (zero, one, or many) and is a safe no-op when none are open.

A menu part-way through its exit animation is torn down at once, and still delivers the value the user had already selected — the result is fixed when the close is requested, not when the animation ends.

> **Note:** For navigation, you don't need this — menus already auto-close when the route changes (see the note above). `closeAllOverlayMenus()` exists for the cases where no route change happens.

### `OverlayMenuButton<T>`

A widget that wraps a child and shows an overlay menu on tap.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
Takes the same configuration as `showOverlayMenu`, plus a tap target and selection callbacks.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `child` | `Widget` | **required** | The tap target widget |
| `items` | `List<OverlayMenuEntry<T>>` | **required** | List of menu entries |
| `header` | `List<OverlayMenuEntry<T>>?` | `null` | Fixed entries pinned above the scrollable area |
| `footer` | `List<OverlayMenuEntry<T>>?` | `null` | Fixed entries pinned below the scrollable area |
| `initialValue` | `T?` | `null` | Value of the item to auto-scroll to when the menu opens |
| `placement` | `OverlayMenuPlacement` | `const OverlayMenuPlacement()` | Where the menu sits relative to the child |
| `barrier` | `OverlayMenuBarrier` | `const OverlayMenuBarrier()` | The area behind the menu and how it behaves |
| `motion` | `OverlayMenuMotion` | `const OverlayMenuMotion()` | How the menu animates in and out |
| `style` | `OverlayMenuStyle?` | `null` | Colors, sizing, item styles, scrollbar |
| `controller` | `OverlayMenuController?` | `null` | Controller for programmatic close |
| `onSelected` | `ValueChanged<T>?` | `null` | Callback when an item is selected |
| `onCanceled` | `VoidCallback?` | `null` | Callback when menu is closed without selection |
| `enabled` | `bool` | `true` | Whether the button responds to taps |

### `OverlayMenuEntry<T>` (sealed)

Base type for menu entries. Two subtypes:

#### `OverlayMenuItem<T>`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | `T?` | `null` | Value returned when this item is selected |
| `child` | `Widget` | **required** | Content widget of the menu item |
| `onTap` | `VoidCallback?` | `null` | Additional callback on tap |
| `enabled` | `bool` | `true` | Whether the item is tappable |
| `height` | `double?` | `null` | Item height (falls back to style, then `48.0`) |

#### `OverlayMenuDivider<T>`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `color` | `Color?` | `null` | Divider color (falls back to style) |
| `thickness` | `double?` | `null` | Divider thickness (falls back to style, then `1.0`) |
| `height` | `double?` | `null` | Total height including surrounding space (falls back to style, then `thickness`) |
| `indent` | `double?` | `null` | Leading indent |
| `endIndent` | `double?` | `null` | Trailing indent |

### `OverlayMenuStyle`

| Parameter | Type | Description |
|-----------|------|-------------|
| `backgroundColor` | `Color?` | Menu surface color (falls back to `surfaceContainer`) |
| `borderRadius` | `BorderRadius?` | Menu surface border radius (falls back to `circular(8)`) |
| `padding` | `EdgeInsets?` | Menu container inner padding (falls back to `symmetric(vertical: 4)`) |
| `maxHeight` | `double?` | Max menu height; scrolls when exceeded |
| `width` | `double?` | Fixed menu width; sizes to content when null |
| `constraints` | `BoxConstraints?` | Extra box constraints around the menu |
| `decoration` | `BoxDecoration?` | Extra decoration around the menu surface |
| `itemStyle` | `OverlayMenuItemStyle?` | Default item styling |
| `headerStyle` | `OverlayMenuHeaderStyle?` | Style override for header items |
| `footerStyle` | `OverlayMenuFooterStyle?` | Style override for footer items |
| `dividerStyle` | `OverlayMenuDividerStyle?` | Divider defaults |
| `scrollbarStyle` | `OverlayMenuScrollbarStyle?` | Scrollbar theming (when `maxHeight` is set) |

### `OverlayMenuItemStyle`

| Parameter | Type | Description |
|-----------|------|-------------|
| `height` | `double?` | Default item height (falls back to `48.0`) |
| `borderRadius` | `BorderRadius?` | Item border radius for InkWell and selection |
| `backgroundColor` | `Color?` | Item background color (painted on ink layer) |
| `selectedBackgroundColor` | `Color?` | Background color for the selected item matched by `initialValue` (painted on ink layer) |
| `hoverColor` | `Color?` | Hover color |
| `splashColor` | `Color?` | Splash color |
| `highlightColor` | `Color?` | Highlight color |
| `focusColor` | `Color?` | Focus color |
| `mouseCursor` | `MouseCursor?` | Mouse cursor (falls back to `SystemMouseCursors.click`) |

> **Note:** Do not apply background colors directly in the item's `child` widget (e.g. `Container(color: ...)`). Child widgets are painted on top of the ink layer, which will cover InkWell hover/splash effects. Use `backgroundColor` and `selectedBackgroundColor` instead — they are painted on the ink layer so hover/splash renders correctly on top.

### `OverlayMenuDividerStyle`

| Parameter | Type | Description |
|-----------|------|-------------|
| `color` | `Color?` | Divider color (falls back to theme default) |
| `thickness` | `double?` | Divider thickness (falls back to `1.0`) |
| `height` | `double?` | Total height including surrounding space (falls back to `thickness`) |
| `indent` | `double?` | Leading indent (falls back to `0`) |
| `endIndent` | `double?` | Trailing indent (falls back to `0`) |

### `OverlayMenuHeaderStyle` / `OverlayMenuFooterStyle`

Type aliases for `OverlayMenuItemStyle`. Same parameters as `OverlayMenuItemStyle` above.

### `OverlayMenuScrollbarStyle`

| Parameter | Type | Description |
|-----------|------|-------------|
| `thumbColor` | `Color?` | Scrollbar thumb color |
| `thickness` | `double?` | Scrollbar thickness |
| `radius` | `Radius?` | Scrollbar corner radius |
| `thumbVisibility` | `bool?` | Whether the thumb is always visible |

### `MenuPosition`

| Value | Description |
|-------|-------------|
| `top` | Menu appears above the target |
| `bottom` | Menu appears below the target |
| `left` | Menu appears to the left of the target |
| `right` | Menu appears to the right of the target |

### `MenuAlignment`

| Value | Description |
|-------|-------------|
| `start` | Aligned to the start edge (left for top/bottom, top for left/right) |
| `center` | Centered on the cross axis |
| `end` | Aligned to the end edge (right for top/bottom, bottom for left/right) |

## Example

The `example/` directory contains a playground app where you can interactively test all parameters — position, alignment, offset, styling, animation, and theme.

```bash
cd example
flutter run
```
