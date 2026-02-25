import 'package:flutter/material.dart';

class PreviewPanel extends StatelessWidget {
  const PreviewPanel({
    super.key,
    required this.configSummary,
    required this.buttonWidth,
    required this.buttonHeight,
    required this.onShowMenu,
  });

  final String configSummary;
  final double buttonWidth;
  final double buttonHeight;
  final void Function(BuildContext context) onShowMenu;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          color: cs.surfaceContainerHighest,
          child: Text(
            configSummary,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Builder(
              builder: (context) => SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: FilledButton.icon(
                  onPressed: () => onShowMenu(context),
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
}
