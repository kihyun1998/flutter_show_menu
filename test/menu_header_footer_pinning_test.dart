import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';

List<OverlayMenuEntry<String>> _items(int count) => [
      for (var i = 0; i < count; i++)
        OverlayMenuItem<String>(value: 'v$i', child: Text('Item $i')),
    ];

OverlayMenuItem<String> _entry(String label) =>
    OverlayMenuItem<String>(value: label, child: Text(label));

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

void main() {
  testWidgets(
      'a scrolling menu keeps its header and footer outside the '
      'viewport', (tester) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(10),
      header: [_entry('Header')],
      footer: [_entry('Footer')],
      style: const OverlayMenuStyle(maxHeight: 300),
    );
    await tester.pumpAndSettle();

    final viewport = tester.getRect(find.byType(SingleChildScrollView));
    expect(tester.getRect(find.text('Header')).bottom,
        lessThanOrEqualTo(viewport.top));
    expect(tester.getRect(find.text('Footer')).top,
        greaterThanOrEqualTo(viewport.bottom));

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('pinned entries do not move when the entries scroll', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(10),
      header: [_entry('Header')],
      footer: [_entry('Footer')],
      style: const OverlayMenuStyle(maxHeight: 300),
    );
    await tester.pumpAndSettle();

    final headerBefore = tester.getRect(find.text('Header'));
    final footerBefore = tester.getRect(find.text('Footer'));
    final firstItemBefore = tester.getRect(find.text('Item 0'));

    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(tester.getRect(find.text('Header')), headerBefore);
    expect(tester.getRect(find.text('Footer')), footerBefore);
    expect(
      tester.getRect(find.text('Item 0')),
      isNot(firstItemBefore),
      reason: 'the entries themselves must have moved',
    );

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets(
      'without maxHeight the header and footer simply bracket the '
      'entries', (tester) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(3),
      header: [_entry('Header')],
      footer: [_entry('Footer')],
    );
    await tester.pumpAndSettle();

    expect(find.byType(SingleChildScrollView), findsNothing);
    expect(
      tester.getRect(find.text('Header')).bottom,
      lessThanOrEqualTo(tester.getRect(find.text('Item 0')).top),
    );
    expect(
      tester.getRect(find.text('Footer')).top,
      greaterThanOrEqualTo(tester.getRect(find.text('Item 2')).bottom),
    );

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('an empty menu drops the dividers from its header and footer', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: const [],
      header: [_entry('Header'), const OverlayMenuDivider<String>()],
      footer: [const OverlayMenuDivider<String>(), _entry('Footer')],
    );
    await tester.pumpAndSettle();

    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Footer'), findsOneWidget);
    expect(
      find.byType(Divider),
      findsNothing,
      reason: 'separators with nothing to separate must not be drawn',
    );

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('a non-empty menu keeps the dividers in its header and footer', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(2),
      header: [_entry('Header'), const OverlayMenuDivider<String>()],
      footer: [const OverlayMenuDivider<String>(), _entry('Footer')],
    );
    await tester.pumpAndSettle();

    expect(find.byType(Divider), findsNWidgets(2));

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });
}
