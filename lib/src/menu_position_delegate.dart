import 'dart:math';
import 'package:flutter/rendering.dart';
import 'menu_position.dart';
import 'menu_scale_origin.dart';

class MenuPositionDelegate extends SingleChildLayoutDelegate {
  MenuPositionDelegate({
    required this.targetRect,
    required this.position,
    required this.alignment,
    required this.screenSize,
    this.offset = Offset.zero,
    this.screenPadding = EdgeInsets.zero,
    this.scaleOrigin,
  });

  final Rect targetRect;
  final MenuPosition position;
  final MenuAlignment alignment;
  final Size screenSize;
  final Offset offset;
  final EdgeInsets screenPadding;

  /// Written during layout with the corner the menu should scale open from,
  /// once it is known which side of the target the menu actually landed on.
  final MenuScaleOrigin? scaleOrigin;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final safeWidth = screenSize.width - screenPadding.horizontal;
    final safeHeight = screenSize.height - screenPadding.vertical;
    return BoxConstraints.loose(Size(safeWidth, safeHeight));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double x, y;

    // Determine main-axis position
    switch (position) {
      case MenuPosition.bottom:
        y = targetRect.bottom + offset.dy;
        x = _crossAxisHorizontal(childSize.width);
      case MenuPosition.top:
        y = targetRect.top - childSize.height + offset.dy;
        x = _crossAxisHorizontal(childSize.width);
      case MenuPosition.right:
        x = targetRect.right + offset.dx;
        y = _crossAxisVertical(childSize.height);
      case MenuPosition.left:
        x = targetRect.left - childSize.width + offset.dx;
        y = _crossAxisVertical(childSize.height);
    }

    // Flip if overflowing screen bounds
    final (flipped, landedOn) = _flipIfNeeded(x, y, childSize);
    x = flipped.dx;
    y = flipped.dy;

    // The nearest edge follows the side the menu landed on, not the side it
    // asked for. Paint reads this after layout, in the same frame.
    scaleOrigin?.value = resolveScaleOrigin(landedOn, alignment);

    // Final clamp to safe area
    x = x.clamp(
      screenPadding.left,
      max(screenPadding.left,
          screenSize.width - screenPadding.right - childSize.width),
    );
    y = y.clamp(
      screenPadding.top,
      max(screenPadding.top,
          screenSize.height - screenPadding.bottom - childSize.height),
    );

    return Offset(x, y);
  }

  double _crossAxisHorizontal(double menuWidth) {
    return switch (alignment) {
      MenuAlignment.start => targetRect.left + offset.dx,
      MenuAlignment.center => targetRect.center.dx - menuWidth / 2 + offset.dx,
      MenuAlignment.end => targetRect.right - menuWidth + offset.dx,
    };
  }

  double _crossAxisVertical(double menuHeight) {
    return switch (alignment) {
      MenuAlignment.start => targetRect.top + offset.dy,
      MenuAlignment.center => targetRect.center.dy - menuHeight / 2 + offset.dy,
      MenuAlignment.end => targetRect.bottom - menuHeight + offset.dy,
    };
  }

  /// Moves the menu to the opposite side of the target when it would overrun
  /// the screen, and reports the side it ended up on.
  (Offset, MenuPosition) _flipIfNeeded(double x, double y, Size childSize) {
    final minX = screenPadding.left;
    final maxX = screenSize.width - screenPadding.right - childSize.width;
    final minY = screenPadding.top;
    final maxY = screenSize.height - screenPadding.bottom - childSize.height;

    var landedOn = position;

    switch (position) {
      case MenuPosition.bottom:
        if (y > maxY) {
          y = targetRect.top - childSize.height + offset.dy;
          landedOn = MenuPosition.top;
        }
      case MenuPosition.top:
        if (y < minY) {
          y = targetRect.bottom + offset.dy;
          landedOn = MenuPosition.bottom;
        }
      case MenuPosition.right:
        if (x > maxX) {
          x = targetRect.left - childSize.width + offset.dx;
          landedOn = MenuPosition.left;
        }
      case MenuPosition.left:
        if (x < minX) {
          x = targetRect.right + offset.dx;
          landedOn = MenuPosition.right;
        }
    }

    return (Offset(x, y), landedOn);
  }

  @override
  bool shouldRelayout(covariant MenuPositionDelegate oldDelegate) {
    return targetRect != oldDelegate.targetRect ||
        position != oldDelegate.position ||
        alignment != oldDelegate.alignment ||
        screenSize != oldDelegate.screenSize ||
        offset != oldDelegate.offset ||
        screenPadding != oldDelegate.screenPadding;
  }
}
