import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/src/overlay_menu_item.dart';
import 'package:flutter_show_menu/src/overlay_menu_metrics.dart';
import 'package:flutter_show_menu/src/overlay_menu_style.dart';

OverlayMenuItem<String> _item(String value, {double? height}) {
  return OverlayMenuItem<String>(
    value: value,
    height: height,
    child: Text(value),
  );
}

void main() {
  group('resolveEntryHeight — item', () {
    test('prefers the item over the style over the package default', () {
      expect(
        resolveEntryHeight(_item('a', height: 12)),
        12,
      );
      expect(
        resolveEntryHeight(
          _item('a'),
          itemStyle: const OverlayMenuItemStyle(height: 30),
        ),
        30,
      );
      expect(resolveEntryHeight(_item('a')), kDefaultItemHeight);
    });

    test('an item height of zero wins over the style', () {
      // Guards against `?? `being swapped for a falsy check.
      expect(
        resolveEntryHeight(
          _item('a', height: 0),
          itemStyle: const OverlayMenuItemStyle(height: 30),
        ),
        0,
      );
    });
  });

  group('resolveEntryHeight — divider', () {
    test('falls back through height, style height, then thickness', () {
      expect(
        resolveEntryHeight(const OverlayMenuDivider<String>(height: 20)),
        20,
      );
      expect(
        resolveEntryHeight(
          const OverlayMenuDivider<String>(),
          dividerStyle: const OverlayMenuDividerStyle(height: 16),
        ),
        16,
      );
      // No height anywhere: a divider is as tall as it is thick.
      expect(
        resolveEntryHeight(const OverlayMenuDivider<String>(thickness: 3)),
        3,
      );
      expect(
        resolveEntryHeight(const OverlayMenuDivider<String>()),
        kDefaultDividerThickness,
      );
    });
  });

  group('resolveDividerThickness', () {
    test('prefers the divider over the style over the package default', () {
      expect(
        resolveDividerThickness(
          const OverlayMenuDivider<String>(thickness: 4),
          const OverlayMenuDividerStyle(thickness: 2),
        ),
        4,
      );
      expect(
        resolveDividerThickness(
          const OverlayMenuDivider<String>(),
          const OverlayMenuDividerStyle(thickness: 2),
        ),
        2,
      );
      expect(
        resolveDividerThickness(const OverlayMenuDivider<String>(), null),
        kDefaultDividerThickness,
      );
    });
  });

  group('resolveScrollOffsetToValue', () {
    test('is null when there is no initial value', () {
      expect(
        resolveScrollOffsetToValue<String>(
          entries: [_item('a'), _item('b')],
          initialValue: null,
          viewportHeight: 200,
        ),
        isNull,
      );
    });

    test('is null when no item carries the value', () {
      expect(
        resolveScrollOffsetToValue<String>(
          entries: [_item('a'), _item('b')],
          initialValue: 'zzz',
          viewportHeight: 200,
        ),
        isNull,
      );
    });

    test('centres the matched item in the viewport', () {
      // Three 48px items; 'c' starts at 96 and we want its middle (120) at the
      // middle of a 200px viewport (100). Offset = 96 - 100 + 24 = 20.
      expect(
        resolveScrollOffsetToValue<String>(
          entries: [_item('a'), _item('b'), _item('c')],
          initialValue: 'c',
          viewportHeight: 200,
        ),
        20,
      );
    });

    test('counts dividers toward the offset', () {
      // 48 (item a) + 9 (divider) = 57 before 'b'. 57 - 100 + 24 = -19.
      // The caller clamps; this module reports the true centring offset.
      expect(
        resolveScrollOffsetToValue<String>(
          entries: [
            _item('a'),
            const OverlayMenuDivider<String>(height: 9),
            _item('b'),
          ],
          initialValue: 'b',
          viewportHeight: 200,
        ),
        -19,
      );
    });

    test('honours per-entry heights when accumulating', () {
      // 10 + 20 = 30 before 'c', whose own height is 40. 30 - 50 + 20 = 0.
      expect(
        resolveScrollOffsetToValue<String>(
          entries: [
            _item('a', height: 10),
            _item('b', height: 20),
            _item('c', height: 40),
          ],
          initialValue: 'c',
          viewportHeight: 100,
        ),
        0,
      );
    });

    test('uses itemStyle height for items that do not set one', () {
      // Two 30px items; 'b' starts at 30. 30 - 50 + 15 = -5.
      expect(
        resolveScrollOffsetToValue<String>(
          entries: [_item('a'), _item('b')],
          initialValue: 'b',
          viewportHeight: 100,
          itemStyle: const OverlayMenuItemStyle(height: 30),
        ),
        -5,
      );
    });

    test('matches the first item carrying the value, not the last', () {
      // First 'dup' starts at 48. 48 - 48 + 24 = 24.
      // The second would start at 96 and give 72.
      expect(
        resolveScrollOffsetToValue<String>(
          entries: [_item('a'), _item('dup'), _item('dup')],
          initialValue: 'dup',
          viewportHeight: 96,
        ),
        24,
      );
    });

    test('agrees with resolveEntryHeight — the two cannot drift', () {
      final entries = <OverlayMenuEntry<String>>[
        _item('a', height: 11),
        const OverlayMenuDivider<String>(thickness: 2),
        _item('b'),
      ];
      const itemStyle = OverlayMenuItemStyle(height: 33);

      final summed = entries
          .take(2)
          .map((e) => resolveEntryHeight(e, itemStyle: itemStyle))
          .reduce((a, b) => a + b);

      final bHeight = resolveEntryHeight(entries[2], itemStyle: itemStyle);
      final offset = resolveScrollOffsetToValue<String>(
        entries: entries,
        initialValue: 'b',
        viewportHeight: 100,
        itemStyle: itemStyle,
      );

      expect(offset, summed - 50 + bHeight / 2);
    });
  });
}
