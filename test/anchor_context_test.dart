import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';

const _items = [OverlayMenuItem<String>(value: 'a', child: Text('Apple'))];

void main() {
  testWidgets('an unmounted anchor context is named in the failure',
      (tester) async {
    late BuildContext anchor;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              anchor = context;
              return const SizedBox(width: 10, height: 10);
            },
          ),
        ),
      ),
    );
    // Tear the anchor's widget down.
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));

    expect(
      () => showOverlayMenu<String>(context: anchor, items: _items),
      throwsA(
        isA<FlutterError>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('showOverlayMenu'),
            contains('context'),
            contains('mounted'),
          ),
        ),
      ),
    );
  });

  testWidgets('an anchor context with no RenderBox is named in the failure',
      (tester) async {
    late BuildContext anchor;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              // This Builder sits above the sliver, so its render object is a
              // RenderSliver rather than a box.
              Builder(
                builder: (context) {
                  anchor = context;
                  return const SliverToBoxAdapter(child: SizedBox(height: 10));
                },
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      () => showOverlayMenu<String>(context: anchor, items: _items),
      throwsA(
        isA<FlutterError>().having(
          (e) => e.message,
          'message',
          allOf(
            contains('showOverlayMenu'),
            contains('RenderBox'),
            contains('RenderSliverToBoxAdapter'),
          ),
        ),
      ),
    );
  });

  testWidgets('OverlayMenuButton still opens from inside a sliver',
      (tester) async {
    // The guard rejects contexts above a sliver. The button anchors to its own
    // context, which is a box, so it must keep working there.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: const [
              SliverToBoxAdapter(
                child: OverlayMenuButton<String>(
                  items: _items,
                  child: Text('open'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Apple'), findsOneWidget);

    closeAllOverlayMenus();
    await tester.pumpAndSettle();
  });

  testWidgets('a mounted box context opens the menu as before', (tester) async {
    late BuildContext anchor;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              anchor = context;
              return const SizedBox(width: 10, height: 10);
            },
          ),
        ),
      ),
    );

    final future = showOverlayMenu<String>(context: anchor, items: _items);
    await tester.pumpAndSettle();
    expect(find.text('Apple'), findsOneWidget);

    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();
    expect(await future, 'a');
  });
}
