import 'dart:convert';
import 'dart:io';

void main() async {
  try {
    // Получаем последние 2 коммита
    final commits = await _getLatestCommits(2);
    if (commits.length < 2) {
      print('⚠️ Недостаточно коммитов для сравнения.');
      exit(1);
    }

    final commitLast = commits[0];
    final commitPrev = commits[1];

    print('✅ Коммиты:\n- $commitLast\n- $commitPrev');

    // Выполняем git diff
    print('git diff $commitPrev $commitLast');
    final diffResult = await _runCommand('git', ['diff', commitPrev, commitLast]);

    // Сохраняем результат в файл
    final outputFile = File('diff_output.txt');
    await outputFile.writeAsString(diffResult.stdout as String);

    print('✅ Diff сохранён в diff_output.txt');
  } catch (e) {
    print('❌ Ошибка: $e');
    exit(1);
  }
}

Future<List<String>> _getLatestCommits(int count) async {
  final result = await _runCommand('git', ['log', '--pretty=format:%H', '-n', '$count']);
  return (result.stdout as String).trim().split('\n');
}

Future<ProcessResult> _runCommand(String command, List<String> args) async {
  final process = await Process.start(command, args);
  final stdout = await process.stdout.transform(utf8.decoder).join();
  final stderr = await process.stderr.transform(utf8.decoder).join();
  final exitCode = await process.exitCode;

  if (exitCode != 0) {
    throw Exception('Ошибка выполнения команды: $stderr');
  }

  return ProcessResult(process.pid, exitCode, stdout, stderr);
}
