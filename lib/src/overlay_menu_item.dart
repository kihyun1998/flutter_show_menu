import 'package:flutter/material.dart';

/// 오버레이 메뉴의 개별 항목을 정의합니다.
class OverlayMenuItem<T> {
  const OverlayMenuItem({
    this.value,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.height = 48.0,
    this.padding,
  });

  /// 이 항목이 선택되었을 때 반환할 값
  final T? value;

  /// 메뉴 항목의 콘텐츠 위젯
  final Widget child;

  /// 항목 탭 시 콜백 (value 반환과 별개로 동작)
  final VoidCallback? onTap;

  /// 항목 활성화 여부
  final bool enabled;

  /// 항목 높이
  final double height;

  /// 항목 내부 패딩
  final EdgeInsets? padding;
}
