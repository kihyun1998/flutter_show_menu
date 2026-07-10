import 'dart:async';

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

void main() {
  // Why the exit animator has no `on TickerCanceled` handler.
  //
  // TickerFuture delegates then/whenComplete/catchError to its *primary*
  // completer. Ticker.dispose() and Ticker.stop(canceled: true) both route to
  // TickerFuture._cancel, which completes only the *secondary* completer — the
  // one behind `orCancel`. Awaiting the primary future therefore never yields a
  // TickerCanceled; it simply never resolves.
  //
  // This test pins that SDK behaviour. If a future Flutter completes the
  // primary future on cancellation, it fails, and the exit animator needs to
  // handle it again.
  testWidgets(
      'disposing an AnimationController leaves a pending reverse() '
      'unresolved rather than erroring', (tester) async {
    final controller = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 100),
    );
    controller.value = 1;

    var resolved = false;
    Object? error;
    unawaited(
      controller.reverse().then(
            (_) => resolved = true,
            onError: (Object e) => error = e,
          ),
    );

    await tester.pump(const Duration(milliseconds: 20));
    controller.dispose();
    await tester.pump(const Duration(milliseconds: 200));

    expect(resolved, isFalse, reason: 'the primary future never completes');
    expect(error, isNull, reason: 'TickerCanceled goes to orCancel, not here');
  });

  testWidgets('orCancel is where TickerCanceled is delivered', (tester) async {
    final controller = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 100),
    );
    controller.value = 1;

    Object? error;
    unawaited(
      controller.reverse().orCancel.catchError((Object e) => error = e),
    );

    await tester.pump(const Duration(milliseconds: 20));
    controller.dispose();
    await tester.pump();

    expect(error, isA<TickerCanceled>());
  });

  testWidgets(
      'an instant Close preempting the exit animation raises no '
      'unhandled error', (tester) async {
    final anchor = await _pumpHost(tester);
    final controller = OverlayMenuController();

    final future = showOverlayMenu<String>(
      context: anchor,
      controller: controller,
      items: _items,
    );
    await tester.pumpAndSettle();

    controller.close(); // starts the reverse
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Apple'), findsOneWidget);

    closeAllOverlayMenus(); // tears down mid-animation, disposing the ticker
    await tester.pump();

    expect(find.text('Apple'), findsNothing);
    expect(await future, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'a selection preempted by Close All still delivers its value and '
      'raises no unhandled error', (tester) async {
    final anchor = await _pumpHost(tester);

    final future = showOverlayMenu<String>(context: anchor, items: _items);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apple'));
    await tester.pump(const Duration(milliseconds: 50));
    closeAllOverlayMenus();
    await tester.pump();

    expect(await future, 'a');
    expect(tester.takeException(), isNull);
  });

  test('closing a Controller that never opened a menu is safe', () {
    final controller = OverlayMenuController();
    expect(controller.isClosed, isFalse);

    controller.close();
    expect(controller.isClosed, isTrue);

    controller.close(); // still a no-op
    expect(controller.isClosed, isTrue);
  });
}
