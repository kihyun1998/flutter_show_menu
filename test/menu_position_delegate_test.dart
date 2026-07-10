import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_show_menu/src/menu_position.dart';
import 'package:flutter_show_menu/src/menu_position_delegate.dart';

/// A 100x50 target sitting comfortably in the middle of an 800x600 screen,
/// far enough from every edge that neither flip nor clamp engages.
const _target = Rect.fromLTWH(300, 250, 100, 50);
const _screen = Size(800, 600);
const _child = Size(120, 80);

Offset _positionFor({
  required MenuPosition position,
  required MenuAlignment alignment,
  Rect target = _target,
  Size child = _child,
  Size screen = _screen,
  Offset offset = Offset.zero,
  EdgeInsets screenPadding = EdgeInsets.zero,
}) {
  return MenuPositionDelegate(
    targetRect: target,
    position: position,
    alignment: alignment,
    screenSize: screen,
    offset: offset,
    screenPadding: screenPadding,
  ).getPositionForChild(screen, child);
}

void main() {
  // Layer 1: placement. Target is centred, so flip and clamp stay out of it.
  group('placement', () {
    test('bottom anchors below the target, cross-axis follows alignment', () {
      expect(
        _positionFor(
            position: MenuPosition.bottom, alignment: MenuAlignment.start),
        const Offset(300, 300), // target.left, target.bottom
      );
      expect(
        _positionFor(
            position: MenuPosition.bottom, alignment: MenuAlignment.center),
        const Offset(290, 300), // centre 350 - half of 120
      );
      expect(
        _positionFor(
            position: MenuPosition.bottom, alignment: MenuAlignment.end),
        const Offset(280, 300), // target.right - 120
      );
    });

    test('top anchors above the target', () {
      expect(
        _positionFor(
            position: MenuPosition.top, alignment: MenuAlignment.start),
        const Offset(300, 170), // target.top - 80
      );
      expect(
        _positionFor(
            position: MenuPosition.top, alignment: MenuAlignment.center),
        const Offset(290, 170),
      );
      expect(
        _positionFor(position: MenuPosition.top, alignment: MenuAlignment.end),
        const Offset(280, 170),
      );
    });

    test('right anchors beside the target, cross-axis is vertical', () {
      expect(
        _positionFor(
            position: MenuPosition.right, alignment: MenuAlignment.start),
        const Offset(400, 250), // target.right, target.top
      );
      expect(
        _positionFor(
            position: MenuPosition.right, alignment: MenuAlignment.center),
        const Offset(400, 235), // centre 275 - half of 80
      );
      expect(
        _positionFor(
            position: MenuPosition.right, alignment: MenuAlignment.end),
        const Offset(400, 220), // target.bottom - 80
      );
    });

    test('left anchors beside the target', () {
      expect(
        _positionFor(
            position: MenuPosition.left, alignment: MenuAlignment.start),
        const Offset(180, 250), // target.left - 120
      );
      expect(
        _positionFor(
            position: MenuPosition.left, alignment: MenuAlignment.center),
        const Offset(180, 235),
      );
      expect(
        _positionFor(position: MenuPosition.left, alignment: MenuAlignment.end),
        const Offset(180, 220),
      );
    });

    test('offset shifts both axes', () {
      expect(
        _positionFor(
          position: MenuPosition.bottom,
          alignment: MenuAlignment.start,
          offset: const Offset(10, 5),
        ),
        const Offset(310, 305),
      );
    });
  });

  // Layer 2: flip. The menu jumps to the opposite side of the target rather
  // than being merely clamped, so it never covers the thing it anchors to.
  group('flip on overflow', () {
    test('bottom flips above when it would overrun the bottom edge', () {
      expect(
        _positionFor(
          position: MenuPosition.bottom,
          alignment: MenuAlignment.start,
          target: const Rect.fromLTWH(300, 540, 100, 50), // bottom = 590
        ),
        const Offset(300, 460), // target.top - 80
      );
    });

    test('top flips below when it would overrun the top edge', () {
      expect(
        _positionFor(
          position: MenuPosition.top,
          alignment: MenuAlignment.start,
          target: const Rect.fromLTWH(300, 10, 100, 50), // top - 80 = -70
        ),
        const Offset(300, 60), // target.bottom
      );
    });

    test('right flips left when it would overrun the right edge', () {
      expect(
        _positionFor(
          position: MenuPosition.right,
          alignment: MenuAlignment.start,
          target: const Rect.fromLTWH(650, 250, 100, 50), // right = 750
        ),
        const Offset(530, 250), // target.left - 120
      );
    });

    test('left flips right when it would overrun the left edge', () {
      expect(
        _positionFor(
          position: MenuPosition.left,
          alignment: MenuAlignment.start,
          target: const Rect.fromLTWH(50, 250, 100, 50), // left - 120 = -70
        ),
        const Offset(150, 250), // target.right
      );
    });

    test('screenPadding tightens the edge that triggers the flip', () {
      // bottom = 530 clears the raw screen edge but not the 34px safe area.
      expect(
        _positionFor(
          position: MenuPosition.bottom,
          alignment: MenuAlignment.start,
          target: const Rect.fromLTWH(300, 480, 100, 50),
          screenPadding: const EdgeInsets.only(bottom: 34),
        ),
        const Offset(300, 400), // flipped above: target.top - 80
      );
    });
  });

  // Layer 3: clamp. Cross-axis alignment can push the menu off-screen even
  // when the main axis fits; flip only ever corrects the main axis.
  group('clamp to safe area', () {
    test('a centred menu wider than the gap is pulled back to the left edge',
        () {
      expect(
        _positionFor(
          position: MenuPosition.bottom,
          alignment: MenuAlignment.center,
          target: const Rect.fromLTWH(10, 250, 100, 50), // centre.dx = 60
          child: const Size(300, 80), // 60 - 150 = -90
        ),
        const Offset(0, 300),
      );
    });

    test('clamping respects screenPadding rather than the raw screen edge', () {
      expect(
        _positionFor(
          position: MenuPosition.bottom,
          alignment: MenuAlignment.center,
          target: const Rect.fromLTWH(10, 250, 100, 50),
          child: const Size(300, 80),
          screenPadding: const EdgeInsets.only(left: 16),
        ),
        const Offset(16, 300),
      );
    });

    test('a menu larger than the screen pins to the origin instead of throwing',
        () {
      // Guards the max() in the clamp bounds: without it the lower limit would
      // exceed the upper limit and num.clamp would raise ArgumentError.
      expect(
        () => _positionFor(
          position: MenuPosition.bottom,
          alignment: MenuAlignment.start,
          child: const Size(900, 700),
        ),
        returnsNormally,
      );
      expect(
        _positionFor(
          position: MenuPosition.bottom,
          alignment: MenuAlignment.start,
          child: const Size(900, 700),
        ),
        Offset.zero,
      );
    });
  });

  group('getConstraintsForChild', () {
    test('loosens to the screen minus its padding', () {
      final constraints = MenuPositionDelegate(
        targetRect: _target,
        position: MenuPosition.bottom,
        alignment: MenuAlignment.start,
        screenSize: _screen,
        screenPadding: const EdgeInsets.fromLTRB(16, 44, 16, 34),
      ).getConstraintsForChild(const BoxConstraints());

      expect(constraints, BoxConstraints.loose(const Size(768, 522)));
    });
  });

  group('shouldRelayout', () {
    MenuPositionDelegate delegate({
      Rect target = _target,
      MenuPosition position = MenuPosition.bottom,
      MenuAlignment alignment = MenuAlignment.start,
      Size screen = _screen,
      Offset offset = Offset.zero,
      EdgeInsets screenPadding = EdgeInsets.zero,
    }) {
      return MenuPositionDelegate(
        targetRect: target,
        position: position,
        alignment: alignment,
        screenSize: screen,
        offset: offset,
        screenPadding: screenPadding,
      );
    }

    test('is false when nothing changed', () {
      expect(delegate().shouldRelayout(delegate()), isFalse);
    });

    test('is true when any input changed', () {
      final old = delegate();
      expect(
        delegate(target: const Rect.fromLTWH(0, 0, 10, 10)).shouldRelayout(old),
        isTrue,
      );
      expect(delegate(position: MenuPosition.top).shouldRelayout(old), isTrue);
      expect(
        delegate(alignment: MenuAlignment.end).shouldRelayout(old),
        isTrue,
      );
      expect(
          delegate(screen: const Size(400, 300)).shouldRelayout(old), isTrue);
      expect(delegate(offset: const Offset(1, 1)).shouldRelayout(old), isTrue);
      expect(
        delegate(screenPadding: const EdgeInsets.all(1)).shouldRelayout(old),
        isTrue,
      );
    });
  });
}
