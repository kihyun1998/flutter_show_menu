// Fails when the territory map under docs/map has a broken edge.
//
// Run it from the repository root, the same way CI does:
//
//   dart run tool/check_map.dart              # every note under docs/map
//   dart run tool/check_map.dart <note.md>... # just these notes
//
// The scope is every .md file under docs/map, listed fresh on each run, so a
// new note is checked without being registered anywhere.
//
// Four checks:
//
// - every relative link resolves, and so does its #anchor;
// - every symbol named under a note's `## Code` occurs, as a whole
//   identifier, in the file its bullet starts with:
//
//     - `lib/src/open_menu.dart` — `OpenMenu.close`, `_Phase`
// - territory and invariant notes carry their required headings, spelled
//   exactly;
// - an invariant and a territory that name each other do so both ways.
//
// Code spans and fenced blocks are ignored when looking for links.
//
// With no notes named, it also checks that every `docs/map/...md` and
// `docs/adr/...md` path mentioned under lib/, test/ and .github/ exists.
import 'dart:io';

const territoryHeadings = [
  'What it is',
  'Governing decisions',
  'Design model',
  'Code',
  'Reference behaviour',
  'Cross-cutting invariants',
  'Blast radius',
  'Known holes / open',
];

const invariantHeadings = [
  'The fact',
  'Why it is cross-cutting',
  'Territories it holds in',
  'What a violation looks like',
  'Discovery history',
  'Where it will recur',
];

void main(List<String> args) {
  final only = args.where((a) => !a.startsWith('--')).toList();
  final findings = checkMap(
    repoRoot: Directory.current.path,
    mapRoot: 'docs/map',
    only: only.isEmpty ? null : only,
  );
  if (only.isEmpty) {
    findings.addAll(checkPointers(repoRoot: Directory.current.path));
  }

  for (final finding in findings) {
    stderr.writeln(finding);
  }
  if (findings.isNotEmpty) {
    stderr.writeln('${findings.length} map finding(s).');
    exit(1);
  }
  stdout.writeln('Map OK.');
}

class MapFinding {
  MapFinding(this.path, this.line, this.message);

  final String path;
  final int line;
  final String message;

  @override
  String toString() => '$path:$line: $message';
}

/// Checks the notes under [mapRoot], or only [only] where given. Paths are
/// relative to [repoRoot], with forward slashes.
List<MapFinding> checkMap({
  required String repoRoot,
  required String mapRoot,
  List<String>? only,
}) {
  final root = _normalize(repoRoot);
  final notes = only?.map(_normalize).toList() ??
      (Directory('$root/$mapRoot')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.md'))
          .map((f) => _relative(root, f.path))
          .toList()
        ..sort());

  final findings = <MapFinding>[];
  for (final note in notes) {
    final text = _read(root, note);
    if (text == null) {
      findings.add(MapFinding(note, 1, 'note does not exist'));
      continue;
    }
    findings
      ..addAll(_checkLinks(root, note, text))
      ..addAll(_checkHeadings(note, text))
      ..addAll(_checkCode(root, note, text))
      ..addAll(_checkReciprocity(root, mapRoot, note, text));
  }
  return findings;
}

/// Every `docs/map/...md` or `docs/adr/...md` path mentioned in a file under
/// [dirs] that does not exist. The paths are relative to [repoRoot], and
/// [skip] holds files whose paths are fixtures rather than pointers.
List<MapFinding> checkPointers({
  required String repoRoot,
  List<String> dirs = const ['lib', 'test', '.github'],
  Set<String> skip = const {'test/check_map_test.dart'},
}) {
  final root = _normalize(repoRoot);
  final files = [
    for (final dir in dirs)
      if (Directory('$root/$dir').existsSync())
        ...Directory('$root/$dir')
            .listSync(recursive: true)
            .whereType<File>()
            .map((f) => _relative(root, f.path)),
  ]..sort();

  final pointer = RegExp(r'docs/(?:map|adr)/[\w./-]*?\.md(?![\w-])');
  final findings = <MapFinding>[];
  for (final file in files) {
    if (skip.contains(file)) continue;
    final text = _read(root, file)!;
    for (final match in pointer.allMatches(text)) {
      final path = match.group(0)!;
      if (!File('$root/$path').existsSync()) {
        findings.add(
          MapFinding(file, _lineOf(text, match.start), '$path does not exist'),
        );
      }
    }
  }
  return findings;
}

/// The GitHub anchor of every heading in [markdown], duplicates numbered.
Set<String> slugsOf(String markdown) {
  final seen = <String, int>{};
  final slugs = <String>{};
  for (final line in _lines(_blankFences(markdown))) {
    final match = RegExp(r'^#{1,6}\s+(.*?)\s*#*\s*$').firstMatch(line);
    if (match == null) continue;
    final base = match
        .group(1)!
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N} _-]', unicode: true), '')
        .replaceAll(' ', '-');
    final count = seen[base] ?? 0;
    seen[base] = count + 1;
    slugs.add(count == 0 ? base : '$base-$count');
  }
  return slugs;
}

Iterable<MapFinding> _checkLinks(String root, String note, String text) sync* {
  final blanked = _blankCode(text);
  final link = RegExp(r'\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)');
  for (final match in link.allMatches(blanked)) {
    final target = match.group(1)!;
    if (RegExp(r'^[a-z][a-z0-9+.-]*:', caseSensitive: false).hasMatch(target)) {
      continue;
    }
    final line = _lineOf(text, match.start);
    final hash = target.indexOf('#');
    final pathPart = hash == -1 ? target : target.substring(0, hash);
    final anchor = hash == -1 ? null : target.substring(hash + 1);

    final resolved = pathPart.isEmpty ? note : _join(_dirOf(note), pathPart);
    final exists = File('$root/$resolved').existsSync() ||
        Directory('$root/$resolved').existsSync();
    if (!exists) {
      yield MapFinding(note, line, '$target: $resolved does not exist');
      continue;
    }
    if (anchor == null || !resolved.endsWith('.md')) continue;
    if (!slugsOf(_read(root, resolved)!).contains(anchor)) {
      yield MapFinding(note, line, '$target: no heading for #$anchor');
    }
  }
}

Iterable<MapFinding> _checkHeadings(String note, String text) sync* {
  final required = _kindOf(note) == 'territory'
      ? territoryHeadings
      : _kindOf(note) == 'invariant'
          ? invariantHeadings
          : const <String>[];
  final present = _sections(text).keys.toSet();
  for (final heading in required) {
    if (!present.contains(heading)) {
      yield MapFinding(note, 1, 'missing `## $heading`');
    }
  }
}

Iterable<MapFinding> _checkCode(String root, String note, String text) sync* {
  final section = _sections(text)['Code'];
  if (section == null) return;

  final symbol = RegExp(r'^[A-Za-z_$][\w$]*(\.[A-Za-z_$][\w$]*)*(\(\))?$');
  for (final (line, content) in section.lines) {
    if (!content.trimLeft().startsWith('- ')) {
      for (final token in RegExp(r'`([^`]+)`').allMatches(content)) {
        yield MapFinding(
          note,
          line,
          '`${token.group(1)}` is not on a bullet line',
        );
      }
      continue;
    }
    String? file;
    String? source;
    for (final token in RegExp(r'`([^`]+)`').allMatches(content)) {
      final value = token.group(1)!;
      if (file == null) {
        file = value;
        source = _read(root, value);
        if (source == null) {
          yield MapFinding(note, line, '$value does not exist');
        }
        continue;
      }
      if (!symbol.hasMatch(value)) {
        yield MapFinding(note, line, '`$value` is not a symbol name');
        continue;
      }
      if (source == null) continue;
      for (final part in value.replaceAll('()', '').split('.')) {
        final word = RegExp('(?<![\\w\$])${RegExp.escape(part)}(?![\\w\$])');
        if (!word.hasMatch(source)) {
          yield MapFinding(note, line, '`$part` not found in $file');
        }
      }
    }
  }
}

Iterable<MapFinding> _checkReciprocity(
  String root,
  String mapRoot,
  String note,
  String text,
) sync* {
  final kind = _kindOf(note);
  final (own, other, otherKind) = switch (kind) {
    'territory' => (
        'Cross-cutting invariants',
        'Territories it holds in',
        'invariant'
      ),
    'invariant' => (
        'Territories it holds in',
        'Cross-cutting invariants',
        'territory'
      ),
    _ => (null, null, null),
  };
  if (own == null) return;

  final section = _sections(text)[own];
  if (section == null) return;
  for (final target in _linkTargets(note, section.text)) {
    if (_kindOf(target) != otherKind) continue;
    final otherText = _read(root, target);
    if (otherText == null) continue;
    final back = _sections(otherText)[other];
    final claimsBack =
        back != null && _linkTargets(target, back.text).contains(note);
    if (!claimsBack) {
      yield MapFinding(
        note,
        section.lines.isEmpty ? 1 : section.lines.first.$1,
        '${_short(mapRoot, target)} does not list '
        '${_short(mapRoot, note)} under `## $other`',
      );
    }
  }
}

class _Section {
  _Section(this.text, this.lines);
  final String text;
  final List<(int, String)> lines;
}

/// The body of every `## ` heading, keyed by the heading text.
Map<String, _Section> _sections(String text) {
  final sections = <String, _Section>{};
  final lines = _lines(text);
  final blanked = _lines(_blankCode(text));
  String? current;
  var body = <(int, String)>[];

  void close() {
    if (current != null) {
      sections[current] = _Section(body.map((l) => l.$2).join('\n'), body);
    }
  }

  for (var i = 0; i < lines.length; i++) {
    final heading = RegExp(r'^##\s+(.*?)\s*$').firstMatch(blanked[i]);
    if (heading != null) {
      close();
      current = heading.group(1);
      body = [];
    } else if (current != null) {
      if (RegExp(r'^#\s').hasMatch(blanked[i])) {
        close();
        current = null;
      } else {
        body.add((i + 1, lines[i]));
      }
    }
  }
  close();
  return sections;
}

/// Note paths, relative to the repository, that [text] links to.
Set<String> _linkTargets(String note, String text) {
  final link = RegExp(r'\[[^\]]*\]\(([^)\s#]+)[^)]*\)');
  return {
    for (final match in link.allMatches(_blankCode(text)))
      _join(_dirOf(note), match.group(1)!),
  };
}

/// [text] with code spans and fenced blocks replaced by spaces, so offsets and
/// line numbers survive.
String _blankCode(String text) =>
    _blankFences(text).replaceAllMapped(RegExp(r'(`+)[^\r\n]*?\1'), _blank);

/// [text] with fenced blocks replaced by spaces.
String _blankFences(String text) => text.replaceAllMapped(
      RegExp(r'^ {0,3}(```|~~~).*?^ {0,3}\1[^\r\n]*$',
          multiLine: true, dotAll: true),
      _blank,
    );

String _blank(Match m) => m.group(0)!.replaceAll(RegExp(r'[^\r\n]'), ' ');

String? _kindOf(String path) {
  final parts = path.split('/');
  if (parts.length < 2) return null;
  final folder = parts[parts.length - 2];
  return folder == 'territory' || folder == 'invariant' ? folder : null;
}

List<String> _lines(String text) => text.split(RegExp(r'\r?\n'));

int _lineOf(String text, int offset) =>
    '\n'.allMatches(text.substring(0, offset)).length + 1;

String? _read(String root, String path) {
  final file = File('$root/$path');
  return file.existsSync() ? file.readAsStringSync() : null;
}

String _normalize(String path) => path.replaceAll(r'\', '/');

String _relative(String root, String path) =>
    _normalize(path).substring(root.length + 1);

String _dirOf(String path) {
  final i = path.lastIndexOf('/');
  return i == -1 ? '' : path.substring(0, i);
}

String _short(String mapRoot, String path) =>
    path.startsWith('$mapRoot/') ? path.substring(mapRoot.length + 1) : path;

/// [relative] resolved against [dir], with `.` and `..` folded away.
String _join(String dir, String relative) {
  final parts = <String>[if (dir.isNotEmpty) ...dir.split('/')];
  for (final part in relative.split('/')) {
    if (part == '.' || part.isEmpty) continue;
    if (part == '..') {
      if (parts.isNotEmpty) parts.removeLast();
    } else {
      parts.add(part);
    }
  }
  return parts.join('/');
}
