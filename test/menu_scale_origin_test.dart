import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';

const _items = [OverlayMenuItem<String>(value: 'a', child: Text('Apple'))];

Finder _menuSurface() =>
    find.byWidgetPredicate((w) => w is Material && w.elevation == 8);

Future<BuildContext> _pumpHost(WidgetTester tester, Alignment where) async {
  late BuildContext anchor;
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: where,
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

/// Opens the menu and samples its surface part-way through the open animation
/// and again once it has settled.
///
/// The menu scales from 0.9 to 1, so the point it grows from is the one that
/// holds still between the two samples. Asserting on that, rather than on the
/// alignment of whatever widget applies the transform, keeps these tests
/// independent of how the scale is implemented.
Future<(Rect early, Rect settled)> _openAndSample(
  WidgetTester tester,
  BuildContext anchor, {
  required MenuPosition position,
  MenuAlignment alignment = MenuAlignment.start,
}) async {
  showOverlayMenu<String>(
    context: anchor,
    items: _items,
    placement: OverlayMenuPlacement(position: position, alignment: alignment),
  );
  await tester.pump();
  final early = tester.getRect(_menuSurface());
  await tester.pumpAndSettle();
  final settled = tester.getRect(_menuSurface());
  return (early, settled);
}

Matcher _sameOffset(Offset expected) => isA<Offset>()
    .having((o) => o.dx, 'dx', moreOrLessEquals(expected.dx, epsilon: 0.01))
    .having((o) => o.dy, 'dy', moreOrLessEquals(expected.dy, epsilon: 0.01));

/// The menu really did scale, so a test that finds a fixed point has found
/// something. Without this a broken sample would pass everything.
void _expectItGrew(Rect early, Rect settled) {
  expect(early.size.width, lessThan(settled.size.width));
  expect(early.size.height, lessThan(settled.size.height));
}

void main() {
  group('the menu grows from the corner nearest its target', () {
    const expected = <(MenuPosition, MenuAlignment), Alignment>{
      (MenuPosition.bottom, MenuAlignment.start): Alignment.topLeft,
      (MenuPosition.bottom, MenuAlignment.center): Alignment.topCenter,
      (MenuPosition.bottom, MenuAlignment.end): Alignment.topRight,
      (MenuPosition.top, MenuAlignment.start): Alignment.bottomLeft,
      (MenuPosition.top, MenuAlignment.center): Alignment.bottomCenter,
      (MenuPosition.top, MenuAlignment.end): Alignment.bottomRight,
      (MenuPosition.left, MenuAlignment.start): Alignment.topRight,
      (MenuPosition.left, MenuAlignment.center): Alignment.centerRight,
      (MenuPosition.left, MenuAlignment.end): Alignment.bottomRight,
      (MenuPosition.right, MenuAlignment.start): Alignment.topLeft,
      (MenuPosition.right, MenuAlignment.center): Alignment.centerLeft,
      (MenuPosition.right, MenuAlignment.end): Alignment.bottomLeft,
    };

    for (final entry in expected.entries) {
      final (position, alignment) = entry.key;
      final origin = entry.value;

      testWidgets('${position.name} + ${alignment.name} holds $origin still', (
        tester,
      ) async {
        // Anchored centrally, so nothing flips.
        final anchor = await _pumpHost(tester, Alignment.center);
        final (early, settled) = await _openAndSample(
          tester,
          anchor,
          position: position,
          alignment: alignment,
        );

        _expectItGrew(early, settled);
        expect(
          origin.withinRect(early),
          _sameOffset(origin.withinRect(settled)),
        );

        closeAllOverlayMenus();
        await tester.pumpAndSettle();
      });
    }

    testWidgets('every position and alignment pair is covered', (tester) async {
      expect(
        expected.length,
        MenuPosition.values.length * MenuAlignment.values.length,
      );
    });
  });

  group('a flipped menu grows from the corner it actually landed nearest', () {
    // The delegate flips a menu to the opposite side of its target when it
    // would overrun the screen. The origin must follow, or the menu appears to
    // grow into the widget it is anchored to rather than out of it.
    const cases = <(Alignment anchorAt, MenuPosition asked, Alignment origin)>[
      (Alignment.bottomCenter, MenuPosition.bottom, Alignment.bottomLeft),
      (Alignment.topCenter, MenuPosition.top, Alignment.topLeft),
      (Alignment.centerRight, MenuPosition.right, Alignment.topRight),
      (Alignment.centerLeft, MenuPosition.left, Alignment.topLeft),
    ];

    for (final (anchorAt, asked, origin) in cases) {
      testWidgets('${asked.name} with no room flips and holds $origin still', (
        tester,
      ) async {
        final anchor = await _pumpHost(tester, anchorAt);
        final (early, settled) = await _openAndSample(
          tester,
          anchor,
          position: asked,
        );

        _expectItGrew(early, settled);
        expect(
          origin.withinRect(early),
          _sameOffset(origin.withinRect(settled)),
        );

        closeAllOverlayMenus();
        await tester.pumpAndSettle();
      });
    }

    testWidgets('a flipped bottom menu really is above its target', (
      tester,
    ) async {
      final anchor = await _pumpHost(tester, Alignment.bottomCenter);
      final (_, settled) = await _openAndSample(
        tester,
        anchor,
        position: MenuPosition.bottom,
      );

      final target = tester.getRect(find.byType(SizedBox).last);
      expect(settled.bottom, lessThanOrEqualTo(target.top + 0.01));

      closeAllOverlayMenus();
      await tester.pumpAndSettle();
    });
  });

  testWidgets('an entry is still tappable while the menu is scaling', (
    tester,
  ) async {
    // The transform must be applied to hit tests too, not only to painting.
    final anchor = await _pumpHost(tester, Alignment.center);
    final future = showOverlayMenu<String>(context: anchor, items: _items);
    await tester.pump(const Duration(milliseconds: 75)); // mid-scale

    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();

    expect(await future, 'a');
  });
}
