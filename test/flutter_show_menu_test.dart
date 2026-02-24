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
}
