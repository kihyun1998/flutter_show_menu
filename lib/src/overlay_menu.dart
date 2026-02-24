import 'dart:async';
import 'package:flutter/material.dart';
import 'menu_position.dart';
import 'menu_position_delegate.dart';
import 'overlay_menu_item.dart';

/// [showMenu]를 대체하는 OverlayEntry 기반 메뉴를 표시합니다.
///
/// [context]의 RenderBox를 기준으로 [position] 방향, [alignment] 정렬에 따라
/// 메뉴를 배치합니다.
Future<T?> showOverlayMenu<T>({
  required BuildContext context,
  required List<OverlayMenuItem<T>> items,
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
  });

  final Rect targetRect;
  final List<OverlayMenuItem<T>> items;
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
  final ValueChanged<T?> onClose;

  @override
  State<_OverlayMenuWidget<T>> createState() => _OverlayMenuWidgetState<T>();
}

class _OverlayMenuWidgetState<T> extends State<_OverlayMenuWidget<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
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

    Widget menu = Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 4),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widget.items.map((item) => _buildItem(item)).toList(),
          ),
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

  Widget _buildItem(OverlayMenuItem<T> item) {
    return InkWell(
      onTap: item.enabled
          ? () {
              item.onTap?.call();
              _dismiss(item.value);
            }
          : null,
      child: Container(
        height: item.height,
        padding:
            item.padding ?? const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: item.enabled ? null : Theme.of(context).disabledColor,
          ),
          child: item.child,
        ),
      ),
    );
  }
}
