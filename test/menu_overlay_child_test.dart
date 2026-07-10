import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';

const _items = [OverlayMenuItem<String>(value: 'a', child: Text('Apple'))];

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

/// A strip along the top of the screen, well clear of the centred menu.
Widget _strip({VoidCallback? onTap}) => Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 40,
            color: const Color(0x22000000),
            alignment: Alignment.center,
            child: const Text('Drag me'),
          ),
        ),
        const Expanded(child: IgnorePointer(child: SizedBox.expand())),
      ],
    );

void main() {
  testWidgets('an overlayChild is rendered above the barrier', (tester) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items,
      barrier: OverlayMenuBarrier(overlayChild: _strip()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Drag me'), findsOneWidget);

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('no overlayChild means nothing is drawn over the barrier', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(context: anchor, items: _items);
    await tester.pumpAndSettle();

    expect(find.text('Drag me'), findsNothing);

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('an overlayChild receives its own taps', (tester) async {
    var tapped = false;
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items,
      barrier:
          OverlayMenuBarrier(overlayChild: _strip(onTap: () => tapped = true)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Drag me'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('tapping an overlayChild does not Close the menu',
      (tester) async {
    final anchor = await _pumpHost(tester);
    final future = showOverlayMenu<String>(
      context: anchor,
      items: _items,
      barrier: OverlayMenuBarrier(overlayChild: _strip(onTap: () {})),
    );
    await tester.pumpAndSettle();

    // The overlayChild sits above the dismissible barrier, so it swallows the
    // tap. That is the point of it — a drag handle must not close the menu.
    await tester.tap(find.text('Drag me'));
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsOneWidget);

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
    expect(await future, isNull);
  });

  testWidgets(
      'the barrier still Closes the menu where the overlayChild is '
      'transparent to hits', (tester) async {
    final anchor = await _pumpHost(tester);
    final future = showOverlayMenu<String>(
      context: anchor,
      items: _items,
      barrier: OverlayMenuBarrier(overlayChild: _strip(onTap: () {})),
    );
    await tester.pumpAndSettle();

    // Below the strip the overlayChild ignores pointers, so the barrier gets
    // the tap.
    await tester.tapAt(const Offset(5, 500));
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsNothing);
    expect(await future, isNull);
  });
}
