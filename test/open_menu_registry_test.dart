import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';
import 'package:flutter_show_menu/src/open_menu_registry.dart';

final _registry = OpenMenuRegistry.instance;

Future<BuildContext> _pumpHost(WidgetTester tester) async {
  late BuildContext hostContext;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            hostContext = context;
            return const SizedBox(width: 100, height: 100);
          },
        ),
      ),
    ),
  );
  return hostContext;
}

Future<String?> _openMenu(BuildContext context, String label) {
  return showOverlayMenu<String>(
    context: context,
    items: [OverlayMenuItem<String>(value: label, child: Text(label))],
  );
}

void main() {
  // ADR-0001 asks that tests leave the registry empty between cases. Reset
  // before asserting, so one leak cannot cascade into every later case.
  tearDown(() {
    final leaked = _registry.length;
    _registry.reset();
    expect(leaked, 0, reason: 'a menu leaked into the open-menu registry');
  });

  testWidgets('a menu joins the registry when shown', (tester) async {
    final context = await _pumpHost(tester);
    expect(_registry.length, 0);

    final future = _openMenu(context, 'Solo');
    await tester.pumpAndSettle();
    expect(_registry.length, 1);

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
    expect(_registry.length, 0);
    expect(await future, isNull);
  });

  testWidgets('every Close path deregisters', (tester) async {
    final context = await _pumpHost(tester);

    // Selection.
    var future = _openMenu(context, 'Pick');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pick'));
    await tester.pumpAndSettle();
    expect(await future, 'Pick');
    expect(_registry.length, 0, reason: 'selection');

    // Barrier tap.
    future = _openMenu(context, 'Barrier');
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(await future, isNull);
    expect(_registry.length, 0, reason: 'barrier tap');

    // Controller.
    final controller = OverlayMenuController();
    future = showOverlayMenu<String>(
      context: context,
      controller: controller,
      items: const [OverlayMenuItem<String>(value: 'c', child: Text('Ctrl'))],
    );
    await tester.pumpAndSettle();
    controller.close();
    await tester.pumpAndSettle();
    expect(await future, isNull);
    expect(_registry.length, 0, reason: 'controller');

    // Close All.
    future = _openMenu(context, 'All');
    await tester.pumpAndSettle();
    closeAllOverlayMenus();
    await tester.pumpAndSettle();
    expect(await future, isNull);
    expect(_registry.length, 0, reason: 'close all');
  });

  testWidgets('the registry holds every simultaneously open menu',
      (tester) async {
    final context = await _pumpHost(tester);

    final futures = [
      _openMenu(context, 'One'),
      _openMenu(context, 'Two'),
      _openMenu(context, 'Three'),
    ];
    await tester.pumpAndSettle();
    expect(_registry.length, 3);

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
    expect(_registry.length, 0);
    expect(await Future.wait(futures), [null, null, null]);
  });

  testWidgets('a menu mid-exit-animation is still registered', (tester) async {
    final context = await _pumpHost(tester);
    final controller = OverlayMenuController();

    final future = showOverlayMenu<String>(
      context: context,
      controller: controller,
      items: const [OverlayMenuItem<String>(value: 'a', child: Text('Exit'))],
    );
    await tester.pumpAndSettle();

    controller.close();
    await tester.pump(const Duration(milliseconds: 50));

    // Closing, not closed: Close All must still be able to reach it.
    expect(_registry.length, 1);

    closeAllOverlayMenus();
    await tester.pump();
    expect(_registry.length, 0);
    expect(await future, isNull);
  });

  testWidgets('closeAll is a no-op on an empty registry', (tester) async {
    await _pumpHost(tester);
    closeAllOverlayMenus();
    await tester.pumpAndSettle();
    expect(_registry.length, 0);
  });

  testWidgets('repeated open/closeAll cycles leave nothing behind',
      (tester) async {
    final context = await _pumpHost(tester);

    for (var i = 0; i < 3; i++) {
      final future = _openMenu(context, 'Cycle$i');
      await tester.pumpAndSettle();
      expect(_registry.length, 1);

      closeAllOverlayMenus();
      await tester.pumpAndSettle();
      expect(_registry.length, 0);
      expect(await future, isNull);
    }
  });

  test('reset forgets menus without closing them', () {
    // Pure registry behaviour, no widgets: reset is a test affordance, not a
    // Close, so it must not deliver results or touch the Overlay.
    expect(_registry.length, 0);
    _registry.reset();
    expect(_registry.length, 0);
  });
}
