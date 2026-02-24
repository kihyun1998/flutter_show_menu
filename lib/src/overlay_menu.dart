import 'dart:async';
import 'package:flutter/material.dart';
import 'menu_position.dart';
import 'menu_position_delegate.dart';
import 'overlay_menu_item.dart';
import 'overlay_menu_style.dart';

/// Controller to programmatically close an open overlay menu.
///
/// Pass this to the `controller` parameter of [showOverlayMenu].
/// Call [close] to dismiss the menu. Safe to call even if already closed.
///
/// ```dart
/// final controller = OverlayMenuController();
/// showOverlayMenu(
///   context: context,
///   items: [...],
///   controller: controller,
/// );
///
/// // Later, when you want to close the menu:
/// controller.close();
/// ```
class OverlayMenuController {
  VoidCallback? _onClose;
  bool _isClosed = false;

  /// Whether the menu is already closed.
  bool get isClosed => _isClosed;

  /// Closes the menu. Safe to call even if already closed.
  void close() {
    if (_isClosed) return;
    _isClosed = true;
    _onClose?.call();
    _onClose = null;
  }
}

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
/// - [constraints] – Additional box constraints for the menu.
/// - [width] – Fixed width for the menu.
/// - [animationDuration] – Duration of the open/close animation.
/// - [animationCurve] – Curve of the open/close animation.
/// - [style] – Visual style options (colors, item sizes, scrollbar, etc.).
/// - [controller] – Optional controller for programmatic dismissal.
Future<T?> showOverlayMenu<T>({
  required BuildContext context,
  required List<OverlayMenuEntry<T>> items,
  List<OverlayMenuEntry<T>>? header,
  List<OverlayMenuEntry<T>>? footer,
  MenuPosition position = MenuPosition.bottom,
  MenuAlignment alignment = MenuAlignment.start,
  Offset offset = Offset.zero,
  bool barrierDismissible = true,
  Color? barrierColor,
  BoxDecoration? decoration,
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
  final completer = Completer<T?>();

  late OverlayEntry entry;
  bool removed = false;

  void removeEntry() {
    if (removed) return;
    removed = true;
    entry.remove();
  }

  void close([T? result]) {
    removeEntry();
    controller?._isClosed = true;
    controller?._onClose = null;
    if (!completer.isCompleted) {
      completer.complete(result);
    }
  }

  // Connect controller
  if (controller != null) {
    controller._isClosed = false;
    controller._onClose = () => close();
  }

  // Auto-close menu when the route is popped or a new route is pushed
  final route = ModalRoute.of(context);
  void onRouteStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.reverse) {
      close(); // Current route popped
    }
  }

  void onSecondaryStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.forward) {
      close(); // New route pushed
    }
  }

  if (route != null) {
    route.animation?.addStatusListener(onRouteStatusChanged);
    route.secondaryAnimation?.addStatusListener(onSecondaryStatusChanged);
    completer.future.whenComplete(() {
      try {
        route.animation?.removeStatusListener(onRouteStatusChanged);
        route.secondaryAnimation
            ?.removeStatusListener(onSecondaryStatusChanged);
      } catch (_) {
        // Ignore if the route is already disposed
      }
    });
  }

  entry = OverlayEntry(
    builder: (context) => _OverlayMenuWidget<T>(
      targetRect: targetRect,
      items: items,
      header: header,
      footer: footer,
      position: position,
      alignment: alignment,
      offset: offset,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      decoration: decoration,
      constraints: constraints,
      width: width,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      style: style,
      onClose: (result) {
        close(result);
      },
    ),
  );

  overlay.insert(entry);
  return completer.future;
}

class _OverlayMenuWidget<T> extends StatefulWidget {
  const _OverlayMenuWidget({
    required this.targetRect,
    required this.items,
    this.header,
    this.footer,
    required this.position,
    required this.alignment,
    required this.offset,
    required this.barrierDismissible,
    required this.onClose,
    this.barrierColor,
    this.decoration,
    this.constraints,
    this.width,
    required this.animationDuration,
    required this.animationCurve,
    this.style,
  });

  final Rect targetRect;
  final List<OverlayMenuEntry<T>> items;
  final List<OverlayMenuEntry<T>>? header;
  final List<OverlayMenuEntry<T>>? footer;
  final MenuPosition position;
  final MenuAlignment alignment;
  final Offset offset;
  final bool barrierDismissible;
  final Color? barrierColor;
  final BoxDecoration? decoration;
  final BoxConstraints? constraints;
  final double? width;
  final Duration animationDuration;
  final Curve animationCurve;
  final OverlayMenuStyle? style;
  final ValueChanged<T?> onClose;

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
      _jumpToSelectedItem();
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
  }

  void _jumpToSelectedItem() {
    final maxHeight = widget.style!.maxHeight!;
    final itemStyle = widget.style?.itemStyle;
    final ds = widget.style?.dividerStyle;

    double offset = 0;
    double? selectedOffset;
    double? selectedHeight;

    for (final entry in widget.items) {
      switch (entry) {
        case OverlayMenuItem<T>():
          final h = entry.height ?? itemStyle?.height ?? 48.0;
          if (entry.selected && selectedOffset == null) {
            selectedOffset = offset;
            selectedHeight = h;
          }
          offset += h;
        case OverlayMenuDivider<T>():
          final h = entry.thickness ?? ds?.thickness ?? 1.0;
          offset += h;
      }
    }

    if (selectedOffset == null) return;

    // Center the selected item in the viewport.
    final target = selectedOffset - (maxHeight / 2) + (selectedHeight! / 2);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController != null && _scrollController!.hasClients) {
        final max = _scrollController!.position.maxScrollExtent;
        _scrollController!.jumpTo(target.clamp(0.0, max));
      }
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool _dismissed = false;

  Future<void> _dismiss([T? result]) async {
    if (_dismissed) return;
    _dismissed = true;
    try {
      await _controller.reverse();
    } on TickerCanceled {
      // Entry was removed and disposed externally (controller / route pop)
      return;
    }
    widget.onClose(result);
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
            onTap: widget.barrierDismissible ? () => _dismiss() : null,
            child: ColoredBox(
              color: widget.barrierColor ?? Colors.transparent,
            ),
          ),
        ),

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

    Widget menu = Material(
      elevation: 8,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      color: bgColor,
      child: Padding(
        padding: style?.padding ?? const EdgeInsets.symmetric(vertical: 4),
        child: IntrinsicWidth(
          child: _buildScrollableBody(style?.maxHeight),
        ),
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

  Widget _buildScrollableBody(double? maxHeight) {
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
      return Column(
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
      );
    }

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: itemWidgets,
    );

    final sb = widget.style?.scrollbarStyle;
    final scrollView = SingleChildScrollView(
      controller: _scrollController,
      child: column,
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
          if (headerEntries != null)
            ...headerEntries
                .map((e) => _buildEntry(e, styleOverride: headerStyle)),
          Flexible(child: scrollable),
          if (footerEntries != null)
            ...footerEntries
                .map((e) => _buildEntry(e, styleOverride: footerStyle)),
        ],
      ),
    );
  }

  Widget _buildEntry(OverlayMenuEntry<T> entry,
      {OverlayMenuItemStyle? styleOverride}) {
    return switch (entry) {
      OverlayMenuItem<T>() => _buildItem(entry, styleOverride: styleOverride),
      OverlayMenuDivider<T>() => _buildDivider(entry),
    };
  }

  Widget _buildItem(OverlayMenuItem<T> item,
      {OverlayMenuItemStyle? styleOverride}) {
    final itemStyle = styleOverride ?? widget.style?.itemStyle;
    final selectedStyle = widget.style?.selectedStyle;
    final theme = Theme.of(context);
    final isSelected = item.selected;

    // Resolve: item → itemStyle → hardcoded default
    final height = item.height ?? itemStyle?.height ?? 48.0;
    final padding = item.padding ??
        itemStyle?.padding ??
        const EdgeInsets.symmetric(horizontal: 16);
    final baseTextStyle = itemStyle?.textStyle;
    final itemBorderRadius = itemStyle?.borderRadius;

    final mouseCursor = item.enabled
        ? (itemStyle?.mouseCursor ?? SystemMouseCursors.click)
        : SystemMouseCursors.basic;

    // Prefix
    final prefixBuilder = item.prefixBuilder ?? widget.style?.prefixBuilder;
    Widget content;
    if (prefixBuilder != null) {
      content = Row(
        children: [
          prefixBuilder(context, isSelected),
          const SizedBox(width: 12),
          Expanded(child: item.child),
        ],
      );
    } else {
      content = item.child;
    }

    // Text style
    TextStyle? resolvedTextStyle;
    if (isSelected && selectedStyle?.textStyle != null) {
      resolvedTextStyle =
          (baseTextStyle ?? const TextStyle()).merge(selectedStyle!.textStyle);
    } else if (baseTextStyle != null) {
      resolvedTextStyle = baseTextStyle;
    }
    if (!item.enabled) {
      resolvedTextStyle = (resolvedTextStyle ?? const TextStyle())
          .copyWith(color: theme.disabledColor);
    }

    Widget child = Container(
      height: height,
      padding: padding,
      alignment: Alignment.centerLeft,
      child: DefaultTextStyle.merge(
        style: resolvedTextStyle ?? const TextStyle(),
        child: content,
      ),
    );

    // Selected decoration
    if (isSelected) {
      child = Container(
        decoration: BoxDecoration(
          color: selectedStyle?.backgroundColor,
          borderRadius: itemBorderRadius,
          border: selectedStyle?.border != null
              ? Border.fromBorderSide(selectedStyle!.border!)
              : null,
        ),
        child: child,
      );
    }

    return InkWell(
      onTap: item.enabled
          ? () {
              item.onTap?.call();
              _dismiss(item.value);
            }
          : null,
      mouseCursor: mouseCursor,
      borderRadius: itemBorderRadius,
      hoverColor: itemStyle?.hoverColor,
      splashColor: itemStyle?.splashColor,
      highlightColor: itemStyle?.highlightColor,
      focusColor: itemStyle?.focusColor,
      child: child,
    );
  }

  Widget _buildDivider(OverlayMenuDivider<T> divider) {
    final ds = widget.style?.dividerStyle;
    return Divider(
      color: divider.color ?? ds?.color,
      thickness: divider.thickness ?? ds?.thickness ?? 1.0,
      indent: divider.indent ?? ds?.indent ?? 0,
      endIndent: divider.endIndent ?? ds?.endIndent ?? 0,
      height: divider.thickness ?? ds?.thickness ?? 1.0,
    );
  }
}
