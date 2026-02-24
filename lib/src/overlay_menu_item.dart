import 'package:flutter/material.dart';

/// Base type for entries in an overlay menu.
///
/// An entry is either an [OverlayMenuItem] (selectable row) or an
/// [OverlayMenuDivider] (visual separator).
sealed class OverlayMenuEntry<T> {
  const OverlayMenuEntry();
}

/// 오버레이 메뉴의 개별 항목을 정의합니다.
class OverlayMenuItem<T> extends OverlayMenuEntry<T> {
  const OverlayMenuItem({
    this.value,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.height,
    this.padding,
    this.selected = false,
    this.prefixBuilder,
  });

  /// 이 항목이 선택되었을 때 반환할 값
  final T? value;

  /// 메뉴 항목의 콘텐츠 위젯
  final Widget child;

  /// 항목 탭 시 콜백 (value 반환과 별개로 동작)
  final VoidCallback? onTap;

  /// 항목 활성화 여부
  final bool enabled;

  /// 항목 높이 (null → [OverlayMenuStyle.itemHeight] → 48.0)
  final double? height;

  /// 항목 내부 패딩
  final EdgeInsets? padding;

  /// Whether this item is marked as selected.
  final bool selected;

  /// Optional prefix widget builder for this item.
  /// Takes precedence over [OverlayMenuStyle.prefixBuilder].
  final Widget Function(BuildContext context, bool selected)? prefixBuilder;
}

/// A horizontal divider line inside an overlay menu.
class OverlayMenuDivider<T> extends OverlayMenuEntry<T> {
  const OverlayMenuDivider({
    this.color,
    this.thickness,
    this.indent,
    this.endIndent,
  });

  /// Divider color (null → [OverlayMenuStyle.dividerColor] → theme default).
  final Color? color;

  /// Divider thickness (null → [OverlayMenuStyle.dividerThickness] → 1.0).
  final double? thickness;

  /// Leading indent.
  final double? indent;

  /// Trailing indent.
  final double? endIndent;
}
