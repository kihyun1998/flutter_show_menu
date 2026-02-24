/// A flexible overlay-based menu for Flutter.
///
/// Use [showOverlayMenu] to display a menu anchored to any widget, or wrap a
/// widget with [OverlayMenuButton] for a tap-to-open shortcut.
///
/// Features:
/// - Anchor to any side of the target ([MenuPosition]) with cross-axis
///   alignment ([MenuAlignment]).
/// - Fixed header/footer entries outside the scroll area.
/// - Selected-item highlighting, prefix builders, dividers, and scrollbar
///   customisation via [OverlayMenuStyle].
/// - Automatic dismissal on route changes and programmatic close via
///   [OverlayMenuController].
library flutter_show_menu;

export 'src/menu_position.dart';
export 'src/overlay_menu.dart' show showOverlayMenu, OverlayMenuController;
export 'src/overlay_menu_item.dart';
export 'src/overlay_menu_button.dart';
export 'src/overlay_menu_style.dart';
