import 'dart:async';
import 'package:flutter/material.dart';
import 'menu_position.dart';
import 'menu_position_delegate.dart';
import 'overlay_menu_item.dart';
import 'overlay_menu_style.dart';

/// [showMenu]를 대체하는 OverlayEntry 기반 메뉴를 표시합니다.
///
/// [context]의 RenderBox를 기준으로 [position] 방향, [alignment] 정렬에 따라
/// 메뉴를 배치합니다.
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
  EdgeInsets? padding,
  BoxConstraints? constraints,
  double? width,
  Duration animationDuration = const Duration(milliseconds: 150),
  Curve animationCurve = Curves.easeOutCubic,
  OverlayMenuStyle? style,
}) {
  final renderBox = context.findRenderObject() as RenderBox;
  final targetRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
  final overlay = Overlay.of(context);
  final completer = Completer<T?>();

  late OverlayEntry entry;

  void close([T? result]) {
    if (!completer.isCompleted) {
      completer.complete(result);
    }
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
      padding: padding,
      constraints: constraints,
      width: width,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      style: style,
      onClose: (result) {
        entry.remove();
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
    this.padding,
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
  final EdgeInsets? padding;
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

  Future<void> _dismiss([T? result]) async {
    await _controller.reverse();
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
        padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 4),
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
    final headerEntries = widget.header;
    final footerEntries = widget.footer;

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
