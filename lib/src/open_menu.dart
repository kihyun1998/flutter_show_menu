import 'dart:async';

import 'package:flutter/widgets.dart';

import 'open_menu_registry.dart';

/// Where an Open Menu is in its life.
///
/// One variable, not a flag per collaborator. `closing` means the Close has
/// been requested and the result is latched; the exit animation may still be
/// playing. `closed` means the resources are gone and the result delivered.
enum _Phase { open, closing, closed }

/// Plays the menu's exit animation and completes when it has finished — or
/// when its ticker was cancelled because the menu was torn down first.
typedef ExitAnimator = Future<void> Function();

/// Controller to programmatically close an open overlay menu.
///
/// Pass this to the `controller` parameter of `showOverlayMenu`.
/// Call [close] to Close the menu. Safe to call even if already closed.
///
/// ```dart
/// final controller = OverlayMenuController();
/// showOverlayMenu(
///   context: context,
///   items: [...],
///   controller: controller,
/// );
///
/// // Later, when you want to close the menu:
/// controller.close();
/// ```
class OverlayMenuController {
  OpenMenu<Object?>? _menu;
  bool _isClosed = false;

  /// Whether the menu is already closed.
  ///
  /// Becomes true the moment a Close is requested, before the exit animation
  /// has finished playing.
  bool get isClosed => _isClosed;

  /// Closes the menu, playing the exit animation. Safe to call when already
  /// closed, and when no menu was ever shown.
  void close() {
    if (_isClosed) return;
    final menu = _menu;
    if (menu == null) {
      _isClosed = true;
      return;
    }
    menu.close(null, animated: true);
  }

  void _bind(OpenMenu<Object?> menu) {
    _menu = menu;
    _isClosed = false;
  }

  void _markClosed() => _isClosed = true;

  void _unbind(OpenMenu<Object?> menu) {
    if (identical(_menu, menu)) _menu = null;
  }
}

/// The lifetime of one Open Menu.
///
/// Owns the overlay entry, the awaited result, the registry membership, the
/// [OverlayMenuController] binding, and the route listeners that drive
/// Auto-close. Every Close path — selection, barrier tap, Controller, route
/// change, Close All — goes through [close], which is the only place any of
/// those five are released.
///
/// The result is latched when a Close is *requested*, not when the exit
/// animation ends. An instant Close arriving mid-animation cuts the animation
/// short but never changes the latched result.
class OpenMenu<T> {
  OpenMenu({
    OverlayMenuController? controller,
    ModalRoute<Object?>? route,
  })  : _controller = controller,
        _route = route {
    controller?._bind(this);
    _route?.animation?.addStatusListener(_onRouteStatus);
    _route?.secondaryAnimation?.addStatusListener(_onSecondaryRouteStatus);
    OpenMenuRegistry.instance.register(this);
  }

  final OverlayMenuController? _controller;
  final ModalRoute<Object?>? _route;
  final Completer<T?> _completer = Completer<T?>();

  OverlayEntry? _entry;
  ExitAnimator? _exitAnimator;
  _Phase _phase = _Phase.open;
  T? _result;

  /// Completes with the latched result once the menu has torn down.
  Future<T?> get result => _completer.future;

  /// The entry this menu was inserted into the Overlay as.
  set entry(OverlayEntry value) => _entry = value;

  /// Registered by the menu widget once it can animate. Without one, an
  /// animated Close degrades to an instant Close — which is what should
  /// happen when the widget is not mounted.
  void attachExitAnimator(ExitAnimator animator) => _exitAnimator = animator;

  void detachExitAnimator() => _exitAnimator = null;

  /// Closes this menu, delivering [result] to whoever awaited it.
  ///
  /// The first call latches [result] and decides whether the exit animation
  /// plays. Later calls cannot change the result; an instant one preempts a
  /// running animation, an animated one is ignored.
  void close(T? result, {required bool animated}) {
    switch (_phase) {
      case _Phase.closed:
        return;
      case _Phase.closing:
        if (!animated) _teardown();
      case _Phase.open:
        _phase = _Phase.closing;
        _result = result;
        _controller?._markClosed();

        final animator = animated ? _exitAnimator : null;
        if (animator == null) {
          _teardown();
        } else {
          animator().whenComplete(_teardown);
        }
    }
  }

  void _teardown() {
    if (_phase == _Phase.closed) return;
    _phase = _Phase.closed;

    OpenMenuRegistry.instance.deregister(this);
    _stopListeningToRoute();
    _exitAnimator = null;
    _entry?.remove();
    _entry = null;
    _controller?._markClosed();
    _controller?._unbind(this);

    if (!_completer.isCompleted) _completer.complete(_result);
  }

  void _onRouteStatus(AnimationStatus status) {
    // The owning route is popping.
    if (status == AnimationStatus.reverse) close(null, animated: false);
  }

  void _onSecondaryRouteStatus(AnimationStatus status) {
    // A route was pushed on top of the owning route.
    if (status == AnimationStatus.forward) close(null, animated: false);
  }

  void _stopListeningToRoute() {
    try {
      _route?.animation?.removeStatusListener(_onRouteStatus);
      _route?.secondaryAnimation?.removeStatusListener(_onSecondaryRouteStatus);
    } catch (_) {
      // The route is already disposed; its listeners went with it.
    }
  }
}
