import 'dart:io';

import 'package:mason/mason.dart';

Future<void> run(HookContext context) async {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) return;

  final content = pubspec.readAsStringSync();
  if (!content.contains('build_runner')) {
    context.logger.info('build_runner not found in pubspec.yaml, skipping.');
    return;
  }

  final progress = context.logger.progress('Running build_runner');

  final result = await Process.run(
    'dart',
    ['run', 'build_runner', 'build', '--delete-conflicting-outputs'],
    runInShell: true,
  );

  if (result.exitCode == 0) {
    progress.complete('build_runner completed');
  } else {
    progress.fail('build_runner failed');
    context.logger.err(result.stderr.toString());
  }
}
