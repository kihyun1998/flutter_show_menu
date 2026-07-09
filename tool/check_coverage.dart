// Fails when total line coverage in an lcov report falls below a floor.
//
// The floor lives here and in the workflow that calls this script — nowhere
// else. Run it the same way CI does:
//
//   flutter test --coverage
//   dart run tool/check_coverage.dart --min 80
//
// Pass --report to print per-file coverage regardless of the outcome.
import 'dart:io';

void main(List<String> args) {
  final minimum = _doubleArg(args, '--min') ?? 0;
  final path = _stringArg(args, '--lcov') ?? 'coverage/lcov.info';
  final report = args.contains('--report');

  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('No lcov report at $path. Run `flutter test --coverage`.');
    exit(2);
  }

  final files = _parse(file.readAsLinesSync());
  if (files.isEmpty) {
    stderr.writeln('$path contains no records.');
    exit(2);
  }

  final found = files.values.fold(0, (sum, r) => sum + r.found);
  final hit = files.values.fold(0, (sum, r) => sum + r.hit);
  final total = found == 0 ? 0.0 : hit * 100 / found;

  if (report || total < minimum) {
    final sorted = files.entries.toList()
      ..sort((a, b) => a.value.percent.compareTo(b.value.percent));
    for (final entry in sorted) {
      final r = entry.value;
      stdout.writeln(
        '${r.percent.toStringAsFixed(1).padLeft(6)}%  '
        '${'${r.hit}/${r.found}'.padRight(9)}  ${entry.key}',
      );
    }
    stdout.writeln('');
  }

  stdout.writeln(
    'Total line coverage: ${total.toStringAsFixed(1)}% '
    '($hit/$found), floor ${minimum.toStringAsFixed(1)}%',
  );

  if (total < minimum) {
    stderr.writeln(
      'Coverage ${total.toStringAsFixed(1)}% is below the '
      '${minimum.toStringAsFixed(1)}% floor.',
    );
    exit(1);
  }
}

class _Record {
  int found = 0;
  int hit = 0;
  double get percent => found == 0 ? 0 : hit * 100 / found;
}

/// Sums LF/LH per source file. A file can appear in more than one record.
Map<String, _Record> _parse(List<String> lines) {
  final records = <String, _Record>{};
  var current = '';

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      current = line.substring(3).replaceAll(r'\', '/');
    } else if (line.startsWith('LF:')) {
      (records[current] ??= _Record()).found += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      (records[current] ??= _Record()).hit += int.parse(line.substring(3));
    }
  }
  return records;
}

String? _stringArg(List<String> args, String name) {
  final i = args.indexOf(name);
  return (i == -1 || i + 1 >= args.length) ? null : args[i + 1];
}

double? _doubleArg(List<String> args, String name) {
  final raw = _stringArg(args, name);
  return raw == null ? null : double.parse(raw);
}
