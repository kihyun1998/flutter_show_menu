import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/src/overlay_menu_entry_view.dart';
import 'package:flutter_show_menu/src/overlay_menu_item.dart';
import 'package:flutter_show_menu/src/overlay_menu_metrics.dart';
import 'package:flutter_show_menu/src/overlay_menu_style.dart';

/// Pumps the view on its own — no Overlay, no menu, no route.
Future<void> _pumpView(
  WidgetTester tester,
  OverlayMenuEntryView<String> view, {
  ThemeData? theme,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(body: view),
    ),
  );
}

Color? _inkColor(WidgetTester tester) {
  final ink = tester.widget<Ink>(find.byType(Ink));
  return (ink.decoration as BoxDecoration?)?.color;
}

void main() {
  group('item', () {
    testWidgets('draws its child', (tester) async {
      await _pumpView(
        tester,
        OverlayMenuEntryView<String>(
          entry: const OverlayMenuItem<String>(
            value: 'a',
            child: Text('Hello'),
          ),
          onSelected: (_) {},
        ),
      );
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('takes its height from the metrics module', (tester) async {
      await _pumpView(
        tester,
        OverlayMenuEntryView<String>(
          entry: const OverlayMenuItem<String>(value: 'a', child: Text('a')),
          onSelected: (_) {},
        ),
      );
      final box = tester.widget<Container>(find.byType(Container));
      expect(box.constraints?.maxHeight, kDefaultItemHeight);

      await _pumpView(
        tester,
        OverlayMenuEntryView<String>(
          entry: const OverlayMenuItem<String>(
            value: 'a',
            child: Text('a'),
            height: 21,
          ),
          onSelected: (_) {},
        ),
      );
      expect(
        tester.widget<Container>(find.byType(Container)).constraints?.maxHeight,
        21,
      );
    });

    testWidgets('selects before running the item\'s own onTap', (tester) async {
      final calls = <String>[];
      await _pumpView(
        tester,
        OverlayMenuEntryView<String>(
          entry: OverlayMenuItem<String>(
            value: 'a',
            onTap: () => calls.add('onTap'),
            child: const Text('Tap me'),
          ),
          onSelected: (value) => calls.add('onSelected:$value'),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();

      // Ordering is load-bearing: the caller latches the result on select, so
      // a side effect in onTap cannot overtake it with a null Close.
      expect(calls, ['onSelected:a', 'onTap']);
    });

    testWidgets('a disabled item does not respond to taps', (tester) async {
      var selected = false;
      var tapped = false;
      await _pumpView(
        tester,
        OverlayMenuEntryView<String>(
          entry: OverlayMenuItem<String>(
            value: 'a',
            enabled: false,
            onTap: () => tapped = true,
            child: const Text('Nope'),
          ),
          onSelected: (_) => selected = true,
        ),
      );

      await tester.tap(find.text('Nope'));
      await tester.pump();

      expect(selected, isFalse);
      expect(tapped, isFalse);
      expect(tester.widget<InkWell>(find.byType(InkWell)).onTap, isNull);
    });

    testWidgets('a disabled item paints its text with the disabled color',
        (tester) async {
      final theme = ThemeData(disabledColor: const Color(0xFF123456));
      await _pumpView(
        tester,
        OverlayMenuEntryView<String>(
          entry: const OverlayMenuItem<String>(
            value: 'a',
            enabled: false,
            child: Text('Dim'),
          ),
          onSelected: (_) {},
        ),
        theme: theme,
      );

      final text = tester.widget<Text>(find.text('Dim'));
      final style = DefaultTextStyle.of(
        tester.element(find.text('Dim')),
      ).style;
      expect(text.style, isNull);
      expect(style.color, const Color(0xFF123456));
    });

    testWidgets('selection swaps the ink color', (tester) async {
      const style = OverlayMenuItemStyle(
        backgroundColor: Color(0xFF111111),
        selectedBackgroundColor: Color(0xFF222222),
      );

      await _pumpView(
        tester,
        OverlayMenuEntryView<String>(
          entry: const OverlayMenuItem<String>(value: 'a', child: Text('a')),
          itemStyle: style,
          onSelected: (_) {},
        ),
      );
      expect(_inkColor(tester), const Color(0xFF111111));

      await _pumpView(
        tester,
        OverlayMenuEntryView<String>(
          entry: const OverlayMenuItem<String>(value: 'a', child: Text('a')),
          itemStyle: style,
          isSelected: true,
          onSelected: (_) {},
        ),
      );
      expect(_inkColor(tester), const Color(0xFF222222));
    });

    testWidgets('an enabled item uses the click cursor by default',
        (tester) async {
      await _pumpView(
        tester,
        OverlayMenuEntryView<String>(
          entry: const OverlayMenuItem<String>(value: 'a', child: Text('a')),
          onSelected: (_) {},
        ),
      );
      expect(
        tester.widget<InkWell>(find.byType(InkWell)).mouseCursor,
        SystemMouseCursors.click,
      );

      await _pumpView(
        tester,
        OverlayMenuEntryView<String>(
          entry: const OverlayMenuItem<String>(
            value: 'a',
            enabled: false,
            child: Text('a'),
          ),
          onSelected: (_) {},
        ),
      );
      expect(
        tester.widget<InkWell>(find.byType(InkWell)).mouseCursor,
        SystemMouseCursors.basic,
      );
    });
  });

  group('divider', () {
    testWidgets('resolves thickness and height through the metrics module',
        (tester) async {
      await _pumpView(
        tester,
        OverlayMenuEntryView<String>(
          entry: const OverlayMenuDivider<String>(),
          onSelected: (_) {},
        ),
      );
      var divider = tester.widget<Divider>(find.byType(Divider));
      expect(divider.thickness, kDefaultDividerThickness);
      expect(divider.height, kDefaultDividerThickness);

      await _pumpView(
        tester,
        OverlayMenuEntryView<String>(
          entry: const OverlayMenuDivider<String>(thickness: 3),
          dividerStyle: const OverlayMenuDividerStyle(height: 12),
          onSelected: (_) {},
        ),
      );
      divider = tester.widget<Divider>(find.byType(Divider));
      expect(divider.thickness, 3);
      expect(divider.height, 12);
    });

    testWidgets('the divider overrides its style', (tester) async {
      await _pumpView(
        tester,
        OverlayMenuEntryView<String>(
          entry: const OverlayMenuDivider<String>(
            color: Color(0xFFAABBCC),
            indent: 8,
            endIndent: 4,
          ),
          dividerStyle: const OverlayMenuDividerStyle(
            color: Color(0xFF000000),
            indent: 99,
            endIndent: 99,
          ),
          onSelected: (_) {},
        ),
      );
      final divider = tester.widget<Divider>(find.byType(Divider));
      expect(divider.color, const Color(0xFFAABBCC));
      expect(divider.indent, 8);
      expect(divider.endIndent, 4);
    });

    testWidgets('falls back to the divider style', (tester) async {
      await _pumpView(
        tester,
        OverlayMenuEntryView<String>(
          entry: const OverlayMenuDivider<String>(),
          dividerStyle: const OverlayMenuDividerStyle(
            color: Color(0xFF00FF00),
            indent: 6,
            endIndent: 2,
          ),
          onSelected: (_) {},
        ),
      );
      final divider = tester.widget<Divider>(find.byType(Divider));
      expect(divider.color, const Color(0xFF00FF00));
      expect(divider.indent, 6);
      expect(divider.endIndent, 2);
    });
  });
}
