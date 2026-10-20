import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/check_map.dart';

const _territoryHeadings = [
  'What it is',
  'Governing decisions',
  'Design model',
  'Code',
  'Reference behaviour',
  'Cross-cutting invariants',
  'Blast radius',
  'Known holes / open',
];

const _invariantHeadings = [
  'The fact',
  'Why it is cross-cutting',
  'Territories it holds in',
  'What a violation looks like',
  'Discovery history',
  'Where it will recur',
];

/// A note with every required heading; [sections] replaces a heading's body.
String _note(
  String title,
  List<String> headings, [
  Map<String, String> sections = const {},
]) {
  final buffer = StringBuffer('# $title\n\n');
  for (final heading in headings) {
    buffer.write('## $heading\n\n${sections[heading] ?? '**None.**'}\n\n');
  }
  return buffer.toString();
}

late Directory _repo;

void _write(String path, String content) {
  File('${_repo.path}/$path')
    ..createSync(recursive: true)
    ..writeAsStringSync(content);
}

List<String> _check({List<String>? only}) => checkMap(
      repoRoot: _repo.path,
      mapRoot: 'docs/map',
      only: only,
    ).map((f) => f.toString()).toList();

/// A two-note map that passes every check.
void _writeGoodMap() {
  _write('lib/a.dart', 'class Alpha {\n  void beta() {}\n}\n');
  _write('docs/adr/0001-x.md', '# X\n\n## Consequences\n');
  _write(
    'docs/map/territory/alpha.md',
    _note('Alpha', _territoryHeadings, {
      'Governing decisions': '[ADR-0001](../../adr/0001-x.md#consequences)',
      'Code': '- `lib/a.dart` — `Alpha.beta`',
      'Cross-cutting invariants': '[One path](../invariant/one-path.md)',
      'Blast radius': '[Self](#what-it-is) — a link to its own heading',
    }),
  );
  _write(
    'docs/map/invariant/one-path.md',
    _note('One path', _invariantHeadings, {
      'Territories it holds in': '[Alpha](../territory/alpha.md) — the site',
    }),
  );
  _write('docs/map/README.md', '# Map\n\n[Alpha](territory/alpha.md)\n');
}

void main() {
  setUp(() => _repo = Directory.systemTemp.createTempSync('check_map_'));
  tearDown(() => _repo.deleteSync(recursive: true));

  test('a complete map passes', () {
    _writeGoodMap();
    expect(_check(), isEmpty);
  });

  test('a CRLF checkout passes the same map', () {
    _writeGoodMap();
    for (final file
        in Directory(_repo.path).listSync(recursive: true).whereType<File>()) {
      file.writeAsStringSync(
        file.readAsStringSync().replaceAll('\n', '\r\n'),
      );
    }
    expect(_check(), isEmpty);
  });

  test('a link to a missing file fails', () {
    _writeGoodMap();
    _write('docs/map/README.md', '# Map\n\n[Gone](territory/gone.md)\n');
    expect(_check(), [contains('territory/gone.md does not exist')]);
  });

  test('a link to a missing anchor fails', () {
    _writeGoodMap();
    _write('docs/map/README.md', '# Map\n\n[A](territory/alpha.md#nope)\n');
    expect(_check(), [contains('#nope')]);
  });

  test('a link inside a code span or fence is ignored', () {
    _writeGoodMap();
    _write(
      'docs/map/README.md',
      '# Map\n\n`[x](../SOMEFILE.md)`\n\n```\n[y](nowhere.md)\n```\n',
    );
    expect(_check(), isEmpty);
  });

  test('a finding names the line it is on', () {
    _writeGoodMap();
    _write('docs/map/README.md', '# Map\n\n`code`\n[Gone](gone.md)\n');
    expect(_check(), [startsWith('docs/map/README.md:4:')]);
  });

  test('a symbol missing from its file fails', () {
    _writeGoodMap();
    _write('lib/a.dart', 'class Alpha {}\n');
    expect(_check(), [contains('`beta` not found in lib/a.dart')]);
  });

  test('a code path that does not exist fails', () {
    _writeGoodMap();
    final note = File('${_repo.path}/docs/map/territory/alpha.md');
    note.writeAsStringSync(
      note.readAsStringSync().replaceFirst('lib/a.dart', 'lib/b.dart'),
    );
    expect(_check(), [contains('lib/b.dart does not exist')]);
  });

  test('a root-level file is read as the file, not a symbol', () {
    _writeGoodMap();
    _write('pubspec.yaml', 'name: x\n');
    final note = File('${_repo.path}/docs/map/territory/alpha.md');
    note.writeAsStringSync(
      note.readAsStringSync().replaceFirst(
            '- `lib/a.dart` — `Alpha.beta`',
            '- `lib/a.dart` — `Alpha.beta`\n- `pubspec.yaml` — `name`',
          ),
    );
    expect(_check(), isEmpty);
  });

  test('a symbol must match a whole identifier', () {
    _writeGoodMap();
    _write('lib/a.dart', 'class Alphabet {\n  void betamax() {}\n}\n');
    expect(_check(), hasLength(2));
  });

  test('a missing heading fails', () {
    _writeGoodMap();
    final note = File('${_repo.path}/docs/map/territory/alpha.md');
    note.writeAsStringSync(
      note.readAsStringSync().replaceFirst('## Blast radius', '## Blast'),
    );
    expect(
      _check(),
      containsAll([contains('missing `## Blast radius`')]),
    );
  });

  test('an invariant its territory does not claim back fails', () {
    _writeGoodMap();
    final note = File('${_repo.path}/docs/map/territory/alpha.md');
    note.writeAsStringSync(
      note.readAsStringSync().replaceFirst(
            '[One path](../invariant/one-path.md)',
            '**None.**',
          ),
    );
    expect(_check(), [contains('does not list invariant/one-path.md')]);
  });

  test('only the named files are checked', () {
    _writeGoodMap();
    _write('docs/map/README.md', '# Map\n\n[Gone](gone.md)\n');
    expect(_check(only: ['docs/map/territory/alpha.md']), isEmpty);
  });

  test('a code span in a heading keeps its text in the slug', () {
    expect(slugsOf('## The `Close` path\n'), {'the-close-path'});
  });

  test('a backticked name off a bullet line under Code fails', () {
    _writeGoodMap();
    final note = File('${_repo.path}/docs/map/territory/alpha.md');
    note.writeAsStringSync(
      note.readAsStringSync().replaceFirst(
            '- `lib/a.dart` — `Alpha.beta`',
            '- `lib/a.dart` — `Alpha`,\n  `gamma`',
          ),
    );
    expect(_check(), [contains('`gamma` is not on a bullet line')]);
  });

  group('pointers in source', () {
    List<String> pointers() =>
        checkPointers(repoRoot: _repo.path).map((f) => f.toString()).toList();

    setUp(() {
      _writeGoodMap();
      _write(
        'lib/a.dart',
        '// Slow, deliberately; see docs/map/territory/alpha.md.\n'
            '// Decided in docs/adr/0001-x.md\n'
            'class Alpha {}\n',
      );
      _write(
        '.github/workflows/ci.yml',
        '# see docs/map/invariant/one-path.md.\n',
      );
    });

    test('a pointer to an existing note passes', () {
      expect(pointers(), isEmpty);
    });

    test('a pointer to a renamed note fails at its line', () {
      File('${_repo.path}/docs/map/territory/alpha.md')
          .renameSync('${_repo.path}/docs/map/territory/beta.md');
      expect(pointers(), [
        'lib/a.dart:1: docs/map/territory/alpha.md does not exist',
      ]);
    });

    test('a pointer to a missing decision record fails', () {
      File('${_repo.path}/docs/adr/0001-x.md').deleteSync();
      expect(pointers(), [contains('lib/a.dart:2:')]);
    });

    test('test/ and .github/ are read too', () {
      _write('test/a_test.dart', '// see docs/map/territory/gone.md\n');
      File('${_repo.path}/docs/map/invariant/one-path.md').deleteSync();
      expect(pointers(), [
        startsWith('.github/workflows/ci.yml:1:'),
        startsWith('test/a_test.dart:1:'),
      ]);
    });

    test("the checker's own fixtures are skipped", () {
      _write('test/check_map_test.dart', "'docs/map/territory/gone.md'\n");
      expect(pointers(), isEmpty);
    });
  });

  test('GitHub slugs drop punctuation and number duplicates', () {
    expect(slugsOf('## Known holes / open\n## A\n## A\n'),
        containsAll(['known-holes--open', 'a', 'a-1']));
  });
}
