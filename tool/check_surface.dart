// Lists the public names the package barrel exports, for the test that pins
// them (test/check_surface_test.dart).
//
// A `show` export contributes the names it lists. A whole-file export
// contributes every public top-level declaration in that file, read from the
// lines `dart format` leaves at column 0. A line there that it cannot read is
// a finding, as are `part` files, `hide`, and an export inside an exported
// file, so a form it does not know fails instead of being skipped.
//
//   dart run tool/check_surface.dart   # prints the names, one per line
import 'dart:io';

void main() {
  final scan = scanSurface(repoRoot: Directory.current.path);
  for (final finding in scan.findings) {
    stderr.writeln(finding);
  }
  for (final name in scan.names.toList()..sort()) {
    stdout.writeln(name);
  }
  if (scan.findings.isNotEmpty) exit(1);
}

/// The names [barrel] makes public, and anything that stopped them being read.
/// Paths are relative to [repoRoot], with forward slashes.
({Set<String> names, List<SurfaceFinding> findings}) scanSurface({
  required String repoRoot,
  String barrel = 'lib/flutter_show_menu.dart',
}) {
  final root = repoRoot.replaceAll(r'\', '/');
  final names = <String>{};
  final findings = <SurfaceFinding>[];

  final text = _read(root, barrel);
  if (text == null) {
    return (
      names: names,
      findings: [SurfaceFinding(barrel, 1, 'does not exist')]
    );
  }
  _declarations(barrel, text, names, findings, inBarrel: true);

  final export = RegExp(r"^export\s+'([^']+)'([^;]*);", multiLine: true);
  final dir = barrel.substring(0, barrel.lastIndexOf('/') + 1);
  for (final match in export.allMatches(text)) {
    final line = _lineOf(text, match.start);
    final file = '$dir${match.group(1)}';
    final combinators = match.group(2)!.trim();
    if (combinators.startsWith('show')) {
      names.addAll(
        combinators
            .substring(4)
            .split(',')
            .map((n) => n.trim())
            .where((n) => n.isNotEmpty),
      );
      continue;
    }
    if (combinators.isNotEmpty) {
      findings.add(
          SurfaceFinding(barrel, line, 'unsupported export: $combinators'));
      continue;
    }
    final source = _read(root, file);
    if (source == null) {
      findings.add(SurfaceFinding(barrel, line, '$file does not exist'));
      continue;
    }
    _declarations(file, source, names, findings, inBarrel: false);
  }
  return (names: names, findings: findings);
}

final _skipped = RegExp(r'^(import\s|library\b|//|/\*|@|[}\)\];])');

final _declarationForms = [
  RegExp(
      r'^(?:(?:abstract|sealed|final|base|interface|mixin)\s+)*class\s+(\w+)'),
  RegExp(r'^enum\s+(\w+)'),
  RegExp(r'^mixin\s+(\w+)'),
  RegExp(r'^typedef\s+(\w+)\s*[<=]'),
  RegExp(r'^extension\s+type\s+(?:const\s+)?(\w+)'),
  RegExp(r'^extension\s+on\b()'),
  RegExp(r'^extension\s+(\w+)'),
  RegExp(r'^(?:const|final|var|late)\s+(?:[\w<>?, .]+\s+)?(\w+)\s*[=;]'),
  RegExp(r'^[\w<>?, .]+\s+get\s+(\w+)'),
  RegExp(r'^(?:[\w<>?, .]+\s+)?(\w+)\s*(?:<[^>]*>)?\('),
];

/// Adds the public top-level names declared in [text] to [names].
void _declarations(
  String path,
  String text,
  Set<String> names,
  List<SurfaceFinding> findings, {
  required bool inBarrel,
}) {
  final lines = text.split(RegExp(r'\r?\n'));
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.isEmpty ||
        line.startsWith(RegExp(r'\s')) ||
        _skipped.hasMatch(line)) {
      continue;
    }
    if (line.startsWith(RegExp(r'export\s'))) {
      if (!inBarrel) {
        findings
            .add(SurfaceFinding(path, i + 1, 'export inside an exported file'));
      }
      continue;
    }
    if (line.startsWith(RegExp(r'part\s'))) {
      findings.add(SurfaceFinding(path, i + 1, 'part files are not read'));
      continue;
    }
    String? name;
    for (final form in _declarationForms) {
      final match = form.firstMatch(line);
      if (match != null) {
        name = match.group(1);
        break;
      }
    }
    if (name == null) {
      findings.add(
          SurfaceFinding(path, i + 1, 'unrecognised top-level line: $line'));
    } else if (name.isNotEmpty && !name.startsWith('_')) {
      names.add(name);
    }
  }
}

int _lineOf(String text, int offset) =>
    '\n'.allMatches(text.substring(0, offset)).length + 1;

String? _read(String root, String path) {
  final file = File('$root/$path');
  return file.existsSync() ? file.readAsStringSync() : null;
}

/// A problem at [path]:[line].
class SurfaceFinding {
  SurfaceFinding(this.path, this.line, this.message);

  final String path;
  final int line;
  final String message;

  @override
  String toString() => '$path:$line: $message';
}
