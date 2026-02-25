import 'package:flutter/material.dart';

import 'playground_page.dart';

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
