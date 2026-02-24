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
  double _itemHeight = 48;
  double _animDuration = 150;
  int _itemCount = 4;
  bool _barrierDismissible = true;
  bool _showBarrierColor = false;
  bool _useCustomWidth = false;
  double _customWidth = 200;

  // Button config
  double _buttonWidth = 240;
  double _buttonHeight = 56;

  // Result
  String _lastResult = '-';

  List<OverlayMenuItem<String>> get _items => List.generate(
    _itemCount,
    (i) => OverlayMenuItem<String>(
      value: 'item_$i',
      height: _itemHeight,
      child: Row(
        children: [
          Icon(_demoIcons[i % _demoIcons.length], size: 20),
          const SizedBox(width: 12),
          Text('Menu Item ${i + 1}'),
        ],
      ),
    ),
  );

  static const _demoIcons = [
    Icons.edit_outlined,
    Icons.copy_outlined,
    Icons.share_outlined,
    Icons.delete_outlined,
    Icons.star_outlined,
    Icons.bookmark_outlined,
  ];

  Future<void> _showMenu(BuildContext context) async {
    final result = await showOverlayMenu<String>(
      context: context,
      items: _items,
      position: _position,
      alignment: _alignment,
      offset: Offset(_offsetX, _offsetY),
      barrierDismissible: _barrierDismissible,
      barrierColor: _showBarrierColor ? Colors.black26 : null,
      width: _useCustomWidth ? _customWidth : null,
      animationDuration: Duration(milliseconds: _animDuration.round()),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    );
    setState(() => _lastResult = result ?? 'dismissed');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OverlayMenu Playground'),
        actions: [
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

        // Menu Styling
        ExpansionTile(
          title: const Text('Menu Styling'),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          children: [
            _sliderRow(
              'Border Radius',
              _borderRadius,
              0,
              24,
              (v) => setState(() => _borderRadius = v),
            ),
            _sliderRow(
              'Item Height',
              _itemHeight,
              32,
              72,
              (v) => setState(() => _itemHeight = v),
            ),
            _sliderRow(
              'Item Count',
              _itemCount.toDouble(),
              1,
              6,
              (v) => setState(() => _itemCount = v.round()),
              divisions: 5,
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
