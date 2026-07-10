import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'menu_position.dart';

/// The corner the menu scales open from, so the animation reads as the menu
/// emerging from the widget it is anchored to.
///
/// [position] is where the menu **ended up**, not where it was asked to go.
/// When the delegate flips a menu to the opposite side of its target, the
/// nearest edge flips with it.
Alignment resolveScaleOrigin(MenuPosition position, MenuAlignment alignment) {
  return switch (position) {
    MenuPosition.bottom => switch (alignment) {
        MenuAlignment.start => Alignment.topLeft,
        MenuAlignment.center => Alignment.topCenter,
        MenuAlignment.end => Alignment.topRight,
      },
    MenuPosition.top => switch (alignment) {
        MenuAlignment.start => Alignment.bottomLeft,
        MenuAlignment.center => Alignment.bottomCenter,
        MenuAlignment.end => Alignment.bottomRight,
      },
    MenuPosition.left => switch (alignment) {
        MenuAlignment.start => Alignment.topRight,
        MenuAlignment.center => Alignment.centerRight,
        MenuAlignment.end => Alignment.bottomRight,
      },
    MenuPosition.right => switch (alignment) {
        MenuAlignment.start => Alignment.topLeft,
        MenuAlignment.center => Alignment.centerLeft,
        MenuAlignment.end => Alignment.bottomLeft,
      },
  };
}

/// Carries the scale origin from layout, where the flip is decided, to paint,
/// where the transform is applied.
///
/// A menu cannot know at build time whether it will overflow the screen and be
/// flipped: that needs its own size, which only layout produces. Paint runs
/// after layout in the same frame, so reading the origin there is always
/// current — no extra rebuild and no wrong first frame.
class MenuScaleOrigin {
  Alignment value = Alignment.center;
}

/// Scales its child about [origin], read at paint time.
///
/// [ScaleTransition] takes its alignment from the widget tree, which is built
/// before layout has decided whether the menu flips. This reads the origin
/// after layout instead, so the first painted frame is already correct.
class MenuScaleTransition extends SingleChildRenderObjectWidget {
  const MenuScaleTransition({
    super.key,
    required this.scale,
    required this.origin,
    required Widget super.child,
  });

  final Animation<double> scale;
  final MenuScaleOrigin origin;

  @override
  RenderMenuScale createRenderObject(BuildContext context) =>
      RenderMenuScale(scale: scale, origin: origin);

  // No updateRenderObject. The menu's State creates its animation and its
  // origin once and never swaps them, so a rebuild carries the same instances
  // and there is nothing to update.
}

class RenderMenuScale extends RenderProxyBox {
  RenderMenuScale({required this.scale, required this.origin});

  /// Final by design — see [MenuScaleTransition].
  final Animation<double> scale;
  final MenuScaleOrigin origin;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    scale.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    scale.removeListener(markNeedsPaint);
    super.detach();
  }

  Matrix4 get _transform {
    final factor = scale.value;
    final about = origin.value.alongSize(size);
    return Matrix4.identity()
      ..translateByDouble(about.dx, about.dy, 0, 1)
      ..scaleByDouble(factor, factor, 1, 1)
      ..translateByDouble(-about.dx, -about.dy, 0, 1);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    layer = context.pushTransform(
      needsCompositing,
      offset,
      _transform,
      super.paint,
      oldLayer: layer as TransformLayer?,
    );
  }

  // localToGlobal walks this, so without it the rendered geometry would not
  // reflect the scale — and neither would a test that measures it.
  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.multiply(_transform);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintTransform(
      transform: _transform,
      position: position,
      hitTest: (BoxHitTestResult result, Offset position) {
        return super.hitTestChildren(result, position: position);
      },
    );
  }
}
