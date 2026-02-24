# flutter_show_menu

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

## Install

```yaml
dependencies:
  flutter_show_menu: ^0.1.0
```

## Basic Usage

### Imperative — `showOverlayMenu`

```dart
import 'package:flutter_show_menu/flutter_show_menu.dart';

// Inside a button's onPressed or onTap callback:
final result = await showOverlayMenu<String>(
  context: context,
  items: [
    OverlayMenuItem(value: 'edit', child: Text('Edit')),
    OverlayMenuItem(value: 'delete', child: Text('Delete')),
  ],
  position: MenuPosition.bottom,
  alignment: MenuAlignment.start,
);

if (result != null) {
  print('Selected: $result');
}
```

### Declarative — `OverlayMenuButton`

```dart
OverlayMenuButton<String>(
  position: MenuPosition.right,
  alignment: MenuAlignment.center,
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
| `context` | `BuildContext` | **required** | BuildContext of the target widget (used to calculate position) |
| `items` | `List<OverlayMenuItem<T>>` | **required** | List of menu items to display |
| `position` | `MenuPosition` | `bottom` | Which side of the target the menu appears on |
| `alignment` | `MenuAlignment` | `start` | Cross-axis alignment of the menu |
| `offset` | `Offset` | `Offset.zero` | Additional offset for fine-tuning position |
| `barrierDismissible` | `bool` | `true` | Whether tapping outside the menu dismisses it |
| `barrierColor` | `Color?` | `null` | Backdrop color behind the menu |
| `decoration` | `BoxDecoration?` | `null` | Custom decoration for the menu container |
| `padding` | `EdgeInsets?` | `EdgeInsets.symmetric(vertical: 4)` | Inner padding of the menu |
| `constraints` | `BoxConstraints?` | `null` | Size constraints for the menu |
| `width` | `double?` | `null` | Fixed width for the menu |
| `animationDuration` | `Duration` | `150ms` | Duration of enter/exit animation |
| `animationCurve` | `Curve` | `Curves.easeOutCubic` | Animation curve |

**Returns** `Future<T?>` — the selected item's value, or `null` if dismissed.

### `OverlayMenuButton<T>`

A widget that wraps a child and shows an overlay menu on tap.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `child` | `Widget` | **required** | The tap target widget |
| `items` | `List<OverlayMenuItem<T>>` | **required** | List of menu items |
| `position` | `MenuPosition` | `bottom` | Menu position relative to child |
| `alignment` | `MenuAlignment` | `start` | Cross-axis alignment |
| `offset` | `Offset` | `Offset.zero` | Additional position offset |
| `onSelected` | `ValueChanged<T>?` | `null` | Callback when an item is selected |
| `onCanceled` | `VoidCallback?` | `null` | Callback when menu is dismissed without selection |
| `barrierDismissible` | `bool` | `true` | Whether outside tap dismisses the menu |
| `barrierColor` | `Color?` | `null` | Backdrop color |
| `decoration` | `BoxDecoration?` | `null` | Menu container decoration |
| `menuPadding` | `EdgeInsets?` | `EdgeInsets.symmetric(vertical: 4)` | Menu inner padding |
| `menuConstraints` | `BoxConstraints?` | `null` | Menu size constraints |
| `menuWidth` | `double?` | `null` | Fixed menu width |
| `animationDuration` | `Duration` | `150ms` | Animation duration |
| `animationCurve` | `Curve` | `Curves.easeOutCubic` | Animation curve |
| `enabled` | `bool` | `true` | Whether the button responds to taps |

### `OverlayMenuItem<T>`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | `T?` | `null` | Value returned when this item is selected |
| `child` | `Widget` | **required** | Content widget of the menu item |
| `onTap` | `VoidCallback?` | `null` | Additional callback on tap (runs alongside value return) |
| `enabled` | `bool` | `true` | Whether the item is tappable |
| `height` | `double` | `48.0` | Item height |
| `padding` | `EdgeInsets?` | `EdgeInsets.symmetric(horizontal: 16)` | Item inner padding |

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
