import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';

const _items = [OverlayMenuItem<String>(value: 'a', child: Text('Apple'))];

/// The menu surface, told apart from the Material each entry wraps itself in.
Finder _menuSurface() =>
    find.byWidgetPredicate((w) => w is Material && w.elevation == 8);

/// The menu's own ScaleTransition. MaterialApp's default page transition builds
/// one of its own, so match by ancestry rather than by type alone.
AlignmentGeometry _scaleOrigin(WidgetTester tester) {
  final transition = tester.widget<ScaleTransition>(
    find.ancestor(of: _menuSurface(), matching: find.byType(ScaleTransition)),
  );
  return transition.alignment;
}

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
  // The menu scales open from the corner nearest its target, so the animation
  // reads as the menu emerging from the widget it belongs to. A wrong corner is
  // a visual regression nothing else would catch.
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
    testWidgets(
        '${position.name} + ${alignment.name} scales from '
        '${entry.value}', (tester) async {
      final anchor = await _pumpHost(tester);
      showOverlayMenu<String>(
        context: anchor,
        items: _items,
        placement: OverlayMenuPlacement(
          position: position,
          alignment: alignment,
        ),
      );
      await tester.pump();

      expect(_scaleOrigin(tester), entry.value);

      closeAllOverlayMenus();
      await tester.pumpAndSettle();
    });
  }

  testWidgets('every position and alignment pair is covered', (tester) async {
    // Guards the table above against a new enum value slipping through: the
    // switch in _resolveScaleAlignment is exhaustive, so this must be too.
    expect(
      expected.length,
      MenuPosition.values.length * MenuAlignment.values.length,
    );
  });
}
