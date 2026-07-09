import 'package:flutter/material.dart';

import 'menu_position.dart';
import 'menu_position_delegate.dart';
import 'open_menu.dart';
import 'overlay_menu_entry_view.dart';
import 'overlay_menu_item.dart';
import 'overlay_menu_metrics.dart';
import 'overlay_menu_style.dart';

/// Displays an OverlayEntry-based menu as a replacement for [showMenu].
///
/// Positions the menu relative to the [context]'s RenderBox according to
/// the given [position] direction and [alignment].
///
/// Pass a [controller] to explicitly close the menu from outside.
/// The menu automatically closes when the owning route is popped.
///
/// Parameters:
///
/// - [context] – Build context whose RenderBox is used as the anchor.
/// - [items] – Selectable entries displayed in the scrollable area.
/// - [header] – Entries pinned above the scrollable area.
/// - [footer] – Entries pinned below the scrollable area.
/// - [position] – Which side of the target the menu appears on.
/// - [alignment] – Cross-axis alignment relative to the target.
/// - [offset] – Additional pixel offset applied after positioning.
/// - [barrierDismissible] – Whether tapping outside closes the menu.
/// - [barrierColor] – Color of the full-screen barrier behind the menu.
/// - [decoration] – Extra [BoxDecoration] wrapped around the menu.
/// - [overlayChild] – Full-screen overlay above the barrier (e.g. drag-to-move area).
/// - [constraints] – Additional box constraints for the menu.
/// - [width] – Fixed width for the menu.
/// - [animationDuration] – Duration of the open/close animation.
/// - [animationCurve] – Curve of the open/close animation.
/// - [initialValue] – Value of the item to scroll to when the menu opens.
/// - [style] – Visual style options (colors, item sizes, scrollbar, etc.).
/// - [controller] – Optional controller for programmatic dismissal.
Future<T?> showOverlayMenu<T>({
  required BuildContext context,
  required List<OverlayMenuEntry<T>> items,
  List<OverlayMenuEntry<T>>? header,
  List<OverlayMenuEntry<T>>? footer,
  T? initialValue,
  MenuPosition position = MenuPosition.bottom,
  MenuAlignment alignment = MenuAlignment.start,
  Offset offset = Offset.zero,
  bool barrierDismissible = true,
  Color? barrierColor,
  BoxDecoration? decoration,
  Widget? overlayChild,
  BoxConstraints? constraints,
  double? width,
  Duration animationDuration = const Duration(milliseconds: 150),
  Curve animationCurve = Curves.easeOutCubic,
  OverlayMenuStyle? style,
  OverlayMenuController? controller,
}) {
  final renderBox = context.findRenderObject() as RenderBox;
  final targetRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
  final overlay = Overlay.of(context);

  final menu = OpenMenu<T>(
    controller: controller,
    route: ModalRoute.of<Object?>(context),
  );

  final entry = OverlayEntry(
    builder: (context) => _OverlayMenuWidget<T>(
      menu: menu,
      targetRect: targetRect,
      items: items,
      header: header,
      footer: footer,
      initialValue: initialValue,
      position: position,
      alignment: alignment,
      offset: offset,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      decoration: decoration,
      overlayChild: overlayChild,
      constraints: constraints,
      width: width,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      style: style,
    ),
  );
  menu.entry = entry;

  overlay.insert(entry);
  return menu.result;
}

class _OverlayMenuWidget<T> extends StatefulWidget {
  const _OverlayMenuWidget({
    required this.menu,
    required this.targetRect,
    required this.items,
    this.header,
    this.footer,
    this.initialValue,
    required this.position,
    required this.alignment,
    required this.offset,
    required this.barrierDismissible,
    this.barrierColor,
    this.decoration,
    this.overlayChild,
    this.constraints,
    this.width,
    required this.animationDuration,
    required this.animationCurve,
    this.style,
  });

  final OpenMenu<T> menu;
  final Rect targetRect;
  final List<OverlayMenuEntry<T>> items;
  final List<OverlayMenuEntry<T>>? header;
  final List<OverlayMenuEntry<T>>? footer;
  final T? initialValue;
  final MenuPosition position;
  final MenuAlignment alignment;
  final Offset offset;
  final bool barrierDismissible;
  final Color? barrierColor;
  final BoxDecoration? decoration;
  final Widget? overlayChild;
  final BoxConstraints? constraints;
  final double? width;
  final Duration animationDuration;
  final Curve animationCurve;
  final OverlayMenuStyle? style;

  @override
  State<_OverlayMenuWidget<T>> createState() => _OverlayMenuWidgetState<T>();
}

class _OverlayMenuWidgetState<T> extends State<_OverlayMenuWidget<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    if (widget.style?.maxHeight != null) {
      _scrollController = ScrollController();
      if (widget.initialValue != null) _jumpToInitialValue();
    }
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _scale = Tween<double>(begin: 0.9, end: 1).animate(curved);
    _controller.forward();

    // Tell the menu's lifetime that an exit animation is available. Until this
    // runs — and after dispose — an animated Close degrades to an instant one.
    widget.menu.attachExitAnimator(_playExit);
  }

  void _jumpToInitialValue() {
    final target = resolveScrollOffsetToValue<T>(
      entries: widget.items,
      initialValue: widget.initialValue,
      viewportHeight: widget.style!.maxHeight!,
      itemStyle: widget.style?.itemStyle,
      dividerStyle: widget.style?.dividerStyle,
    );
    if (target == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = _scrollController;
      if (controller != null && controller.hasClients) {
        final max = controller.position.maxScrollExtent;
        controller.jumpTo(target.clamp(0.0, max));
      }
    });
  }

  @override
  void dispose() {
    widget.menu.detachExitAnimator();
    _scrollController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playExit() async {
    try {
      await _controller.reverse();
    } on TickerCanceled {
      // An instant Close tore the menu down mid-animation and the ticker died
      // with it. There is nothing left to animate, and the result was latched
      // before this ever started.
    }
  }

  Alignment _resolveScaleAlignment() {
    return switch (widget.position) {
      MenuPosition.bottom => switch (widget.alignment) {
          MenuAlignment.start => Alignment.topLeft,
          MenuAlignment.center => Alignment.topCenter,
          MenuAlignment.end => Alignment.topRight,
        },
      MenuPosition.top => switch (widget.alignment) {
          MenuAlignment.start => Alignment.bottomLeft,
          MenuAlignment.center => Alignment.bottomCenter,
          MenuAlignment.end => Alignment.bottomRight,
        },
      MenuPosition.left => switch (widget.alignment) {
          MenuAlignment.start => Alignment.topRight,
          MenuAlignment.center => Alignment.centerRight,
          MenuAlignment.end => Alignment.bottomRight,
        },
      MenuPosition.right => switch (widget.alignment) {
          MenuAlignment.start => Alignment.topLeft,
          MenuAlignment.center => Alignment.centerLeft,
          MenuAlignment.end => Alignment.bottomLeft,
        },
    };
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenPadding = mediaQuery.padding;

    return Stack(
      children: [
        // Barrier
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.barrierDismissible
                ? () => widget.menu.close(null, animated: true)
                : null,
            child: ColoredBox(
              color: widget.barrierColor ?? Colors.transparent,
            ),
          ),
        ),

        // Overlay child
        if (widget.overlayChild != null)
          Positioned.fill(child: widget.overlayChild!),

        // Menu
        CustomSingleChildLayout(
          delegate: MenuPositionDelegate(
            targetRect: widget.targetRect,
            position: widget.position,
            alignment: widget.alignment,
            screenSize: screenSize,
            offset: widget.offset,
            screenPadding: screenPadding,
          ),
          child: FadeTransition(
            opacity: _opacity,
            child: ScaleTransition(
              scale: _scale,
              alignment: _resolveScaleAlignment(),
              child: _buildMenu(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    final theme = Theme.of(context);
    final style = widget.style;

    final bgColor =
        style?.backgroundColor ?? theme.colorScheme.surfaceContainer;
    final radius = style?.borderRadius ?? BorderRadius.circular(8);

    final padding = style?.padding ?? const EdgeInsets.symmetric(vertical: 4);

    Widget menu = Material(
      elevation: 8,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      color: bgColor,
      child: IntrinsicWidth(
        child: _buildScrollableBody(style?.maxHeight, padding),
      ),
    );

    if (widget.decoration != null) {
      menu = DecoratedBox(
        decoration: widget.decoration!,
        child: menu,
      );
    }

    if (widget.width != null) {
      menu = SizedBox(width: widget.width, child: menu);
    }

    if (widget.constraints != null) {
      menu = ConstrainedBox(
        constraints: widget.constraints!,
        child: menu,
      );
    }

    return menu;
  }

  Widget _buildScrollableBody(double? maxHeight, EdgeInsets padding) {
    final hasItems = widget.items.isNotEmpty;
    final headerEntries = hasItems
        ? widget.header
        : widget.header?.where((e) => e is! OverlayMenuDivider<T>).toList();
    final footerEntries = hasItems
        ? widget.footer
        : widget.footer?.where((e) => e is! OverlayMenuDivider<T>).toList();

    final itemWidgets =
        widget.items.map((entry) => _buildEntry(entry)).toList();

    final headerStyle = widget.style?.headerStyle;
    final footerStyle = widget.style?.footerStyle;

    if (maxHeight == null) {
      return Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (headerEntries != null)
              ...headerEntries
                  .map((e) => _buildEntry(e, styleOverride: headerStyle)),
            ...itemWidgets,
            if (footerEntries != null)
              ...footerEntries
                  .map((e) => _buildEntry(e, styleOverride: footerStyle)),
          ],
        ),
      );
    }

    final horizontalPadding =
        EdgeInsets.only(left: padding.left, right: padding.right);

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: itemWidgets,
    );

    final sb = widget.style?.scrollbarStyle;
    final scrollView = SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: horizontalPadding,
        child: column,
      ),
    );

    Widget scrollable;
    if (sb != null) {
      scrollable = ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbColor: sb.thumbColor != null
              ? WidgetStatePropertyAll(sb.thumbColor!)
              : null,
          thickness: sb.thickness != null
              ? WidgetStatePropertyAll(sb.thickness!)
              : null,
          radius: sb.radius,
          thumbVisibility: sb.thumbVisibility != null
              ? WidgetStatePropertyAll(sb.thumbVisibility!)
              : null,
        ),
        child: Scrollbar(
          controller: _scrollController,
          child: scrollView,
        ),
      );
    } else {
      scrollable = Scrollbar(
        controller: _scrollController,
        child: scrollView,
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: padding.top),
          if (headerEntries != null)
            ...headerEntries.map((e) => Padding(
                  padding: horizontalPadding,
                  child: _buildEntry(e, styleOverride: headerStyle),
                )),
          Flexible(child: scrollable),
          if (footerEntries != null)
            ...footerEntries.map((e) => Padding(
                  padding: horizontalPadding,
                  child: _buildEntry(e, styleOverride: footerStyle),
                )),
          SizedBox(height: padding.bottom),
        ],
      ),
    );
  }

  Widget _buildEntry(OverlayMenuEntry<T> entry,
      {OverlayMenuItemStyle? styleOverride}) {
    return OverlayMenuEntryView<T>(
      entry: entry,
      itemStyle: styleOverride ?? widget.style?.itemStyle,
      dividerStyle: widget.style?.dividerStyle,
      isSelected: entry is OverlayMenuItem<T> &&
          widget.initialValue != null &&
          entry.value == widget.initialValue,
      onSelected: (value) => widget.menu.close(value, animated: true),
    );
  }
}
