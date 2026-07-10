import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';

const _itemHeight = 48.0;
const _verticalPadding = 8.0; // the default 4 top + 4 bottom

List<OverlayMenuEntry<String>> _items(int count) => [
      for (var i = 0; i < count; i++)
        OverlayMenuItem<String>(value: 'v$i', child: Text('Item $i')),
    ];

Future<BuildContext> _pumpHost(WidgetTester tester) async {
  late BuildContext anchor;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(
            builder: (context) {
              anchor = context;
              return const SizedBox(width: 10, height: 10);
            },
          ),
        ),
      ),
    ),
  );
  return anchor;
}

/// The menu surface itself, distinguished from the Material each entry wraps
/// itself in by its elevation.
Finder _menuSurface() =>
    find.byWidgetPredicate((w) => w is Material && w.elevation == 8);

void main() {
  testWidgets('maxHeight makes the Open Menu scroll rather than grow', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(10), // 480px of entries
      style: const OverlayMenuStyle(maxHeight: 200),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.getSize(_menuSurface()).height, 200);

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('a menu shorter than maxHeight is sized by its entries', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(2),
      style: const OverlayMenuStyle(maxHeight: 500),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getSize(_menuSurface()).height,
      2 * _itemHeight + _verticalPadding,
    );

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('without maxHeight the menu grows and never scrolls', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(context: anchor, items: _items(10));
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(find.byType(Scrollbar), findsNothing);
    expect(
      tester.getSize(_menuSurface()).height,
      10 * _itemHeight + _verticalPadding,
    );

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('every entry is laid out even when the menu scrolls', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(10),
      style: const OverlayMenuStyle(maxHeight: 200),
    );
    await tester.pumpAndSettle();

    // A SingleChildScrollView builds its whole child, so entries below the fold
    // exist in the tree. Only the visible ones are hit-testable.
    expect(find.text('Item 9', skipOffstage: false), findsOneWidget);

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('scrolling reveals entries below the fold', (tester) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(10),
      style: const OverlayMenuStyle(maxHeight: 200),
    );
    await tester.pumpAndSettle();

    final viewport = tester.getRect(find.byType(SingleChildScrollView));
    expect(tester.getRect(find.text('Item 9')).center.dy,
        isNot(inViewport(viewport)));

    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(tester.getRect(find.text('Item 9')).center.dy, inViewport(viewport));

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });
}

Matcher inViewport(Rect viewport) =>
    inInclusiveRange(viewport.top, viewport.bottom);
