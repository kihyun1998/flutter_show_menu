import 'package:flutter/material.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';

import 'widgets/control_panel.dart';
import 'widgets/preview_panel.dart';

class PlaygroundConfig {
  // Menu config
  MenuPosition position = MenuPosition.bottom;
  MenuAlignment alignment = MenuAlignment.start;
  double offsetX = 0;
  double offsetY = 0;
  double borderRadius = 8;
  double itemBorderRadius = 0;
  double itemHeight = 48;
  double menuPaddingH = 0;
  double menuPaddingV = 4;
  double maxHeight = 0; // 0 = no limit
  double animDuration = 150;
  int itemCount = 4;
  bool barrierDismissible = true;
  bool showBarrierColor = false;
  bool useCustomWidth = false;
  double customWidth = 200;

  // Style colors (null = disabled/default)
  Color? backgroundColor;
  Color? itemBackgroundColor;
  Color? selectedBackgroundColor;
  Color? hoverColor;
  Color? splashColor;
  Color? dividerColor;
  double dividerHeight = 1;
  double dividerIndent = 0;
  double dividerEndIndent = 0;
  Color? scrollbarColor;
  double scrollbarThickness = 4;
  double scrollbarRadius = 8;
  bool scrollbarAlwaysVisible = false;
  bool showDividers = false;
  bool showHeader = false;
  double headerHeight = 48;
  double headerBorderRadius = 0;
  Color? headerHoverColor;
  Color? headerSplashColor;

  bool showOverlayChild = false;

  bool showFooter = false;
  double footerHeight = 48;
  double footerBorderRadius = 0;
  Color? footerHoverColor;
  Color? footerSplashColor;

  // Button config
  double buttonWidth = 240;
  double buttonHeight = 56;

  // Result
  String lastResult = '-';
  String selectedItem = 'item_0';
}

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({
    super.key,
    required this.isDark,
    required this.seedColor,
    required this.seedColors,
    required this.onThemeToggle,
    required this.onSeedColorChanged,
  });

  final bool isDark;
  final Color seedColor;
  final Map<String, Color> seedColors;
  final VoidCallback onThemeToggle;
  final ValueChanged<Color> onSeedColorChanged;

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  final _config = PlaygroundConfig();

  static const _demoIcons = [
    Icons.edit_outlined,
    Icons.copy_outlined,
    Icons.share_outlined,
    Icons.delete_outlined,
    Icons.star_outlined,
    Icons.bookmark_outlined,
  ];

  String get _configSummary =>
      'position: ${_config.position.name}  |  '
      'alignment: ${_config.alignment.name}  |  '
      'offset: (${_config.offsetX.toStringAsFixed(0)}, ${_config.offsetY.toStringAsFixed(0)})  |  '
      'button: ${_config.buttonWidth.toStringAsFixed(0)}x${_config.buttonHeight.toStringAsFixed(0)}  |  '
      'last: ${_config.lastResult}';

  OverlayMenuStyle get _menuStyle {
    return OverlayMenuStyle(
      borderRadius: BorderRadius.circular(_config.borderRadius),
      padding: EdgeInsets.symmetric(
        horizontal: _config.menuPaddingH,
        vertical: _config.menuPaddingV,
      ),
      maxHeight: _config.maxHeight > 0 ? _config.maxHeight : null,
      backgroundColor: _config.backgroundColor,
      itemStyle: OverlayMenuItemStyle(
        height: _config.itemHeight,
        borderRadius: _config.itemBorderRadius > 0
            ? BorderRadius.circular(_config.itemBorderRadius)
            : null,
        backgroundColor: _config.itemBackgroundColor,
        selectedBackgroundColor: _config.selectedBackgroundColor,
        hoverColor: _config.hoverColor,
        splashColor: _config.splashColor,
      ),
      headerStyle: _config.showHeader
          ? OverlayMenuHeaderStyle(
              height: _config.headerHeight,
              borderRadius: _config.headerBorderRadius > 0
                  ? BorderRadius.circular(_config.headerBorderRadius)
                  : null,
              hoverColor: _config.headerHoverColor,
              splashColor: _config.headerSplashColor,
            )
          : null,
      footerStyle: _config.showFooter
          ? OverlayMenuFooterStyle(
              height: _config.footerHeight,
              borderRadius: _config.footerBorderRadius > 0
                  ? BorderRadius.circular(_config.footerBorderRadius)
                  : null,
              hoverColor: _config.footerHoverColor,
              splashColor: _config.footerSplashColor,
            )
          : null,
      dividerStyle: _config.showDividers
          ? OverlayMenuDividerStyle(
              color: _config.dividerColor,
              height: _config.dividerHeight,
              indent: _config.dividerIndent,
              endIndent: _config.dividerEndIndent,
            )
          : null,
      scrollbarStyle: _config.maxHeight > 0
          ? OverlayMenuScrollbarStyle(
              thumbColor: _config.scrollbarColor,
              thickness: _config.scrollbarThickness,
              radius: Radius.circular(_config.scrollbarRadius),
              thumbVisibility: _config.scrollbarAlwaysVisible,
            )
          : null,
    );
  }

  List<OverlayMenuEntry<String>> get _items {
    final cs = Theme.of(context).colorScheme;
    final entries = <OverlayMenuEntry<String>>[];
    for (var i = 0; i < _config.itemCount; i++) {
      if (_config.showDividers && i > 0) {
        entries.add(const OverlayMenuDivider<String>());
      }
      final isSelected = _config.selectedItem == 'item_$i';
      entries.add(
        OverlayMenuItem<String>(
          value: 'item_$i',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : _demoIcons[i % _demoIcons.length],
                  size: 20,
                  color: isSelected ? cs.primary : null,
                ),
                const SizedBox(width: 12),
                Text(
                  'Menu Item ${i + 1}',
                  style: isSelected
                      ? TextStyle(
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return entries;
  }

  List<OverlayMenuEntry<String>>? get _header {
    if (!_config.showHeader) return null;
    return [
      OverlayMenuItem<String>(
        value: 'search',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.search, size: 20),
              const SizedBox(width: 12),
              const Text('Search...'),
            ],
          ),
        ),
      ),
      const OverlayMenuDivider<String>(),
    ];
  }

  List<OverlayMenuEntry<String>>? get _footer {
    if (!_config.showFooter) return null;
    return [
      const OverlayMenuDivider<String>(),
      OverlayMenuItem<String>(
        value: 'create_new',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.add_circle_outline, size: 20),
              const SizedBox(width: 12),
              const Text('Create New'),
            ],
          ),
        ),
      ),
    ];
  }

  void _testAutoClose(BuildContext context) {
    showOverlayMenu<String>(
      context: context,
      items: _items,
      initialValue: _config.selectedItem,
      position: MenuPosition.bottom,
      alignment: MenuAlignment.end,
      style: _menuStyle,
    ).then((result) {
      debugPrint('menu closed with: $result');
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!context.mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Test Page')),
            body: const Center(child: Text('Page pushed after 3 seconds')),
          ),
        ),
      );
    });
  }

  Future<void> _showMenu(BuildContext context) async {
    final result = await showOverlayMenu<String>(
      context: context,
      items: _items,
      header: _header,
      footer: _footer,
      initialValue: _config.selectedItem,
      position: _config.position,
      alignment: _config.alignment,
      offset: Offset(_config.offsetX, _config.offsetY),
      barrierDismissible: _config.barrierDismissible,
      barrierColor: _config.showBarrierColor ? Colors.black26 : null,
      width: _config.useCustomWidth ? _config.customWidth : null,
      animationDuration:
          Duration(milliseconds: _config.animDuration.round()),
      style: _menuStyle,
      overlayChild: _config.showOverlayChild
          ? Column(
              children: [
                GestureDetector(
                  onTap: () => debugPrint('overlayChild tapped!'),
                  child: Container(
                    height: 40,
                    color: Colors.blue.withValues(alpha: 0.15),
                    alignment: Alignment.center,
                    child: const Text(
                      'overlayChild area',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ),
                Expanded(
                  child: IgnorePointer(ignoring: true, child: Container()),
                ),
              ],
            )
          : null,
    );
    setState(() {
      _config.lastResult = result ?? 'dismissed';
      if (result != null) _config.selectedItem = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OverlayMenu Playground'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.navigate_next),
              tooltip: 'Open menu → push page after 3s',
              onPressed: () => _testAutoClose(context),
            ),
          ),
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 320,
            child: ControlPanel(
              config: _config,
              onChanged: () => setState(() {}),
              seedColors: widget.seedColors,
              seedColor: widget.seedColor,
              onSeedColorChanged: widget.onSeedColorChanged,
            ),
          ),
          VerticalDivider(width: 1, color: cs.outlineVariant),
          Expanded(
            child: PreviewPanel(
              configSummary: _configSummary,
              buttonWidth: _config.buttonWidth,
              buttonHeight: _config.buttonHeight,
              onShowMenu: _showMenu,
            ),
          ),
        ],
      ),
    );
  }
}
