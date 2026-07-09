import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';

void main() {
  group('OverlayMenuMotion', () {
    test('two motions with the same duration and curve are equal', () {
      // Never `const`: two identical const values are canonicalised into one
      // instance, so an identity `==` would pass and hide a missing operator.
      final ms = 200;
      final a = OverlayMenuMotion(
        duration: Duration(milliseconds: ms),
        curve: Curves.linear,
      );
      final b = OverlayMenuMotion(
        duration: Duration(milliseconds: ms),
        curve: Curves.linear,
      );

      expect(identical(a, b), isFalse, reason: 'the test must compare values');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('differing motions are unequal', () {
      final base = OverlayMenuMotion(duration: Duration(milliseconds: 200));
      expect(base, isNot(equals(base.copyWith(curve: Curves.linear))));
      expect(
        base,
        isNot(equals(base.copyWith(duration: const Duration(seconds: 1)))),
      );
    });

    // Curve has no `==` of its own. This pins the boundary rather than driving
    // it: const curves are canonicalised and compare equal, separately built
    // ones never do, however identical their coefficients.
    test('curves compare by identity, so const curves are equal', () {
      final withConst = OverlayMenuMotion(curve: Curves.easeOutCubic);
      final withSameConst = OverlayMenuMotion(curve: Curves.easeOutCubic);
      expect(withConst, equals(withSameConst));
    });

    test('separately built curves are unequal even with equal coefficients',
        () {
      final x = 0.2;
      final left = OverlayMenuMotion(curve: Cubic(x, 0.6, 0.35, 1));
      final right = OverlayMenuMotion(curve: Cubic(x, 0.6, 0.35, 1));
      expect(left, isNot(equals(right)));
    });
  });

  group('OverlayMenuPlacement', () {
    test(
        'two placements with the same position, alignment, and offset are '
        'equal', () {
      final dx = 4.0;
      final a = OverlayMenuPlacement(
        position: MenuPosition.left,
        alignment: MenuAlignment.center,
        offset: Offset(dx, 8),
      );
      final b = OverlayMenuPlacement(
        position: MenuPosition.left,
        alignment: MenuAlignment.center,
        offset: Offset(dx, 8),
      );

      expect(identical(a, b), isFalse, reason: 'the test must compare values');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('differing placements are unequal', () {
      const base = OverlayMenuPlacement();
      expect(base, isNot(equals(base.copyWith(position: MenuPosition.top))));
      expect(base, isNot(equals(base.copyWith(alignment: MenuAlignment.end))));
      expect(base, isNot(equals(base.copyWith(offset: const Offset(1, 0)))));
    });

    test('a const default equals a freshly constructed identical value', () {
      final built = OverlayMenuPlacement(
        position: MenuPosition.bottom,
        alignment: MenuAlignment.start,
        offset: Offset(0, 0),
      );
      expect(const OverlayMenuPlacement(), equals(built));
    });
  });

  group('OverlayMenuBarrier', () {
    test('two barriers with the same dismissible and color are equal', () {
      final alpha = 0x80;
      final a = OverlayMenuBarrier(
        dismissible: false,
        color: Color.fromARGB(alpha, 0, 0, 0),
      );
      final b = OverlayMenuBarrier(
        dismissible: false,
        color: Color.fromARGB(alpha, 0, 0, 0),
      );

      expect(identical(a, b), isFalse, reason: 'the test must compare values');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('differing barriers are unequal', () {
      const base = OverlayMenuBarrier();
      expect(base, isNot(equals(base.copyWith(dismissible: false))));
      expect(
          base, isNot(equals(base.copyWith(color: const Color(0xFF000000)))));
    });

    // Widget has no `==` of its own. These pin the boundary rather than drive
    // it, mirroring the curve case on OverlayMenuMotion.
    test('barriers sharing one overlayChild instance are equal', () {
      const child = SizedBox();
      final left = OverlayMenuBarrier(overlayChild: child);
      final right = OverlayMenuBarrier(overlayChild: child);
      expect(left, equals(right));
    });

    test('separately constructed overlayChild widgets are unequal', () {
      // True even for `const SizedBox()`: under `flutter test` and in debug
      // builds, widget creation tracking stamps each const constructor call
      // site with its own location, so the two are not the same instance.
      // Release builds canonicalise them. Never rely on const widget equality.
      final left = OverlayMenuBarrier(overlayChild: const SizedBox());
      final right = OverlayMenuBarrier(overlayChild: const SizedBox());
      expect(left, isNot(equals(right)));
    });
  });

  group('OverlayMenuItemStyle', () {
    test('two item styles with the same fields are equal', () {
      final height = 32.0;
      final a = OverlayMenuItemStyle(
        height: height,
        backgroundColor: const Color(0xFF111111),
        mouseCursor: SystemMouseCursors.basic,
      );
      final b = OverlayMenuItemStyle(
        height: height,
        backgroundColor: const Color(0xFF111111),
        mouseCursor: SystemMouseCursors.basic,
      );

      expect(identical(a, b), isFalse, reason: 'the test must compare values');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith replaces only the field it is given', () {
      const base = OverlayMenuItemStyle(
        height: 40,
        hoverColor: Color(0xFF222222),
      );
      final taller = base.copyWith(height: 60);

      expect(taller.height, 60);
      expect(taller.hoverColor, const Color(0xFF222222));
      expect(base.height, 40, reason: 'copyWith must not mutate the receiver');
    });

    test('copyWith given nothing preserves every field', () {
      final base = OverlayMenuItemStyle(
        height: 40.0 + 1,
        borderRadius: BorderRadius.circular(3),
        backgroundColor: const Color(0xFF111111),
        selectedBackgroundColor: const Color(0xFF222222),
        hoverColor: const Color(0xFF333333),
        splashColor: const Color(0xFF444444),
        highlightColor: const Color(0xFF555555),
        focusColor: const Color(0xFF666666),
        mouseCursor: SystemMouseCursors.basic,
      );
      expect(base.copyWith(), equals(base));
    });
  });

  group('OverlayMenuDividerStyle', () {
    test('two divider styles with the same fields are equal', () {
      final thickness = 2.0;
      final a = OverlayMenuDividerStyle(thickness: thickness, indent: 6);
      final b = OverlayMenuDividerStyle(thickness: thickness, indent: 6);

      expect(identical(a, b), isFalse, reason: 'the test must compare values');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(a.copyWith(indent: 7))));
    });

    test('copyWith given nothing preserves every field', () {
      final base = OverlayMenuDividerStyle(
        color: const Color(0xFF111111),
        thickness: 1.0 + 1,
        height: 8,
        indent: 4,
        endIndent: 2,
      );
      expect(base.copyWith(), equals(base));
    });
  });

  group('OverlayMenuScrollbarStyle', () {
    test('two scrollbar styles with the same fields are equal', () {
      final thickness = 4.0;
      final a = OverlayMenuScrollbarStyle(
        thickness: thickness,
        radius: const Radius.circular(8),
        thumbVisibility: true,
      );
      final b = OverlayMenuScrollbarStyle(
        thickness: thickness,
        radius: const Radius.circular(8),
        thumbVisibility: true,
      );

      expect(identical(a, b), isFalse, reason: 'the test must compare values');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(a.copyWith(thumbVisibility: false))));
    });

    test('copyWith given nothing preserves every field', () {
      final base = OverlayMenuScrollbarStyle(
        thumbColor: const Color(0xFF111111),
        thickness: 2.0 + 2,
        radius: const Radius.circular(8),
        thumbVisibility: true,
      );
      expect(base.copyWith(), equals(base));
    });
  });

  group('OverlayMenuStyle', () {
    OverlayMenuStyle build({double itemHeight = 48}) {
      return OverlayMenuStyle(
        backgroundColor: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.all(4),
        maxHeight: 300,
        width: 200,
        constraints: const BoxConstraints(minWidth: 100),
        decoration: const BoxDecoration(color: Color(0xFF202020)),
        itemStyle: OverlayMenuItemStyle(height: itemHeight),
        dividerStyle: const OverlayMenuDividerStyle(thickness: 2),
        scrollbarStyle: const OverlayMenuScrollbarStyle(thickness: 4),
      );
    }

    test('two styles with the same fields are equal', () {
      final a = build();
      final b = build();

      expect(identical(a, b), isFalse, reason: 'the test must compare values');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equality composes into the nested item style', () {
      // The only difference is one field, one level down.
      expect(build(itemHeight: 48), isNot(equals(build(itemHeight: 49))));
    });

    test('a const default equals a freshly constructed identical value', () {
      final built = OverlayMenuStyle(maxHeight: 100.0 * 3);
      expect(const OverlayMenuStyle(maxHeight: 300), equals(built));
    });

    test('copyWith replaces only the field it is given', () {
      const base = OverlayMenuStyle(maxHeight: 300, width: 200);
      final narrower = base.copyWith(width: 120);

      expect(narrower.width, 120);
      expect(narrower.maxHeight, 300);
      expect(base.width, 200, reason: 'copyWith must not mutate the receiver');
    });

    test('copyWith given nothing preserves every field', () {
      final base = build().copyWith(
        headerStyle: const OverlayMenuItemStyle(height: 30),
        footerStyle: const OverlayMenuItemStyle(height: 20),
      );
      expect(base.copyWith(), equals(base));
    });

    test('copyWith preserves every nested style it is not given', () {
      final base = build();
      final restyled = base.copyWith(width: 999);

      expect(restyled.itemStyle, equals(base.itemStyle));
      expect(restyled.dividerStyle, equals(base.dividerStyle));
      expect(restyled.scrollbarStyle, equals(base.scrollbarStyle));
      expect(restyled.decoration, equals(base.decoration));
      expect(restyled, isNot(equals(base)));
    });

    test('header and footer styles participate in equality', () {
      const left = OverlayMenuStyle(
        headerStyle: OverlayMenuItemStyle(height: 30),
      );
      const right = OverlayMenuStyle(
        footerStyle: OverlayMenuItemStyle(height: 30),
      );
      expect(left, isNot(equals(right)));
    });
  });
}
