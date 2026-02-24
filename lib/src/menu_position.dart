/// Determines which side of the target widget the menu will appear on.
enum MenuPosition {
  /// Display the menu above the target widget.
  top,

  /// Display the menu below the target widget.
  bottom,

  /// Display the menu to the left of the target widget.
  left,

  /// Display the menu to the right of the target widget.
  right,
}

/// Determines the cross-axis alignment of the menu.
///
/// Applies to horizontal alignment when [MenuPosition] is top/bottom,
/// and vertical alignment when left/right.
enum MenuAlignment {
  /// Align the menu to the start edge of the target widget.
  ///
  /// Left for horizontal alignment, top for vertical alignment.
  start,

  /// Center the menu relative to the target widget.
  center,

  /// Align the menu to the end edge of the target widget.
  ///
  /// Right for horizontal alignment, bottom for vertical alignment.
  end,
}
