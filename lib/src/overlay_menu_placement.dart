import 'package:flutter/rendering.dart';

import 'menu_position.dart';

/// Where the menu sits relative to the widget it is anchored to.
class OverlayMenuPlacement {
  const OverlayMenuPlacement({
    this.position = MenuPosition.bottom,
    this.alignment = MenuAlignment.start,
    this.offset = Offset.zero,
  });

  /// Which side of the target the menu appears on.
  final MenuPosition position;

  /// Cross-axis alignment relative to the target.
  final MenuAlignment alignment;

  /// Pixel offset applied after positioning.
  final Offset offset;

  OverlayMenuPlacement copyWith({
    MenuPosition? position,
    MenuAlignment? alignment,
    Offset? offset,
  }) {
    return OverlayMenuPlacement(
      position: position ?? this.position,
      alignment: alignment ?? this.alignment,
      offset: offset ?? this.offset,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is OverlayMenuPlacement &&
        other.position == position &&
        other.alignment == alignment &&
        other.offset == offset;
  }

  @override
  int get hashCode => Object.hash(position, alignment, offset);
}
