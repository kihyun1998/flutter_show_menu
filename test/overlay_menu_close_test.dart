import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';
import 'package:flutter_show_menu/src/open_menu_registry.dart';

const _animation = Duration(milliseconds: 150);

class _Host {
  _Host(this.context, this.navigator);
  final BuildContext context;
  final GlobalKey<NavigatorState> navigator;
}

Future<_Host> _pumpHost(WidgetTester tester) async {
  final navigator = GlobalKey<NavigatorState>();
  late BuildContext hostContext;
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigator,
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
  return _Host(hostContext, navigator);
}

void main() {
  // ADR-0001: no case may leave a menu in the registry. Reset before asserting
  // so a single leak cannot cascade into every case that follows.
  tearDown(() {
    final leaked = OpenMenuRegistry.instance.length;
    OpenMenuRegistry.instance.reset();
    expect(leaked, 0, reason: 'a menu leaked into the open-menu registry');
  });

  group('the result is latched when Close is requested', () {
    testWidgets('an item whose onTap pushes a route still returns its value',
        (tester) async {
      final host = await _pumpHost(tester);

      final future = showOverlayMenu<String>(
        context: host.context,
        items: [
          OverlayMenuItem<String>(
            value: 'save',
            onTap: () => host.navigator.currentState!.push(
              MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: Text('next page')),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // The push fires a route Auto-close mid-dismiss. The selection was
      // already made, so it must survive.
      expect(await future, 'save');
    });

    testWidgets('Close All during the exit animation preserves the selection',
        (tester) async {
      final host = await _pumpHost(tester);

      final future = showOverlayMenu<String>(
        context: host.context,
        items: [
          const OverlayMenuItem<String>(value: 'pick', child: Text('Pick')),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pick'));
      await tester.pump(const Duration(milliseconds: 50)); // mid reverse
      closeAllOverlayMenus();
      await tester.pumpAndSettle();

      expect(await future, 'pick');
    });
  });

  group('animated Close', () {
    testWidgets('Controller.close() plays the exit animation', (tester) async {
      final host = await _pumpHost(tester);
      final controller = OverlayMenuController();

      final future = showOverlayMenu<String>(
        context: host.context,
        controller: controller,
        items: [
          const OverlayMenuItem<String>(value: 'ctrl', child: Text('Ctrl')),
        ],
      );
      await tester.pumpAndSettle();

      controller.close();
      expect(controller.isClosed, isTrue, reason: 'closed state is immediate');

      await tester.pump(const Duration(milliseconds: 50));
      expect(
        find.text('Ctrl'),
        findsOneWidget,
        reason: 'still on screen part-way through the exit animation',
      );

      await tester.pumpAndSettle();
      expect(find.text('Ctrl'), findsNothing);
      expect(await future, isNull);
    });

    testWidgets('selecting an item plays the exit animation', (tester) async {
      final host = await _pumpHost(tester);

      final future = showOverlayMenu<String>(
        context: host.context,
        items: [
          const OverlayMenuItem<String>(value: 'pick', child: Text('Pick')),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pick'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Pick'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(await future, 'pick');
    });
  });

  group('instant Close', () {
    testWidgets('Close All removes the menu within a single frame',
        (tester) async {
      final host = await _pumpHost(tester);

      final future = showOverlayMenu<String>(
        context: host.context,
        items: [
          const OverlayMenuItem<String>(value: 'a', child: Text('Solo')),
        ],
      );
      await tester.pumpAndSettle();

      closeAllOverlayMenus();
      await tester.pump();

      expect(
        find.text('Solo'),
        findsNothing,
        reason: 'ADR-0001: Close All closes immediately, no reverse animation',
      );
      expect(await future, isNull);
    });

    testWidgets('Close All preempts an in-flight exit animation',
        (tester) async {
      final host = await _pumpHost(tester);
      final controller = OverlayMenuController();

      final future = showOverlayMenu<String>(
        context: host.context,
        controller: controller,
        items: [
          const OverlayMenuItem<String>(value: 'a', child: Text('Preempt')),
        ],
      );
      await tester.pumpAndSettle();

      controller.close(); // starts the ~150ms reverse
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Preempt'), findsOneWidget);

      closeAllOverlayMenus();
      await tester.pump();
      expect(find.text('Preempt'), findsNothing);
      expect(await future, isNull);
    });

    testWidgets('a route pop closes the menu immediately', (tester) async {
      final host = await _pumpHost(tester);
      host.navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showOverlayMenu<String>(
                  context: context,
                  items: [
                    const OverlayMenuItem<String>(
                      value: 'a',
                      child: Text('OnRoute'),
                    ),
                  ],
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('OnRoute'), findsOneWidget);

      host.navigator.currentState!.pop();
      await tester.pump();
      expect(find.text('OnRoute'), findsNothing);
      await tester.pumpAndSettle();
    });
  });

  group('idempotency', () {
    testWidgets('a second Close cannot overwrite the first result',
        (tester) async {
      final host = await _pumpHost(tester);
      final controller = OverlayMenuController();

      final future = showOverlayMenu<String>(
        context: host.context,
        controller: controller,
        items: [
          const OverlayMenuItem<String>(value: 'pick', child: Text('Pick')),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pick'));
      controller.close();
      closeAllOverlayMenus();
      await tester.pumpAndSettle();

      expect(await future, 'pick');
      expect(controller.isClosed, isTrue);
    });

    testWidgets('Controller.close() twice is a no-op the second time',
        (tester) async {
      final host = await _pumpHost(tester);
      final controller = OverlayMenuController();

      final future = showOverlayMenu<String>(
        context: host.context,
        controller: controller,
        items: [
          const OverlayMenuItem<String>(value: 'a', child: Text('Twice')),
        ],
      );
      await tester.pumpAndSettle();

      controller.close();
      controller.close();
      await tester.pumpAndSettle();

      expect(await future, isNull);
      expect(controller.isClosed, isTrue);
    });

    testWidgets('a barrier tap after selection does not change the result',
        (tester) async {
      final host = await _pumpHost(tester);

      final future = showOverlayMenu<String>(
        context: host.context,
        items: [
          const OverlayMenuItem<String>(value: 'pick', child: Text('Pick')),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pick'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tapAt(const Offset(5, 5)); // barrier, mid-dismiss
      await tester.pumpAndSettle();

      expect(await future, 'pick');
    });
  });

  group('Controller binding', () {
    testWidgets('a Controller reused for a second menu closes only that menu',
        (tester) async {
      final host = await _pumpHost(tester);
      final controller = OverlayMenuController();

      final first = showOverlayMenu<String>(
        context: host.context,
        controller: controller,
        items: [const OverlayMenuItem<String>(value: 'a', child: Text('One'))],
      );
      await tester.pumpAndSettle();
      controller.close();
      await tester.pumpAndSettle();
      expect(await first, isNull);

      final second = showOverlayMenu<String>(
        context: host.context,
        controller: controller,
        items: [const OverlayMenuItem<String>(value: 'b', child: Text('Two'))],
      );
      await tester.pumpAndSettle();
      expect(controller.isClosed, isFalse, reason: 'rebound to a live menu');

      controller.close();
      await tester.pumpAndSettle();
      expect(find.text('Two'), findsNothing);
      expect(await second, isNull);
    });
  });

  group('cleanup', () {
    testWidgets(
        'the exit animation still runs when the menu outlives a rebuild',
        (tester) async {
      final host = await _pumpHost(tester);

      final future = showOverlayMenu<String>(
        context: host.context,
        items: [
          const OverlayMenuItem<String>(value: 'a', child: Text('Rebuild')),
        ],
        motion: const OverlayMenuMotion(duration: _animation),
      );
      await tester.pumpAndSettle();

      await tester.pump();
      expect(find.text('Rebuild'), findsOneWidget);

      closeAllOverlayMenus();
      await tester.pumpAndSettle();
      expect(await future, isNull);
    });
  });
}
