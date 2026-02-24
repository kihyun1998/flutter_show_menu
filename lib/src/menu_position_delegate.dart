import 'dart:math';
import 'package:flutter/rendering.dart';
import 'menu_position.dart';

class MenuPositionDelegate extends SingleChildLayoutDelegate {
  MenuPositionDelegate({
    required this.targetRect,
    required this.position,
    required this.alignment,
    required this.screenSize,
    this.offset = Offset.zero,
    this.screenPadding = EdgeInsets.zero,
  });

  final Rect targetRect;
  final MenuPosition position;
  final MenuAlignment alignment;
  final Size screenSize;
  final Offset offset;
  final EdgeInsets screenPadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final safeWidth = screenSize.width - screenPadding.horizontal;
    final safeHeight = screenSize.height - screenPadding.vertical;
    return BoxConstraints.loose(Size(safeWidth, safeHeight));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double x, y;

    // 주축 위치 결정
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

    // 화면 경계 flip
    final flipped = _flipIfNeeded(x, y, childSize);
    x = flipped.dx;
    y = flipped.dy;

    // 최종 clamp
    x = x.clamp(
      screenPadding.left,
      max(screenPadding.left, screenSize.width - screenPadding.right - childSize.width),
    );
    y = y.clamp(
      screenPadding.top,
      max(screenPadding.top, screenSize.height - screenPadding.bottom - childSize.height),
    );

    return Offset(x, y);
  }

  double _crossAxisHorizontal(double menuWidth) {
    return switch (alignment) {
      MenuAlignment.start => targetRect.left + offset.dx,
      MenuAlignment.center =>
        targetRect.center.dx - menuWidth / 2 + offset.dx,
      MenuAlignment.end => targetRect.right - menuWidth + offset.dx,
    };
  }

  double _crossAxisVertical(double menuHeight) {
    return switch (alignment) {
      MenuAlignment.start => targetRect.top + offset.dy,
      MenuAlignment.center =>
        targetRect.center.dy - menuHeight / 2 + offset.dy,
      MenuAlignment.end => targetRect.bottom - menuHeight + offset.dy,
    };
  }

  Offset _flipIfNeeded(double x, double y, Size childSize) {
    final minX = screenPadding.left;
    final maxX = screenSize.width - screenPadding.right - childSize.width;
    final minY = screenPadding.top;
    final maxY = screenSize.height - screenPadding.bottom - childSize.height;

    switch (position) {
      case MenuPosition.bottom:
        if (y > maxY) {
          y = targetRect.top - childSize.height + offset.dy;
        }
      case MenuPosition.top:
        if (y < minY) {
          y = targetRect.bottom + offset.dy;
        }
      case MenuPosition.right:
        if (x > maxX) {
          x = targetRect.left - childSize.width + offset.dx;
        }
      case MenuPosition.left:
        if (x < minX) {
          x = targetRect.right + offset.dx;
        }
    }

    return Offset(x, y);
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
