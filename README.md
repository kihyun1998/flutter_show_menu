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
- **Rich styling** — `OverlayMenuStyle` with grouped sub-classes for item, selected, divider, and scrollbar styles
- **Divider support** — `OverlayMenuDivider` entries between items
- **Selected state** — per-item `selected` flag with customizable background, text style, and border
- **Prefix builder** — per-item or style-level leading widget with selected state awareness
- **Scrollable menu** — `maxHeight` with automatic scrolling and scrollbar theming

## Install

```yaml
dependencies:
  flutter_show_menu: ^0.1.0
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

### With Styling, Dividers, and Selected State

```dart
final result = await showOverlayMenu<String>(
  context: context,
  items: [
    OverlayMenuItem(value: 'home', selected: true, child: Text('Home')),
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
      padding: EdgeInsets.symmetric(horizontal: 12),
      hoverColor: Colors.blue.withValues(alpha: 0.08),
    ),
    selectedStyle: OverlayMenuSelectedStyle(
      backgroundColor: Colors.blue.withValues(alpha: 0.12),
      textStyle: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
    ),
    dividerStyle: OverlayMenuDividerStyle(color: Colors.grey.shade300),
    prefixBuilder: (context, selected) => Icon(
      selected ? Icons.check_circle : Icons.circle_outlined,
      size: 20,
    ),
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
| `context` | `BuildContext` | **required** | BuildContext of the target widget |
| `items` | `List<OverlayMenuEntry<T>>` | **required** | List of menu entries (items and dividers) |
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
| `style` | `OverlayMenuStyle?` | `null` | Visual style options |

**Returns** `Future<T?>` — the selected item's value, or `null` if dismissed.

### `OverlayMenuButton<T>`

A widget that wraps a child and shows an overlay menu on tap.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `child` | `Widget` | **required** | The tap target widget |
| `items` | `List<OverlayMenuEntry<T>>` | **required** | List of menu entries |
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
| `style` | `OverlayMenuStyle?` | `null` | Visual style options |

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
| `padding` | `EdgeInsets?` | `null` | Item inner padding (falls back to style) |
| `selected` | `bool` | `false` | Whether this item is marked as selected |
| `prefixBuilder` | `Widget Function(BuildContext, bool)?` | `null` | Leading widget builder (overrides style-level) |

#### `OverlayMenuDivider<T>`

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `color` | `Color?` | `null` | Divider color (falls back to style) |
| `thickness` | `double?` | `null` | Divider thickness (falls back to style, then `1.0`) |
| `indent` | `double?` | `null` | Leading indent |
| `endIndent` | `double?` | `null` | Trailing indent |

### `OverlayMenuStyle`

| Parameter | Type | Description |
|-----------|------|-------------|
| `backgroundColor` | `Color?` | Menu surface color (falls back to `surfaceContainer`) |
| `borderRadius` | `BorderRadius?` | Menu surface border radius (falls back to `circular(8)`) |
| `maxHeight` | `double?` | Max menu height; scrolls when exceeded |
| `itemStyle` | `OverlayMenuItemStyle?` | Default item styling |
| `selectedStyle` | `OverlayMenuSelectedStyle?` | Selected item styling |
| `dividerStyle` | `OverlayMenuDividerStyle?` | Divider defaults |
| `scrollbarStyle` | `OverlayMenuScrollbarStyle?` | Scrollbar theming (when `maxHeight` is set) |
| `prefixBuilder` | `Widget Function(BuildContext, bool)?` | Default prefix builder for all items |

### `OverlayMenuItemStyle`

| Parameter | Type | Description |
|-----------|------|-------------|
| `height` | `double?` | Default item height (falls back to `48.0`) |
| `padding` | `EdgeInsets?` | Default item padding (falls back to `horizontal: 16`) |
| `borderRadius` | `BorderRadius?` | Item border radius for InkWell and selection |
| `textStyle` | `TextStyle?` | Default text style |
| `hoverColor` | `Color?` | Hover color |
| `splashColor` | `Color?` | Splash color |
| `highlightColor` | `Color?` | Highlight color |
| `focusColor` | `Color?` | Focus color |
| `mouseCursor` | `MouseCursor?` | Mouse cursor (falls back to `SystemMouseCursors.click`) |

### `OverlayMenuSelectedStyle`

| Parameter | Type | Description |
|-----------|------|-------------|
| `backgroundColor` | `Color?` | Background color for selected items |
| `textStyle` | `TextStyle?` | Text style override (merged on top of item textStyle) |
| `border` | `BorderSide?` | Border around selected items |

### `OverlayMenuDividerStyle`

| Parameter | Type | Description |
|-----------|------|-------------|
| `color` | `Color?` | Divider color (falls back to theme default) |
| `thickness` | `double?` | Divider thickness (falls back to `1.0`) |

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
