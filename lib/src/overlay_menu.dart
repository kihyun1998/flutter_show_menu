import 'package:flutter/material.dart';

import 'menu_position.dart';
import 'menu_position_delegate.dart';
import 'open_menu.dart';
import 'overlay_menu_barrier.dart';
import 'overlay_menu_entry_view.dart';
import 'overlay_menu_item.dart';
import 'overlay_menu_metrics.dart';
import 'overlay_menu_motion.dart';
import 'overlay_menu_placement.dart';
import 'overlay_menu_style.dart';

/// The box [showOverlayMenu] anchors an Open Menu to.
///
/// Checked rather than cast: the failure is a programming error, and the
/// caller needs to be told which context is wrong. The check runs in release
/// builds too — an unmounted context would otherwise yield a stale render
/// object there, opening the menu at the position of a widget that is gone.
RenderBox _anchorBoxOf(BuildContext context) {
  if (!context.mounted) {
    throw FlutterError(
      'showOverlayMenu was given a context that is no longer mounted.\n'
      'The menu is anchored to the box of the widget that owns `context`, so '
      'that widget must still be in the tree. This usually means the context '
      'was captured and used after an await, or after the widget was '
      'disposed. Check `context.mounted` before calling showOverlayMenu.',
    );
  }

  final renderObject = context.findRenderObject();
  if (renderObject is! RenderBox) {
    throw FlutterError(
      'showOverlayMenu was given a context with no RenderBox to anchor to.\n'
      'Its render object is ${renderObject.runtimeType}, not a RenderBox. The '
      '`context` passed to showOverlayMenu must belong to a box-laid-out '
      'widget; a context taken from above a sliver, for example, will not do. '
      'Wrap the anchor in a Builder that sits below any sliver and pass that '
      "Builder's context.",
    );
  }

  return renderObject;
}

/// Displays an OverlayEntry-based menu as a replacement for [showMenu].
///
/// Positions the menu relative to the [context]'s RenderBox according to
/// [placement].
///
/// Pass a [controller] to Close the menu from outside. The menu Closes
/// automatically when the owning route is pushed over or popped.
///
/// Parameters:
///
/// - [context] – Build context whose RenderBox is used as the anchor.
/// - [items] – Selectable entries displayed in the scrollable area.
/// - [header] – Entries pinned above the scrollable area.
/// - [footer] – Entries pinned below the scrollable area.
/// - [initialValue] – Value of the item to scroll to when the menu opens.
/// - [placement] – Where the menu sits relative to the target.
/// - [barrier] – The area behind the menu and how it behaves.
/// - [motion] – How the menu animates in and out.
/// - [style] – Colors, sizing, item styles, scrollbar.
/// - [controller] – Optional controller for programmatic Close.
Future<T?> showOverlayMenu<T>({
  required BuildContext context,
  required List<OverlayMenuEntry<T>> items,
  List<OverlayMenuEntry<T>>? header,
  List<OverlayMenuEntry<T>>? footer,
  T? initialValue,
  OverlayMenuPlacement placement = const OverlayMenuPlacement(),
  OverlayMenuBarrier barrier = const OverlayMenuBarrier(),
  OverlayMenuMotion motion = const OverlayMenuMotion(),
  OverlayMenuStyle? style,
  OverlayMenuController? controller,
}) {
  final renderBox = _anchorBoxOf(context);
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
      placement: placement,
      barrier: barrier,
      motion: motion,
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
    required this.placement,
    required this.barrier,
    required this.motion,
    this.style,
  });

  final OpenMenu<T> menu;
  final Rect targetRect;
  final List<OverlayMenuEntry<T>> items;
  final List<OverlayMenuEntry<T>>? header;
  final List<OverlayMenuEntry<T>>? footer;
  final T? initialValue;
  final OverlayMenuPlacement placement;
  final OverlayMenuBarrier barrier;
  final OverlayMenuMotion motion;
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
      duration: widget.motion.duration,
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: widget.motion.curve,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _scale = Tween<double>(begin: 0.9, end: 1).animate(curved);
    _controller.forward();

    // Tell the menu's lifetime that an exit animation is available. Until this
    // runs — and after dispose — an animated Close degrades to an instant one.
    widget.menu.attachExitAnimator(_playExit);
  }

  void _jumpToInitialValue() {
    // Deferred to the first frame: only then does the scroll position know how
    // tall the viewport really is. It is not `maxHeight` — the menu's padding
    // and any header or footer are pinned outside the scrollable area, and
    // centring against `maxHeight` would push the entry down by half of what
    // they occupy.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = _scrollController;
      if (controller == null || !controller.hasClients) return;

      final position = controller.position;
      final target = resolveScrollOffsetToValue<T>(
        entries: widget.items,
        initialValue: widget.initialValue,
        viewportHeight: position.viewportDimension,
        itemStyle: widget.style?.itemStyle,
        dividerStyle: widget.style?.dividerStyle,
      );
      if (target == null) return;

      controller.jumpTo(target.clamp(0.0, position.maxScrollExtent));
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
    return switch (widget.placement.position) {
      MenuPosition.bottom => switch (widget.placement.alignment) {
          MenuAlignment.start => Alignment.topLeft,
          MenuAlignment.center => Alignment.topCenter,
          MenuAlignment.end => Alignment.topRight,
        },
      MenuPosition.top => switch (widget.placement.alignment) {
          MenuAlignment.start => Alignment.bottomLeft,
          MenuAlignment.center => Alignment.bottomCenter,
          MenuAlignment.end => Alignment.bottomRight,
        },
      MenuPosition.left => switch (widget.placement.alignment) {
          MenuAlignment.start => Alignment.topRight,
          MenuAlignment.center => Alignment.centerRight,
          MenuAlignment.end => Alignment.bottomRight,
        },
      MenuPosition.right => switch (widget.placement.alignment) {
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
            onTap: widget.barrier.dismissible
                ? () => widget.menu.close(null, animated: true)
                : null,
            child: ColoredBox(
              color: widget.barrier.color ?? Colors.transparent,
            ),
          ),
        ),

        // Overlay child
        if (widget.barrier.overlayChild != null)
          Positioned.fill(child: widget.barrier.overlayChild!),

        // Menu
        CustomSingleChildLayout(
          delegate: MenuPositionDelegate(
            targetRect: widget.targetRect,
            position: widget.placement.position,
            alignment: widget.placement.alignment,
            screenSize: screenSize,
            offset: widget.placement.offset,
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

    if (style?.decoration != null) {
      menu = DecoratedBox(
        decoration: style!.decoration!,
        child: menu,
      );
    }

    if (style?.width != null) {
      menu = SizedBox(width: style!.width, child: menu);
    }

    if (style?.constraints != null) {
      menu = ConstrainedBox(
        constraints: style!.constraints!,
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
