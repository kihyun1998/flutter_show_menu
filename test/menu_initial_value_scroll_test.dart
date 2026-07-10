import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';

const _itemHeight = 48.0;

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

/// The rect of the scrollable viewport, which is smaller than `maxHeight`:
/// padding and any header or footer sit outside it.
Rect _viewport(WidgetTester tester) =>
    tester.getRect(find.byType(SingleChildScrollView));

void main() {
  testWidgets('initialValue centres its item in the scroll viewport', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(10),
      initialValue: 'v5',
      style: const OverlayMenuStyle(maxHeight: 200),
    );
    await tester.pumpAndSettle();

    // The viewport is 192 tall (200 less 4+4 of default padding), not 200.
    expect(_viewport(tester).height, 200 - 8);
    expect(
      tester.getRect(find.text('Item 5')).center.dy,
      _viewport(tester).center.dy,
      reason: 'the selected entry must sit at the centre of what is visible',
    );

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('a header and footer shrink the viewport the entry centres in', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(10),
      header: [_entry('Header')],
      footer: [_entry('Footer')],
      initialValue: 'v5',
      style: const OverlayMenuStyle(maxHeight: 300),
    );
    await tester.pumpAndSettle();

    // 300 less 8 of padding and two 48px pinned entries.
    expect(_viewport(tester).height, 300 - 8 - 2 * _itemHeight);
    expect(
      tester.getRect(find.text('Item 5')).center.dy,
      _viewport(tester).center.dy,
      reason: 'pinned entries are outside the viewport and must not skew it',
    );

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('initialValue on the first entry does not scroll past the top', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(10),
      initialValue: 'v0',
      style: const OverlayMenuStyle(maxHeight: 200),
    );
    await tester.pumpAndSettle();

    // Centring would ask for a negative offset; the clamp holds it at zero, so
    // the first entry sits flush with the top of the viewport. Compare centres:
    // find.text returns the Text, which is centred inside its 48px entry.
    expect(
      tester.getRect(find.text('Item 0')).center.dy,
      _viewport(tester).top + _itemHeight / 2,
    );

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('initialValue on the last entry does not scroll past the bottom',
      (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(10),
      initialValue: 'v9',
      style: const OverlayMenuStyle(maxHeight: 200),
    );
    await tester.pumpAndSettle();

    // Centring would ask for an offset beyond maxScrollExtent; the clamp holds
    // it there, so the last entry sits flush with the bottom.
    expect(
      tester.getRect(find.text('Item 9')).center.dy,
      _viewport(tester).bottom - _itemHeight / 2,
    );

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('an initialValue no entry carries leaves the menu unscrolled', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(10),
      initialValue: 'nothing-matches',
      style: const OverlayMenuStyle(maxHeight: 200),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.text('Item 0')).center.dy,
      _viewport(tester).top + _itemHeight / 2,
    );

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('dividers count toward the offset of the entry below them', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: [
        _entry('A'),
        const OverlayMenuDivider<String>(height: 20),
        for (var i = 0; i < 8; i++) _entry('B$i'),
      ],
      initialValue: 'B4',
      style: const OverlayMenuStyle(maxHeight: 200),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getRect(find.text('B4')).center.dy,
      _viewport(tester).center.dy,
    );

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });
}
