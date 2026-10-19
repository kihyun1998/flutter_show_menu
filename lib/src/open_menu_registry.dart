import 'package:flutter/foundation.dart';

import 'open_menu.dart';

/// The Open Menus currently live, app-wide.
///
/// There is one instance, by design. See
/// `docs/adr/0001-global-close-all-registry.md`.
class OpenMenuRegistry {
  OpenMenuRegistry._();

  static final OpenMenuRegistry instance = OpenMenuRegistry._();

  final Set<OpenMenu<Object?>> _menus = <OpenMenu<Object?>>{};

  void register(OpenMenu<Object?> menu) => _menus.add(menu);

  void deregister(OpenMenu<Object?> menu) => _menus.remove(menu);

  /// Closes every live menu immediately, with a null result.
  void closeAll() {
    // Copied first, deliberately; see
    // `docs/map/territory/close-all-registry.md`.
    for (final menu in _menus.toList()) {
      menu.close(null, animated: false);
    }
  }

  /// How many menus are live.
  @visibleForTesting
  int get length => _menus.length;

  /// Forgets every menu without closing it. For `tearDown`.
  @visibleForTesting
  void reset() => _menus.clear();
}

/// Closes every open overlay menu immediately, app-wide.
///
/// Each menu closes with a null result — exactly as it would on a route
/// change — without playing the reverse animation. A menu already part-way
/// through an exit animation is torn down at once; a result it had already
/// latched (a selection, say) is still delivered.
///
/// Use this for non-route moments when every menu must go but you hold no
/// `OverlayMenuController` references: session expiry, app backgrounding,
/// event-driven cleanup. For route changes the menus already auto-close, so
/// this is unnecessary there.
///
/// Safe to call when no menus are open.
void closeAllOverlayMenus() => OpenMenuRegistry.instance.closeAll();
