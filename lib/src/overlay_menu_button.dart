import 'package:flutter/material.dart';
import 'menu_position.dart';
import 'overlay_menu.dart';
import 'overlay_menu_item.dart';
import 'overlay_menu_style.dart';

/// 자식 위젯을 감싸고, 탭 시 오버레이 메뉴를 표시하는 위젯입니다.
class OverlayMenuButton<T> extends StatelessWidget {
  const OverlayMenuButton({
    super.key,
    required this.items,
    required this.child,
    this.position = MenuPosition.bottom,
    this.alignment = MenuAlignment.start,
    this.offset = Offset.zero,
    this.onSelected,
    this.onCanceled,
    this.barrierDismissible = true,
    this.barrierColor,
    this.decoration,
    this.menuPadding,
    this.menuConstraints,
    this.menuWidth,
    this.animationDuration = const Duration(milliseconds: 150),
    this.animationCurve = Curves.easeOutCubic,
    this.enabled = true,
    this.style,
  });

  /// 메뉴 항목 목록
  final List<OverlayMenuEntry<T>> items;

  /// 탭 영역이 되는 자식 위젯
  final Widget child;

  /// 메뉴 표시 방향
  final MenuPosition position;

  /// 메뉴 교차축 정렬
  final MenuAlignment alignment;

  /// 위치 미세 조정 오프셋
  final Offset offset;

  /// 항목 선택 시 콜백
  final ValueChanged<T>? onSelected;

  /// 메뉴가 선택 없이 닫힐 때 콜백
  final VoidCallback? onCanceled;

  /// 바깥 탭으로 닫기 허용 여부
  final bool barrierDismissible;

  /// 배리어 배경색
  final Color? barrierColor;

  /// 메뉴 컨테이너 데코레이션
  final BoxDecoration? decoration;

  /// 메뉴 내부 패딩
  final EdgeInsets? menuPadding;

  /// 메뉴 크기 제약
  final BoxConstraints? menuConstraints;

  /// 메뉴 고정 너비
  final double? menuWidth;

  /// 애니메이션 지속 시간
  final Duration animationDuration;

  /// 애니메이션 커브
  final Curve animationCurve;

  /// 버튼 활성화 여부
  final bool enabled;

  /// Visual style options for the menu.
  final OverlayMenuStyle? style;

  Future<void> _show(BuildContext context) async {
    final result = await showOverlayMenu<T>(
      context: context,
      items: items,
      position: position,
      alignment: alignment,
      offset: offset,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      decoration: decoration,
      padding: menuPadding,
      constraints: menuConstraints,
      width: menuWidth,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      style: style,
    );

    if (result != null) {
      onSelected?.call(result);
    } else {
      onCanceled?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => _show(context) : null,
      child: child,
    );
  }
}
