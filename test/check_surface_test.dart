import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/check_surface.dart';

/// Every name the barrel makes public. Adding, removing or renaming one is an
/// API decision, so it has to show up here; see
/// `docs/adr/0007-pin-the-public-names-the-barrel-exports.md`.
const _publicNames = {
  'MenuAlignment',
  'MenuPosition',
  'OverlayMenuBarrier',
  'OverlayMenuButton',
  'OverlayMenuController',
  'OverlayMenuDivider',
  'OverlayMenuDividerStyle',
  'OverlayMenuEntry',
  'OverlayMenuFooterStyle',
  'OverlayMenuHeaderStyle',
  'OverlayMenuItem',
  'OverlayMenuItemStyle',
  'OverlayMenuMotion',
  'OverlayMenuPlacement',
  'OverlayMenuScrollbarStyle',
  'OverlayMenuStyle',
  'closeAllOverlayMenus',
  'showOverlayMenu',
};

late Directory _repo;

void _write(String path, String content) {
  File('${_repo.path}/$path')
    ..createSync(recursive: true)
    ..writeAsStringSync(content);
}

({Set<String> names, List<String> findings}) _scan() {
  final scan = scanSurface(repoRoot: _repo.path);
  return (
    names: scan.names,
    findings: scan.findings.map((f) => f.toString()).toList(),
  );
}

/// The scan finds [names] and nothing wrong.
void _expectNames(Set<String> names) {
  final scan = _scan();
  expect(scan.findings, isEmpty);
  expect(scan.names, names);
}

void main() {
  test('the barrel exports exactly the pinned public names', () {
    final scan = scanSurface(repoRoot: Directory.current.path);
    expect(scan.findings, isEmpty);
    expect(scan.names, _publicNames);
  });

  group('scanSurface', () {
    setUp(() => _repo = Directory.systemTemp.createTempSync('check_surface_'));
    tearDown(() => _repo.deleteSync(recursive: true));

    test('a whole-file export contributes every public declaration', () {
      _write('lib/flutter_show_menu.dart', "export 'src/a.dart';\n");
      _write(
        'lib/src/a.dart',
        "import 'b.dart';\n"
            '\n'
            '/// Docs.\n'
            '@immutable\n'
            'sealed class Entry<T> {\n'
            '  const Entry();\n'
            '}\n'
            'abstract final class Tokens {}\n'
            'enum Side { top }\n'
            'mixin Tap {}\n'
            'typedef Alias = Entry<int>;\n'
            'extension Ext on int {}\n'
            'extension on String {}\n'
            'extension type Id(int value) {}\n'
            'const limit = 3;\n'
            'final Map<String, int> table = {};\n'
            'void run(int x) {}\n'
            'Future<void> later() async {}\n'
            'int get count => 0;\n'
            'class _Hidden {}\n'
            'void _helper() {}\n',
      );
      _expectNames({
        'Entry',
        'Tokens',
        'Side',
        'Tap',
        'Alias',
        'Ext',
        'Id',
        'limit',
        'table',
        'run',
        'later',
        'count',
      });
    });

    test('a show export contributes only the shown names', () {
      _write(
        'lib/flutter_show_menu.dart',
        "export 'src/a.dart'\n    show Alpha,\n        beta;\n",
      );
      _write(
          'lib/src/a.dart', 'class Alpha {}\nvoid beta() {}\nclass Gamma {}\n');
      _expectNames({'Alpha', 'beta'});
    });

    test('a declaration in the barrel itself is public too', () {
      _write(
        'lib/flutter_show_menu.dart',
        "/// Docs.\nlibrary;\n\nexport 'src/a.dart';\n\nclass Extra {}\n",
      );
      _write('lib/src/a.dart', 'class Alpha {}\n');
      _expectNames({'Alpha', 'Extra'});
    });

    test('a top-level line it cannot read fails at its line', () {
      _write('lib/flutter_show_menu.dart', "export 'src/a.dart';\n");
      _write('lib/src/a.dart', 'class Alpha {}\nr"""\n');
      expect(_scan().findings, [
        'lib/src/a.dart:2: unrecognised top-level line: r"""',
      ]);
    });

    test('a part file fails rather than going unread', () {
      _write('lib/flutter_show_menu.dart', "export 'src/a.dart';\n");
      _write('lib/src/a.dart', "part 'a_part.dart';\nclass Alpha {}\n");
      expect(_scan().findings, [contains('lib/src/a.dart:1: ')]);
    });

    test('an export inside an exported file fails rather than going unread',
        () {
      _write('lib/flutter_show_menu.dart', "export 'src/a.dart';\n");
      _write('lib/src/a.dart', "export 'b.dart';\nclass Alpha {}\n");
      expect(_scan().findings, [contains('lib/src/a.dart:1: ')]);
    });

    test('an exported file that does not exist fails', () {
      _write('lib/flutter_show_menu.dart', "export 'src/gone.dart';\n");
      expect(_scan().findings, [contains('lib/src/gone.dart does not exist')]);
    });

    test('a hide combinator fails rather than being read as whole-file', () {
      _write('lib/flutter_show_menu.dart', "export 'src/a.dart' hide Gamma;\n");
      _write('lib/src/a.dart', 'class Alpha {}\nclass Gamma {}\n');
      expect(_scan().findings, [contains('lib/flutter_show_menu.dart:1: ')]);
    });
  });
}
