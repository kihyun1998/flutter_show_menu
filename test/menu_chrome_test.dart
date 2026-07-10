import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';

const _items = [OverlayMenuItem<String>(value: 'a', child: Text('Apple'))];

Finder _menuSurface() =>
    find.byWidgetPredicate((w) => w is Material && w.elevation == 8);

Future<BuildContext> _pumpHost(WidgetTester tester) async {
  late BuildContext anchor;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) {
              anchor = context;
              return const SizedBox(width: 20, height: 20);
            },
          ),
        ),
      ),
    ),
  );
  return anchor;
}

void main() {
  // These three moved onto OverlayMenuStyle in 1.0.0, rejoining maxHeight.
  // See docs/adr/0003-group-menu-configuration-by-cohesion.md.

  testWidgets('style.decoration wraps the menu surface', (tester) async {
    const decoration = BoxDecoration(color: Color(0xFF123456));
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items,
      style: const OverlayMenuStyle(decoration: decoration),
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (w) => w is DecoratedBox && w.decoration == decoration,
      ),
      findsOneWidget,
    );

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('no decoration means no decorated box of our own', (
    tester,
  ) async {
    const decoration = BoxDecoration(color: Color(0xFF123456));
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(context: anchor, items: _items);
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (w) => w is DecoratedBox && w.decoration == decoration,
      ),
      findsNothing,
    );

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('style.width fixes the menu width', (tester) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items,
      style: const OverlayMenuStyle(width: 240),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(_menuSurface()).width, 240);

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('without a width the menu sizes to its content', (tester) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(context: anchor, items: _items);
    await tester.pumpAndSettle();

    final intrinsic = tester.getSize(_menuSurface()).width;
    expect(intrinsic, lessThan(240));
    expect(intrinsic, greaterThan(0));

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('style.constraints bound the menu surface', (tester) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items,
      style: const OverlayMenuStyle(
        constraints: BoxConstraints(minWidth: 300),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(_menuSurface()).width, greaterThanOrEqualTo(300));

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('decoration, width, and constraints compose', (tester) async {
    const decoration = BoxDecoration(color: Color(0xFF654321));
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items,
      style: const OverlayMenuStyle(
        decoration: decoration,
        width: 200,
        constraints: BoxConstraints(minHeight: 120),
      ),
    );
    await tester.pumpAndSettle();

    final size = tester.getSize(_menuSurface());
    expect(size.width, 200);
    expect(size.height, greaterThanOrEqualTo(120));
    expect(
      find.byWidgetPredicate(
        (w) => w is DecoratedBox && w.decoration == decoration,
      ),
      findsOneWidget,
    );

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });
}
