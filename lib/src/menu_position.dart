/// 메뉴가 타겟 위젯의 어느 쪽에 표시될지 결정합니다.
enum MenuPosition {
  top,
  bottom,
  left,
  right,
}

/// 메뉴의 교차축 정렬을 결정합니다.
///
/// [MenuPosition]이 top/bottom일 때 수평 정렬,
/// left/right일 때 수직 정렬에 적용됩니다.
enum MenuAlignment {
  start,
  center,
  end,
}
