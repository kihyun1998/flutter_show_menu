/// A flexible overlay-based menu for Flutter.
///
/// Use [showOverlayMenu] to display a menu anchored to any widget, or wrap a
/// widget with [OverlayMenuButton] for a tap-to-open shortcut.
///
/// Features:
/// - Anchor to any side of the target ([MenuPosition]) with cross-axis
///   alignment ([MenuAlignment]).
/// - Fixed header/footer entries outside the scroll area.
/// - Selected-item auto-scroll, dividers, and scrollbar customisation via
///   [OverlayMenuStyle].
/// - Automatic dismissal on route changes and programmatic close via
///   [OverlayMenuController].
/// - App-wide dismissal of every open menu at once via [closeAllOverlayMenus]
///   for non-route moments (session expiry, app backgrounding, etc.).
library;

export 'src/menu_position.dart';
export 'src/open_menu.dart' show OverlayMenuController;
export 'src/open_menu_registry.dart' show closeAllOverlayMenus;
export 'src/overlay_menu.dart' show showOverlayMenu;
export 'src/overlay_menu_barrier.dart';
export 'src/overlay_menu_button.dart';
export 'src/overlay_menu_item.dart';
export 'src/overlay_menu_motion.dart';
export 'src/overlay_menu_placement.dart';
export 'src/overlay_menu_style.dart';
