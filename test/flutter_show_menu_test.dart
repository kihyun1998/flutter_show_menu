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

  test('OverlayMenuDivider defaults every field to null', () {
    // Built at runtime: a const divider is evaluated at compile time, so its
    // constructor never runs.
    final divider = OverlayMenuDivider<String>(color: null);

    expect(divider.color, isNull);
    expect(divider.thickness, isNull);
    expect(divider.height, isNull);
    expect(divider.indent, isNull);
    expect(divider.endIndent, isNull);
  });

  group('configuration groups', () {
    test('every group is const-constructible with defaults', () {
      const placement = OverlayMenuPlacement();
      const barrier = OverlayMenuBarrier();
      const motion = OverlayMenuMotion();

      expect(placement.position, MenuPosition.bottom);
      expect(placement.alignment, MenuAlignment.start);
      expect(placement.offset, Offset.zero);

      expect(barrier.dismissible, isTrue);
      expect(barrier.color, isNull);
      expect(barrier.overlayChild, isNull);

      expect(motion.duration, const Duration(milliseconds: 150));
      expect(motion.curve, Curves.easeOutCubic);
    });

    test('copyWith replaces only what it is given', () {
      const placement = OverlayMenuPlacement(offset: Offset(1, 2));
      final moved = placement.copyWith(position: MenuPosition.top);
      expect(moved.position, MenuPosition.top);
      expect(moved.offset, const Offset(1, 2));
      expect(moved.alignment, MenuAlignment.start);

      const barrier = OverlayMenuBarrier(color: Color(0xFF112233));
      final undismissible = barrier.copyWith(dismissible: false);
      expect(undismissible.dismissible, isFalse);
      expect(undismissible.color, const Color(0xFF112233));

      const motion = OverlayMenuMotion(curve: Curves.linear);
      final slower = motion.copyWith(duration: const Duration(seconds: 1));
      expect(slower.duration, const Duration(seconds: 1));
      expect(slower.curve, Curves.linear);
    });

    test('the sizing family lives together on OverlayMenuStyle', () {
      const style = OverlayMenuStyle(
        maxHeight: 300,
        width: 200,
        constraints: BoxConstraints(minWidth: 100),
        decoration: BoxDecoration(color: Color(0xFF000000)),
      );

      expect(style.maxHeight, 300);
      expect(style.width, 200);
      expect(style.constraints, const BoxConstraints(minWidth: 100));
      expect(style.decoration, isNotNull);
    });
  });
}
