import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';
import 'package:flutter_smooth_wheel_scroll/flutter_smooth_wheel_scroll.dart'
    show SmoothScrollController;

const _wheelDelta = 60.0;

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

ScrollController _bodyController(WidgetTester tester) => tester
    .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
    .controller!;

/// Sends one mouse wheel notch over the menu body and returns the scroll
/// offset after the first frame, one 16ms frame later, and once settled.
Future<({double firstFrame, double nextFrame, double settled})> _wheelOnce(
  WidgetTester tester,
) async {
  final controller = _bodyController(tester);
  expect(controller.offset, 0, reason: 'the menu must start at the top');
  expect(
    controller.position.maxScrollExtent,
    greaterThan(_wheelDelta),
    reason: 'the menu must be able to scroll the whole notch',
  );

  final pointer = TestPointer(1, PointerDeviceKind.mouse);
  final center = tester.getCenter(find.byType(SingleChildScrollView));
  await tester.sendEventToBinding(pointer.hover(center));
  await tester.sendEventToBinding(pointer.scroll(const Offset(0, _wheelDelta)));
  await tester.pump();
  final firstFrame = controller.offset;
  await tester.pump(const Duration(milliseconds: 16));
  final nextFrame = controller.offset;
  await tester.pumpAndSettle();
  return (
    firstFrame: firstFrame,
    nextFrame: nextFrame,
    settled: controller.offset,
  );
}

/// The notch is spread over frames: short of the full delta at first,
/// moving one frame later, and complete once settled.
void _expectAnimated(
  ({double firstFrame, double nextFrame, double settled}) r,
) {
  expect(r.firstFrame, lessThan(_wheelDelta));
  expect(r.nextFrame, greaterThan(r.firstFrame));
  expect(r.nextFrame, lessThan(_wheelDelta));
  expect(r.settled, _wheelDelta);
}

Future<void> _closeAll(WidgetTester tester) async {
  closeAllOverlayMenus();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a scrolling menu animates a wheel notch by default', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(30),
      style: const OverlayMenuStyle(maxHeight: 245),
    );
    await tester.pumpAndSettle();

    final result = await _wheelOnce(tester);

    _expectAnimated(result);

    await _closeAll(tester);
  });

  testWidgets('a menu shown without a style animates a wheel notch too', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    // 30 items overflow the 600px test screen, so the menu scrolls.
    showOverlayMenu<String>(context: anchor, items: _items(30));
    await tester.pumpAndSettle();

    final result = await _wheelOnce(tester);

    _expectAnimated(result);

    await _closeAll(tester);
  });

  testWidgets('a zero-duration wheelMotion applies the notch in one frame', (
    tester,
  ) async {
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(30),
      style: const OverlayMenuStyle(
        maxHeight: 245,
        wheelMotion: WheelMotion.spring(duration: Duration.zero),
      ),
    );
    await tester.pumpAndSettle();

    final result = await _wheelOnce(tester);

    expect(result.firstFrame, _wheelDelta);
    expect(result.nextFrame, _wheelDelta);
    expect(result.settled, _wheelDelta);

    await _closeAll(tester);
  });

  testWidgets('the menu body uses the wheelMotion the style gives', (
    tester,
  ) async {
    const motion = WheelMotion.curve(duration: Duration(milliseconds: 120));
    final anchor = await _pumpHost(tester);
    showOverlayMenu<String>(
      context: anchor,
      items: _items(30),
      style: const OverlayMenuStyle(maxHeight: 245, wheelMotion: motion),
    );
    await tester.pumpAndSettle();

    final controller = _bodyController(tester);
    expect(controller, isA<SmoothScrollController>());
    expect((controller as SmoothScrollController).motion, motion);

    await _closeAll(tester);
  });

  testWidgets('OverlayMenuButton passes its style wheelMotion to the menu', (
    tester,
  ) async {
    const motion = WheelMotion.lerp();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: OverlayMenuButton<String>(
              items: _items(30),
              style: const OverlayMenuStyle(
                maxHeight: 245,
                wheelMotion: motion,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final controller = _bodyController(tester) as SmoothScrollController;
    expect(controller.motion, motion);

    await _closeAll(tester);
  });
}
