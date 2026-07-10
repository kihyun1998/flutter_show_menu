import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';

Future<void> _pump(WidgetTester tester, Widget button) {
  return tester.pumpWidget(
    MaterialApp(home: Scaffold(body: Center(child: button))),
  );
}

void main() {
  testWidgets('opens on tap and reports the selection', (tester) async {
    String? selected;
    await _pump(
      tester,
      OverlayMenuButton<String>(
        items: const [
          OverlayMenuItem<String>(value: 'a', child: Text('Apple')),
        ],
        onSelected: (value) => selected = value,
        child: const Text('open'),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();
    expect(selected, 'a');
  });

  testWidgets('reports a cancel when the barrier is tapped', (tester) async {
    var canceled = false;
    await _pump(
      tester,
      OverlayMenuButton<String>(
        items: const [
          OverlayMenuItem<String>(value: 'a', child: Text('Apple')),
        ],
        onCanceled: () => canceled = true,
        child: const Text('open'),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(canceled, isTrue);
  });

  testWidgets('a disabled button does not open', (tester) async {
    await _pump(
      tester,
      const OverlayMenuButton<String>(
        enabled: false,
        items: [OverlayMenuItem<String>(value: 'a', child: Text('Apple'))],
        child: Text('open'),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Apple'), findsNothing);
  });

  // The button used to redeclare showOverlayMenu's parameters by hand, and had
  // silently dropped these two. Sharing the configuration makes that
  // impossible; these pin the behaviour rather than the mere existence.
  group('parity with showOverlayMenu', () {
    testWidgets('accepts a Controller and Closes through it', (tester) async {
      final controller = OverlayMenuController();
      var canceled = false;

      await _pump(
        tester,
        OverlayMenuButton<String>(
          controller: controller,
          items: const [
            OverlayMenuItem<String>(value: 'a', child: Text('Apple')),
          ],
          onCanceled: () => canceled = true,
          child: const Text('open'),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Apple'), findsOneWidget);

      controller.close();
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsNothing);
      expect(controller.isClosed, isTrue);
      expect(canceled, isTrue);
    });

    testWidgets('accepts an initialValue and marks it selected',
        (tester) async {
      await _pump(
        tester,
        OverlayMenuButton<String>(
          initialValue: 'b',
          style: const OverlayMenuStyle(
            itemStyle: OverlayMenuItemStyle(
              selectedBackgroundColor: Color(0xFF00FF00),
            ),
          ),
          items: const [
            OverlayMenuItem<String>(value: 'a', child: Text('Apple')),
            OverlayMenuItem<String>(value: 'b', child: Text('Banana')),
          ],
          child: const Text('open'),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final inks = tester.widgetList<Ink>(find.byType(Ink)).toList();
      final colors =
          inks.map((ink) => (ink.decoration as BoxDecoration?)?.color).toList();

      expect(colors, [null, const Color(0xFF00FF00)]);
    });

    testWidgets('barrier.dismissible: false keeps the menu open',
        (tester) async {
      await _pump(
        tester,
        const OverlayMenuButton<String>(
          barrier: OverlayMenuBarrier(dismissible: false),
          items: [OverlayMenuItem<String>(value: 'a', child: Text('Apple'))],
          child: Text('open'),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.text('Apple'), findsOneWidget);
      closeAllOverlayMenus();
      await tester.pumpAndSettle();
    });
  });
}
