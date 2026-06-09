import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';

void main() {
  test('MenuPosition has all expected values', () {
    expect(MenuPosition.values.length, 4);
    expect(MenuPosition.values, contains(MenuPosition.top));
    expect(MenuPosition.values, contains(MenuPosition.bottom));
    expect(MenuPosition.values, contains(MenuPosition.left));
    expect(MenuPosition.values, contains(MenuPosition.right));
  });

  test('MenuAlignment has all expected values', () {
    expect(MenuAlignment.values.length, 3);
    expect(MenuAlignment.values, contains(MenuAlignment.start));
    expect(MenuAlignment.values, contains(MenuAlignment.center));
    expect(MenuAlignment.values, contains(MenuAlignment.end));
  });

  test('OverlayMenuItem stores properties correctly', () {
    final item = OverlayMenuItem<String>(
      value: 'test',
      child: const Text('Test'),
      enabled: false,
    );

    expect(item.value, 'test');
    expect(item.enabled, false);
    expect(item.height, isNull);
  });

  group('closeAllOverlayMenus', () {
    // Pumps a MaterialApp and hands back a BuildContext that has a RenderBox
    // and a surrounding Overlay/ModalRoute — everything showOverlayMenu needs.
    Future<BuildContext> pumpHost(WidgetTester tester) async {
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

    Future<String?> openMenu(
      WidgetTester tester,
      BuildContext context,
      String label, {
      OverlayMenuController? controller,
    }) {
      final future = showOverlayMenu<String>(
        context: context,
        controller: controller,
        items: [
          OverlayMenuItem<String>(value: label, child: Text(label)),
        ],
      );
      return future;
    }

    testWidgets('is a no-op when no menus are open', (tester) async {
      await pumpHost(tester);
      // Must not throw with an empty registry.
      closeAllOverlayMenus();
      await tester.pumpAndSettle();
    });

    testWidgets('closes a single open menu with a null result',
        (tester) async {
      final context = await pumpHost(tester);
      final future = openMenu(tester, context, 'Solo');
      await tester.pumpAndSettle();
      expect(find.text('Solo'), findsOneWidget);

      closeAllOverlayMenus();
      await tester.pumpAndSettle();

      expect(find.text('Solo'), findsNothing);
      expect(await future, isNull);
    });

    testWidgets('closes N simultaneously open menus at once', (tester) async {
      final context = await pumpHost(tester);
      final f1 = openMenu(tester, context, 'One');
      final f2 = openMenu(tester, context, 'Two');
      final f3 = openMenu(tester, context, 'Three');
      await tester.pumpAndSettle();
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      expect(find.text('Three'), findsOneWidget);

      closeAllOverlayMenus();
      await tester.pumpAndSettle();

      expect(find.text('One'), findsNothing);
      expect(find.text('Two'), findsNothing);
      expect(find.text('Three'), findsNothing);
      expect(await Future.wait([f1, f2, f3]), [null, null, null]);
    });

    testWidgets('selecting an item deregisters it — no leak for closeAll',
        (tester) async {
      final context = await pumpHost(tester);
      final future = openMenu(tester, context, 'Pick');
      await tester.pumpAndSettle();

      // Close via the selection path, not closeAll.
      await tester.tap(find.text('Pick'));
      await tester.pumpAndSettle();
      expect(await future, 'Pick');

      // The menu already left the registry, so closeAll has nothing to do.
      closeAllOverlayMenus();
      await tester.pumpAndSettle();
      expect(find.text('Pick'), findsNothing);
    });

    testWidgets('controller.close() deregisters it — no leak for closeAll',
        (tester) async {
      final context = await pumpHost(tester);
      final controller = OverlayMenuController();
      final future = openMenu(tester, context, 'Ctrl', controller: controller);
      await tester.pumpAndSettle();

      controller.close();
      await tester.pumpAndSettle();
      expect(controller.isClosed, isTrue);
      expect(await future, isNull);

      // Registry is empty again; closeAll is a safe no-op.
      closeAllOverlayMenus();
      await tester.pumpAndSettle();
      expect(find.text('Ctrl'), findsNothing);
    });

    testWidgets('registry empties after closeAll — repeated cycles stay clean',
        (tester) async {
      final context = await pumpHost(tester);

      for (var i = 0; i < 3; i++) {
        final future = openMenu(tester, context, 'Cycle$i');
        await tester.pumpAndSettle();
        expect(find.text('Cycle$i'), findsOneWidget);

        closeAllOverlayMenus();
        await tester.pumpAndSettle();
        expect(find.text('Cycle$i'), findsNothing);
        expect(await future, isNull);
      }
    });
  });
}
