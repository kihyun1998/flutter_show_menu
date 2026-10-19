import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'menu_position.dart';

/// The corner the menu scales open from: the one nearest the widget it is
/// anchored to.
///
/// [position] is where the menu **ended up**, not where it was asked to go.
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
/// where the transform is applied. See
/// `docs/adr/0004-resolve-the-scale-origin-during-layout.md`.
class MenuScaleOrigin {
  Alignment value = Alignment.center;
}

/// Scales its child about [origin], read at paint time.
///
/// Not a [ScaleTransition], deliberately; see
/// `docs/adr/0004-resolve-the-scale-origin-during-layout.md`.
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

  // No updateRenderObject, deliberately; see
  // `docs/adr/0004-resolve-the-scale-origin-during-layout.md`.
}

class RenderMenuScale extends RenderProxyBox {
  RenderMenuScale({required this.scale, required this.origin});

  /// Final by design — see
  /// `docs/adr/0004-resolve-the-scale-origin-during-layout.md`.
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

  // Required, not optional; see
  // `docs/adr/0004-resolve-the-scale-origin-during-layout.md`.
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
