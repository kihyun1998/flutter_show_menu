import 'package:flutter/material.dart';
import 'package:flutter_show_menu/flutter_show_menu.dart';

import '../playground_page.dart';
import 'color_picker_row.dart';
import 'slider_row.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({
    super.key,
    required this.config,
    required this.onChanged,
    required this.seedColors,
    required this.seedColor,
    required this.onSeedColorChanged,
  });

  final PlaygroundConfig config;
  final VoidCallback onChanged;
  final Map<String, Color> seedColors;
  final Color seedColor;
  final ValueChanged<Color> onSeedColorChanged;

  void _update(VoidCallback fn) {
    fn();
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
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
              children: seedColors.entries.map((e) {
                final selected = seedColor == e.value;
                return FilterChip(
                  label: Text(e.key),
                  selected: selected,
                  onSelected: (_) => onSeedColorChanged(e.value),
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
              selected: {config.position},
              onSelectionChanged: (s) =>
                  _update(() => config.position = s.first),
            ),
            const SizedBox(height: 12),
            SegmentedButton<MenuAlignment>(
              segments: MenuAlignment.values
                  .map((a) => ButtonSegment(value: a, label: Text(a.name)))
                  .toList(),
              selected: {config.alignment},
              onSelectionChanged: (s) =>
                  _update(() => config.alignment = s.first),
            ),
            const SizedBox(height: 8),
            SliderRow(
              label: 'Offset X',
              value: config.offsetX,
              min: -40,
              max: 40,
              onChanged: (v) => _update(() => config.offsetX = v),
            ),
            SliderRow(
              label: 'Offset Y',
              value: config.offsetY,
              min: -40,
              max: 40,
              onChanged: (v) => _update(() => config.offsetY = v),
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
            SliderRow(
              label: 'Width',
              value: config.buttonWidth,
              min: 80,
              max: 400,
              onChanged: (v) => _update(() => config.buttonWidth = v),
            ),
            SliderRow(
              label: 'Height',
              value: config.buttonHeight,
              min: 32,
              max: 80,
              onChanged: (v) => _update(() => config.buttonHeight = v),
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
            ColorPickerRow(
              label: 'Background',
              current: config.backgroundColor,
              onChanged: (c) => _update(() => config.backgroundColor = c),
            ),
            const SizedBox(height: 8),
            SliderRow(
              label: 'Border Radius',
              value: config.borderRadius,
              min: 0,
              max: 24,
              onChanged: (v) => _update(() => config.borderRadius = v),
            ),
            SliderRow(
              label: 'Max Height',
              value: config.maxHeight,
              min: 0,
              max: 400,
              onChanged: (v) => _update(() => config.maxHeight = v),
            ),
            SliderRow(
              label: 'Padding H',
              value: config.menuPaddingH,
              min: 0,
              max: 16,
              onChanged: (v) => _update(() => config.menuPaddingH = v),
            ),
            SliderRow(
              label: 'Padding V',
              value: config.menuPaddingV,
              min: 0,
              max: 16,
              onChanged: (v) => _update(() => config.menuPaddingV = v),
            ),
            SliderRow(
              label: 'Item Count',
              value: config.itemCount.toDouble(),
              min: 0,
              max: 6,
              onChanged: (v) => _update(() => config.itemCount = v.round()),
              divisions: 6,
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              title: const Text('Custom Width'),
              dense: true,
              value: config.useCustomWidth,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => _update(() => config.useCustomWidth = v),
            ),
            if (config.useCustomWidth)
              SliderRow(
                label: 'Menu Width',
                value: config.customWidth,
                min: 120,
                max: 320,
                onChanged: (v) => _update(() => config.customWidth = v),
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
            SliderRow(
              label: 'Height',
              value: config.itemHeight,
              min: 32,
              max: 72,
              onChanged: (v) => _update(() => config.itemHeight = v),
            ),
            SliderRow(
              label: 'Border Radius',
              value: config.itemBorderRadius,
              min: 0,
              max: 24,
              onChanged: (v) => _update(() => config.itemBorderRadius = v),
            ),
            const SizedBox(height: 8),
            ColorPickerRow(
              label: 'Background',
              current: config.itemBackgroundColor,
              onChanged: (c) =>
                  _update(() => config.itemBackgroundColor = c),
            ),
            const SizedBox(height: 8),
            ColorPickerRow(
              label: 'Selected BG',
              current: config.selectedBackgroundColor,
              onChanged: (c) =>
                  _update(() => config.selectedBackgroundColor = c),
            ),
            const SizedBox(height: 8),
            ColorPickerRow(
              label: 'Hover',
              current: config.hoverColor,
              onChanged: (c) => _update(() => config.hoverColor = c),
            ),
            const SizedBox(height: 8),
            ColorPickerRow(
              label: 'Splash',
              current: config.splashColor,
              onChanged: (c) => _update(() => config.splashColor = c),
            ),
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
              value: config.showDividers,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => _update(() => config.showDividers = v),
            ),
            if (config.showDividers) ...[
              const SizedBox(height: 4),
              ColorPickerRow(
                label: 'Color',
                current: config.dividerColor,
                onChanged: (c) => _update(() => config.dividerColor = c),
              ),
              const SizedBox(height: 8),
              SliderRow(
                label: 'Height',
                value: config.dividerHeight,
                min: 1,
                max: 24,
                onChanged: (v) => _update(() => config.dividerHeight = v),
              ),
              SliderRow(
                label: 'Indent',
                value: config.dividerIndent,
                min: 0,
                max: 32,
                onChanged: (v) => _update(() => config.dividerIndent = v),
              ),
              SliderRow(
                label: 'End Indent',
                value: config.dividerEndIndent,
                min: 0,
                max: 32,
                onChanged: (v) =>
                    _update(() => config.dividerEndIndent = v),
              ),
            ],
          ],
        ),

        // Scrollbar Style
        if (config.maxHeight > 0)
          ExpansionTile(
            title: const Text('Scrollbar Style'),
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            children: [
              ColorPickerRow(
                label: 'Thumb Color',
                current: config.scrollbarColor,
                onChanged: (c) => _update(() => config.scrollbarColor = c),
              ),
              const SizedBox(height: 8),
              SliderRow(
                label: 'Thickness',
                value: config.scrollbarThickness,
                min: 2,
                max: 12,
                onChanged: (v) =>
                    _update(() => config.scrollbarThickness = v),
                divisions: 10,
              ),
              SliderRow(
                label: 'Radius',
                value: config.scrollbarRadius,
                min: 0,
                max: 12,
                onChanged: (v) =>
                    _update(() => config.scrollbarRadius = v),
              ),
              SwitchListTile(
                title: const Text('Always Visible'),
                dense: true,
                value: config.scrollbarAlwaysVisible,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) =>
                    _update(() => config.scrollbarAlwaysVisible = v),
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
              value: config.showHeader,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => _update(() => config.showHeader = v),
            ),
            if (config.showHeader) ...[
              SliderRow(
                label: 'Height',
                value: config.headerHeight,
                min: 32,
                max: 72,
                onChanged: (v) => _update(() => config.headerHeight = v),
              ),
              SliderRow(
                label: 'Border Radius',
                value: config.headerBorderRadius,
                min: 0,
                max: 24,
                onChanged: (v) =>
                    _update(() => config.headerBorderRadius = v),
              ),
              const SizedBox(height: 8),
              ColorPickerRow(
                label: 'Hover',
                current: config.headerHoverColor,
                onChanged: (c) =>
                    _update(() => config.headerHoverColor = c),
              ),
              const SizedBox(height: 8),
              ColorPickerRow(
                label: 'Splash',
                current: config.headerSplashColor,
                onChanged: (c) =>
                    _update(() => config.headerSplashColor = c),
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
              value: config.showFooter,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) => _update(() => config.showFooter = v),
            ),
            if (config.showFooter) ...[
              SliderRow(
                label: 'Height',
                value: config.footerHeight,
                min: 32,
                max: 72,
                onChanged: (v) => _update(() => config.footerHeight = v),
              ),
              SliderRow(
                label: 'Border Radius',
                value: config.footerBorderRadius,
                min: 0,
                max: 24,
                onChanged: (v) =>
                    _update(() => config.footerBorderRadius = v),
              ),
              const SizedBox(height: 8),
              ColorPickerRow(
                label: 'Hover',
                current: config.footerHoverColor,
                onChanged: (c) =>
                    _update(() => config.footerHoverColor = c),
              ),
              const SizedBox(height: 8),
              ColorPickerRow(
                label: 'Splash',
                current: config.footerSplashColor,
                onChanged: (c) =>
                    _update(() => config.footerSplashColor = c),
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
            SliderRow(
              label: 'Duration (ms)',
              value: config.animDuration,
              min: 0,
              max: 500,
              onChanged: (v) => _update(() => config.animDuration = v),
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
              value: config.barrierDismissible,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) =>
                  _update(() => config.barrierDismissible = v),
            ),
            SwitchListTile(
              title: const Text('Barrier Color'),
              dense: true,
              value: config.showBarrierColor,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) =>
                  _update(() => config.showBarrierColor = v),
            ),
            SwitchListTile(
              title: const Text('Overlay Child'),
              dense: true,
              value: config.showOverlayChild,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) =>
                  _update(() => config.showOverlayChild = v),
            ),
          ],
        ),
      ],
    );
  }
}
