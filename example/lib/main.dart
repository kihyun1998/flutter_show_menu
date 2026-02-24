import 'package:flutter/material.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';

void main() {
  runApp(const PlaygroundApp());
}

class PlaygroundApp extends StatefulWidget {
  const PlaygroundApp({super.key});

  @override
  State<PlaygroundApp> createState() => _PlaygroundAppState();
}

class _PlaygroundAppState extends State<PlaygroundApp> {
  bool _isDark = false;
  Color _seedColor = Colors.deepPurple;

  static const _seedColors = {
    'Deep Purple': Colors.deepPurple,
    'Blue': Colors.blue,
    'Teal': Colors.teal,
    'Orange': Colors.orange,
    'Pink': Colors.pink,
    'Green': Colors.green,
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OverlayMenu Playground',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
      ),
      home: PlaygroundPage(
        isDark: _isDark,
        seedColor: _seedColor,
        seedColors: _seedColors,
        onThemeToggle: () => setState(() => _isDark = !_isDark),
        onSeedColorChanged: (c) => setState(() => _seedColor = c),
      ),
    );
  }
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
  // Menu config
  MenuPosition _position = MenuPosition.bottom;
  MenuAlignment _alignment = MenuAlignment.start;
  double _offsetX = 0;
  double _offsetY = 0;
  double _borderRadius = 8;
  double _itemBorderRadius = 0;
  double _itemHeight = 48;
  double _itemPaddingH = 16;
  double _itemPaddingV = 0;
  double _menuPaddingH = 0;
  double _menuPaddingV = 4;
  double _maxHeight = 0; // 0 = no limit
  double _selectedBorderWidth = 0;
  double _animDuration = 150;
  int _itemCount = 4;
  bool _barrierDismissible = true;
  bool _showBarrierColor = false;
  bool _useCustomWidth = false;
  double _customWidth = 200;

  // Style colors (null = disabled/default)
  Color? _backgroundColor;
  Color? _hoverColor;
  Color? _splashColor;
  Color? _selectedBgColor;
  Color? _selectedTextColor;
  Color? _dividerColor;
  double _dividerHeight = 1;
  double _dividerIndent = 0;
  double _dividerEndIndent = 0;
  Color? _scrollbarColor;
  double _scrollbarThickness = 4;
  double _scrollbarRadius = 8;
  bool _scrollbarAlwaysVisible = false;
  bool _showSelectedState = false;
  bool _showPrefixIcons = false;
  double _prefixSpacing = 12;
  bool _showDividers = false;
  bool _showHeader = false;
  double _headerHeight = 48;
  double _headerPaddingH = 16;
  double _headerPaddingV = 0;
  double _headerBorderRadius = 0;
  Color? _headerHoverColor;
  Color? _headerSplashColor;

  bool _showOverlayChild = false;

  bool _showFooter = false;
  double _footerHeight = 48;
  double _footerPaddingH = 16;
  double _footerPaddingV = 0;
  double _footerBorderRadius = 0;
  Color? _footerHoverColor;
  Color? _footerSplashColor;

  // Button config
  double _buttonWidth = 240;
  double _buttonHeight = 56;

  // Result
  String _lastResult = '-';
  String _selectedItem = 'item_0';

  static const _palette = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  static const _demoIcons = [
    Icons.edit_outlined,
    Icons.copy_outlined,
    Icons.share_outlined,
    Icons.delete_outlined,
    Icons.star_outlined,
    Icons.bookmark_outlined,
  ];

  OverlayMenuStyle get _menuStyle {
    final selColor = _selectedTextColor ?? Colors.deepPurple;
    return OverlayMenuStyle(
      borderRadius: BorderRadius.circular(_borderRadius),
      padding: EdgeInsets.symmetric(
        horizontal: _menuPaddingH,
        vertical: _menuPaddingV,
      ),
      maxHeight: _maxHeight > 0 ? _maxHeight : null,
      backgroundColor: _backgroundColor,
      itemStyle: OverlayMenuItemStyle(
        height: _itemHeight,
        padding: EdgeInsets.symmetric(
          horizontal: _itemPaddingH,
          vertical: _itemPaddingV,
        ),
        borderRadius: _itemBorderRadius > 0
            ? BorderRadius.circular(_itemBorderRadius)
            : null,
        hoverColor: _hoverColor,
        splashColor: _splashColor,
      ),
      headerStyle: _showHeader
          ? OverlayMenuHeaderStyle(
              height: _headerHeight,
              padding: EdgeInsets.symmetric(
                horizontal: _headerPaddingH,
                vertical: _headerPaddingV,
              ),
              borderRadius: _headerBorderRadius > 0
                  ? BorderRadius.circular(_headerBorderRadius)
                  : null,
              hoverColor: _headerHoverColor,
              splashColor: _headerSplashColor,
            )
          : null,
      footerStyle: _showFooter
          ? OverlayMenuFooterStyle(
              height: _footerHeight,
              padding: EdgeInsets.symmetric(
                horizontal: _footerPaddingH,
                vertical: _footerPaddingV,
              ),
              borderRadius: _footerBorderRadius > 0
                  ? BorderRadius.circular(_footerBorderRadius)
                  : null,
              hoverColor: _footerHoverColor,
              splashColor: _footerSplashColor,
            )
          : null,
      selectedStyle: _showSelectedState
          ? OverlayMenuSelectedStyle(
              backgroundColor: _selectedBgColor,
              textStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: selColor,
              ),
              border: _selectedBorderWidth > 0
                  ? BorderSide(color: selColor, width: _selectedBorderWidth)
                  : null,
            )
          : null,
      dividerStyle: _showDividers
          ? OverlayMenuDividerStyle(
              color: _dividerColor,
              height: _dividerHeight,
              indent: _dividerIndent,
              endIndent: _dividerEndIndent,
            )
          : null,
      scrollbarStyle: _maxHeight > 0
          ? OverlayMenuScrollbarStyle(
              thumbColor: _scrollbarColor,
              thickness: _scrollbarThickness,
              radius: Radius.circular(_scrollbarRadius),
              thumbVisibility: _scrollbarAlwaysVisible,
            )
          : null,
      prefixBuilder: _showPrefixIcons
          ? (context, selected) => Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color: selected ? selColor : null,
            )
          : null,
      prefixSpacing: _showPrefixIcons ? _prefixSpacing : null,
    );
  }

  List<OverlayMenuEntry<String>> get _items {
    final entries = <OverlayMenuEntry<String>>[];
    for (var i = 0; i < _itemCount; i++) {
      if (_showDividers && i > 0) {
        entries.add(const OverlayMenuDivider<String>());
      }
      entries.add(
        OverlayMenuItem<String>(
          value: 'item_$i',
          selected: _showSelectedState && _selectedItem == 'item_$i',
          child: Row(
            children: [
              if (!_showPrefixIcons) ...[
                Icon(_demoIcons[i % _demoIcons.length], size: 20),
                const SizedBox(width: 12),
              ],
              Text('Menu Item ${i + 1}'),
            ],
          ),
        ),
      );
    }
    return entries;
  }

  List<OverlayMenuEntry<String>>? get _header {
    if (!_showHeader) return null;
    return [
      OverlayMenuItem<String>(
        value: 'search',
        child: Row(
          children: [
            const Icon(Icons.search, size: 20),
            const SizedBox(width: 12),
            const Text('Search...'),
          ],
        ),
      ),
      const OverlayMenuDivider<String>(),
    ];
  }

  List<OverlayMenuEntry<String>>? get _footer {
    if (!_showFooter) return null;
    return [
      const OverlayMenuDivider<String>(),
      OverlayMenuItem<String>(
        value: 'create_new',
        child: Row(
          children: [
            const Icon(Icons.add_circle_outline, size: 20),
            const SizedBox(width: 12),
            const Text('Create New'),
          ],
        ),
      ),
    ];
  }

  void _testAutoClose(BuildContext context) {
    // Open the menu and receive the result asynchronously
    showOverlayMenu<String>(
      context: context,
      items: _items,
      position: MenuPosition.bottom,
      alignment: MenuAlignment.end,
      style: _menuStyle,
    ).then((result) {
      debugPrint('menu closed with: $result');
    });

    // Push another page after 3 seconds → menu should auto-close if still open
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
      position: _position,
      alignment: _alignment,
      offset: Offset(_offsetX, _offsetY),
      barrierDismissible: _barrierDismissible,
      barrierColor: _showBarrierColor ? Colors.black26 : null,
      width: _useCustomWidth ? _customWidth : null,
      animationDuration: Duration(milliseconds: _animDuration.round()),
      style: _menuStyle,
      overlayChild: _showOverlayChild
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
      _lastResult = result ?? 'dismissed';
      if (result != null) _selectedItem = result;
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
          // Left: Controls
          SizedBox(width: 320, child: _buildControlPanel(cs)),

          VerticalDivider(width: 1, color: cs.outlineVariant),

          // Right: Preview
          Expanded(child: _buildPreview(cs)),
        ],
      ),
    );
  }

  Widget _buildControlPanel(ColorScheme cs) {
    return ListView(
      children: [
        // Theme
        ExpansionTile(
          title: const Text('Theme'),
          initiallyExpanded: true,
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.seedColors.entries.map((e) {
                final selected = widget.seedColor == e.value;
                return FilterChip(
                  label: Text(e.key),
                  selected: selected,
                  onSelected: (_) => widget.onSeedColorChanged(e.value),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
          ],
        ),

        // Position & Alignment
        ExpansionTile(
          title: const Text('Position & Alignment'),
          initiallyExpanded: true,
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: [
            SegmentedButton<MenuPosition>(
              segments: MenuPosition.values
                  .map((p) => ButtonSegment(value: p, label: Text(p.name)))
                  .toList(),
              selected: {_position},
              onSelectionChanged: (s) => setState(() => _position = s.first),
            ),
            const SizedBox(height: 12),
            SegmentedButton<MenuAlignment>(
              segments: MenuAlignment.values
                  .map((a) => ButtonSegment(value: a, label: Text(a.name)))
                  .toList(),
              selected: {_alignment},
              onSelectionChanged: (s) => setState(() => _alignment = s.first),
            ),
            const SizedBox(height: 8),
            _sliderRow(
              'Offset X',
              _offsetX,
              -40,
              40,
              (v) => setState(() => _offsetX = v),
            ),
            _sliderRow(
              'Offset Y',
              _offsetY,
              -40,
              40,
              (v) => setState(() => _offsetY = v),
            ),
          ],
        ),

        // Target Button
        ExpansionTile(
          title: const Text('Target Button'),
          initiallyExpanded: true,
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: [
            _sliderRow(
              'Width',
              _buttonWidth,
              80,
              400,
              (v) => setState(() => _buttonWidth = v),
            ),
            _sliderRow(
              'Height',
              _buttonHeight,
              32,
              80,
              (v) => setState(() => _buttonHeight = v),
            ),
          ],
        ),

        // Menu Container
        ExpansionTile(
          title: const Text('Menu Container'),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: [
            _colorPickerRow(
              'Background',
              _backgroundColor,
              (c) => setState(() => _backgroundColor = c),
            ),
            const SizedBox(height: 8),
            _sliderRow(
              'Border Radius',
              _borderRadius,
              0,
              24,
              (v) => setState(() => _borderRadius = v),
            ),
            _sliderRow(
              'Max Height',
              _maxHeight,
              0,
              400,
              (v) => setState(() => _maxHeight = v),
            ),
            _sliderRow(
              'Padding H',
              _menuPaddingH,
              0,
              16,
              (v) => setState(() => _menuPaddingH = v),
            ),
            _sliderRow(
              'Padding V',
              _menuPaddingV,
              0,
              16,
              (v) => setState(() => _menuPaddingV = v),
            ),
            _sliderRow(
              'Item Count',
              _itemCount.toDouble(),
              0,
              6,
              (v) => setState(() => _itemCount = v.round()),
              divisions: 6,
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              title: const Text('Custom Width'),
              dense: true,
              value: _useCustomWidth,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _useCustomWidth = v),
            ),
            if (_useCustomWidth)
              _sliderRow(
                'Menu Width',
                _customWidth,
                120,
                320,
                (v) => setState(() => _customWidth = v),
              ),
          ],
        ),

        // Item Style
        ExpansionTile(
          title: const Text('Item Style'),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: [
            _sliderRow(
              'Height',
              _itemHeight,
              32,
              72,
              (v) => setState(() => _itemHeight = v),
            ),
            _sliderRow(
              'Padding H',
              _itemPaddingH,
              0,
              32,
              (v) => setState(() => _itemPaddingH = v),
            ),
            _sliderRow(
              'Padding V',
              _itemPaddingV,
              0,
              16,
              (v) => setState(() => _itemPaddingV = v),
            ),
            _sliderRow(
              'Border Radius',
              _itemBorderRadius,
              0,
              24,
              (v) => setState(() => _itemBorderRadius = v),
            ),
            const SizedBox(height: 8),
            _colorPickerRow(
              'Hover',
              _hoverColor,
              (c) => setState(() => _hoverColor = c),
            ),
            const SizedBox(height: 8),
            _colorPickerRow(
              'Splash',
              _splashColor,
              (c) => setState(() => _splashColor = c),
            ),
          ],
        ),

        // Selected Style
        ExpansionTile(
          title: const Text('Selected Style'),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: [
            SwitchListTile(
              title: const Text('Enable'),
              dense: true,
              value: _showSelectedState,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _showSelectedState = v),
            ),
            if (_showSelectedState) ...[
              const SizedBox(height: 4),
              _colorPickerRow(
                'Background',
                _selectedBgColor,
                (c) => setState(() => _selectedBgColor = c),
              ),
              const SizedBox(height: 8),
              _colorPickerRow(
                'Text Color',
                _selectedTextColor,
                (c) => setState(() => _selectedTextColor = c),
              ),
              const SizedBox(height: 8),
              _sliderRow(
                'Border Width',
                _selectedBorderWidth,
                0,
                4,
                (v) => setState(() => _selectedBorderWidth = v),
                divisions: 8,
              ),
            ],
          ],
        ),

        // Divider Style
        ExpansionTile(
          title: const Text('Divider Style'),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: [
            SwitchListTile(
              title: const Text('Enable'),
              dense: true,
              value: _showDividers,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _showDividers = v),
            ),
            if (_showDividers) ...[
              const SizedBox(height: 4),
              _colorPickerRow(
                'Color',
                _dividerColor,
                (c) => setState(() => _dividerColor = c),
              ),
              const SizedBox(height: 8),
              _sliderRow(
                'Height',
                _dividerHeight,
                1,
                24,
                (v) => setState(() => _dividerHeight = v),
              ),
              _sliderRow(
                'Indent',
                _dividerIndent,
                0,
                32,
                (v) => setState(() => _dividerIndent = v),
              ),
              _sliderRow(
                'End Indent',
                _dividerEndIndent,
                0,
                32,
                (v) => setState(() => _dividerEndIndent = v),
              ),
            ],
          ],
        ),

        // Scrollbar Style
        if (_maxHeight > 0)
          ExpansionTile(
            title: const Text('Scrollbar Style'),
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            children: [
              _colorPickerRow(
                'Thumb Color',
                _scrollbarColor,
                (c) => setState(() => _scrollbarColor = c),
              ),
              const SizedBox(height: 8),
              _sliderRow(
                'Thickness',
                _scrollbarThickness,
                2,
                12,
                (v) => setState(() => _scrollbarThickness = v),
                divisions: 10,
              ),
              _sliderRow(
                'Radius',
                _scrollbarRadius,
                0,
                12,
                (v) => setState(() => _scrollbarRadius = v),
              ),
              SwitchListTile(
                title: const Text('Always Visible'),
                dense: true,
                value: _scrollbarAlwaysVisible,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _scrollbarAlwaysVisible = v),
              ),
            ],
          ),

        // Prefix Builder
        ExpansionTile(
          title: const Text('Prefix Builder'),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: [
            SwitchListTile(
              title: const Text('Enable'),
              dense: true,
              value: _showPrefixIcons,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _showPrefixIcons = v),
            ),
            if (_showPrefixIcons)
              _sliderRow(
                'Spacing',
                _prefixSpacing,
                0,
                24,
                (v) => setState(() => _prefixSpacing = v),
              ),
          ],
        ),

        // Header Style
        ExpansionTile(
          title: const Text('Header Style'),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: [
            SwitchListTile(
              title: const Text('Enable'),
              dense: true,
              value: _showHeader,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _showHeader = v),
            ),
            if (_showHeader) ...[
              _sliderRow(
                'Height',
                _headerHeight,
                32,
                72,
                (v) => setState(() => _headerHeight = v),
              ),
              _sliderRow(
                'Padding H',
                _headerPaddingH,
                0,
                32,
                (v) => setState(() => _headerPaddingH = v),
              ),
              _sliderRow(
                'Padding V',
                _headerPaddingV,
                0,
                16,
                (v) => setState(() => _headerPaddingV = v),
              ),
              _sliderRow(
                'Border Radius',
                _headerBorderRadius,
                0,
                24,
                (v) => setState(() => _headerBorderRadius = v),
              ),
              const SizedBox(height: 8),
              _colorPickerRow(
                'Hover',
                _headerHoverColor,
                (c) => setState(() => _headerHoverColor = c),
              ),
              const SizedBox(height: 8),
              _colorPickerRow(
                'Splash',
                _headerSplashColor,
                (c) => setState(() => _headerSplashColor = c),
              ),
            ],
          ],
        ),

        // Footer Style
        ExpansionTile(
          title: const Text('Footer Style'),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: [
            SwitchListTile(
              title: const Text('Enable'),
              dense: true,
              value: _showFooter,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _showFooter = v),
            ),
            if (_showFooter) ...[
              _sliderRow(
                'Height',
                _footerHeight,
                32,
                72,
                (v) => setState(() => _footerHeight = v),
              ),
              _sliderRow(
                'Padding H',
                _footerPaddingH,
                0,
                32,
                (v) => setState(() => _footerPaddingH = v),
              ),
              _sliderRow(
                'Padding V',
                _footerPaddingV,
                0,
                16,
                (v) => setState(() => _footerPaddingV = v),
              ),
              _sliderRow(
                'Border Radius',
                _footerBorderRadius,
                0,
                24,
                (v) => setState(() => _footerBorderRadius = v),
              ),
              const SizedBox(height: 8),
              _colorPickerRow(
                'Hover',
                _footerHoverColor,
                (c) => setState(() => _footerHoverColor = c),
              ),
              const SizedBox(height: 8),
              _colorPickerRow(
                'Splash',
                _footerSplashColor,
                (c) => setState(() => _footerSplashColor = c),
              ),
            ],
          ],
        ),

        // Animation
        ExpansionTile(
          title: const Text('Animation'),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: [
            _sliderRow(
              'Duration (ms)',
              _animDuration,
              0,
              500,
              (v) => setState(() => _animDuration = v),
            ),
          ],
        ),

        // Barrier
        ExpansionTile(
          title: const Text('Barrier'),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: [
            SwitchListTile(
              title: const Text('Dismissible'),
              dense: true,
              value: _barrierDismissible,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _barrierDismissible = v),
            ),
            SwitchListTile(
              title: const Text('Barrier Color'),
              dense: true,
              value: _showBarrierColor,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _showBarrierColor = v),
            ),
            SwitchListTile(
              title: const Text('Overlay Child'),
              dense: true,
              value: _showOverlayChild,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => setState(() => _showOverlayChild = v),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreview(ColorScheme cs) {
    return Column(
      children: [
        // Config summary
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: cs.surfaceContainerHighest,
          child: Text(
            'position: ${_position.name}  |  '
            'alignment: ${_alignment.name}  |  '
            'offset: (${_offsetX.toStringAsFixed(0)}, ${_offsetY.toStringAsFixed(0)})  |  '
            'button: ${_buttonWidth.toStringAsFixed(0)}x${_buttonHeight.toStringAsFixed(0)}  |  '
            'last: $_lastResult',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),

        // Preview area
        Expanded(
          child: Center(
            child: Builder(
              builder: (context) => SizedBox(
                width: _buttonWidth,
                height: _buttonHeight,
                child: FilledButton.icon(
                  onPressed: () => _showMenu(context),
                  icon: const Icon(Icons.touch_app_outlined),
                  label: const Text('Show Menu'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _colorPickerRow(
    String label,
    Color? current,
    ValueChanged<Color?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(label, style: const TextStyle(fontSize: 13)),
            ),
            if (current != null) ...[
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: current,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black26),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (current != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: const Icon(Icons.close, size: 16),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _palette.map((color) {
            final isSelected = current?.toARGB32() == color.toARGB32();
            return GestureDetector(
              onTap: () => onChanged(color),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                  boxShadow: isSelected
                      ? [BoxShadow(color: color, blurRadius: 4)]
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _sliderRow(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    int? divisions,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(label, style: const TextStyle(fontSize: 13)),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions ?? (max - min).round(),
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value.toStringAsFixed(0),
            style: const TextStyle(fontSize: 13, fontFamily: 'monospace'),
          ),
        ),
      ],
    );
  }
}
