import 'package:flutter/material.dart';

const defaultPalette = <Color>[
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

class ColorPickerRow extends StatelessWidget {
  const ColorPickerRow({
    super.key,
    required this.label,
    required this.current,
    required this.onChanged,
    this.palette = defaultPalette,
  });

  final String label;
  final Color? current;
  final ValueChanged<Color?> onChanged;
  final List<Color> palette;

  @override
  Widget build(BuildContext context) {
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
          children: palette.map((color) {
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
}
