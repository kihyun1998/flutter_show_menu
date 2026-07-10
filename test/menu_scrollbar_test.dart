import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';

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

ScrollbarThemeData _scrollbarTheme(WidgetTester tester) =>
    tester.widget<ScrollbarTheme>(find.byType(ScrollbarTheme)).data;

/// Scrollbar theme fields are WidgetStateProperty; resolve them for a resting
/// scrollbar so the assertions read as plain values.
T? _resolve<T>(WidgetStateProperty<T?>? property) =>
    property?.resolve(<WidgetState>{});

void main() {
  testWidgets('a scrollbarStyle themes the scrollbar', (tester) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(10),
      style: const OverlayMenuStyle(
        maxHeight: 200,
        scrollbarStyle: OverlayMenuScrollbarStyle(
          thumbColor: Color(0xFF00FF00),
          thickness: 6,
          radius: Radius.circular(3),
          thumbVisibility: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final theme = _scrollbarTheme(tester);
    expect(_resolve(theme.thumbColor), const Color(0xFF00FF00));
    expect(_resolve(theme.thickness), 6);
    expect(theme.radius, const Radius.circular(3));
    expect(_resolve(theme.thumbVisibility), isTrue);

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('a partial scrollbarStyle leaves the rest to the theme', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(10),
      style: const OverlayMenuStyle(
        maxHeight: 200,
        scrollbarStyle: OverlayMenuScrollbarStyle(thickness: 6),
      ),
    );
    await tester.pumpAndSettle();

    final theme = _scrollbarTheme(tester);
    expect(_resolve(theme.thickness), 6);
    expect(theme.thumbColor, isNull, reason: 'unset fields must stay unset');
    expect(theme.radius, isNull);
    expect(theme.thumbVisibility, isNull);

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('omitting scrollbarStyle still gives a scrollbar',
      (tester) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(10),
      style: const OverlayMenuStyle(maxHeight: 200),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scrollbar), findsOneWidget);
    expect(
      find.byType(ScrollbarTheme),
      findsNothing,
      reason: 'no override, so the ambient theme applies untouched',
    );

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('a scrollbarStyle without maxHeight has nothing to theme', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(10),
      style: const OverlayMenuStyle(
        scrollbarStyle: OverlayMenuScrollbarStyle(thickness: 6),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Scrollbar), findsNothing);
    expect(find.byType(ScrollbarTheme), findsNothing);

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });
}
