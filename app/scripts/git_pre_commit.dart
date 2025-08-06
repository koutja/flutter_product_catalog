// ignore_for_file: avoid_print
/// Скрипт для автоматического применения dart fix и форматирования измененных Dart файлов перед коммитом.
///
/// Находит все измененные Dart файлы, применяет к ним dart fix, форматирует их и добавляет обратно в индекс Git.
/// Используется как pre-commit хук для поддержания качества кода.
library;

import 'dart:io';

void main() async {
  // Получаем список изменённых файлов с их статусами
  final gitDiffStatus = await Process.run('git', ['diff', '--cached', '--name-status']);
  if (gitDiffStatus.exitCode != 0) {
    stderr.writeln('Ошибка при получении списка изменённых файлов.');
    exit(1);
  }

  // Парсим вывод, чтобы получить только файлы, которые не удалены
  final lines = gitDiffStatus.stdout.toString().split('\n');
  final changedFiles = <String>[];
  for (var line in lines) {
    line = line.trim();
    if (line.isEmpty) continue;
    final parts = line.split(RegExp(r'\s+'));
    if (parts.length < 2) continue;
    final status = parts[0];
    final filePath = parts[1];
    // Добавляем файл, если он не удалён (статус не D)
    if ((status != 'D' && !status.startsWith('R')) && filePath.endsWith('.dart')) {
      changedFiles.add(filePath);
    }
  }

  if (changedFiles.isEmpty) {
    print('Нет изменённых Dart файлов для форматирования.');
    exit(0);
  }

  // Применяем dart fix для каждого файла отдельно
  print('Применение dart fix для ${changedFiles.length} файлов...');
  var fixError = false;
  for (final file in changedFiles) {
    final fixResult = await Process.run('dart', ['fix', '--apply', file]);
    stdout.write(fixResult.stdout);
    stderr.write(fixResult.stderr);
    if (fixResult.exitCode != 0) {
      stderr.writeln('Ошибка при применении dart fix для файла $file');
      fixError = true;
    }
  }

  if (fixError) {
    stderr.writeln('Произошли ошибки при применении dart fix.');
    exit(1);
  }

  // Форматируем файлы с помощью dart format по одному
  print('Форматирование ${changedFiles.length} файлов...');
  var formatError = false;
  for (final file in changedFiles) {
    final formatResult = await Process.run('dart', ['format', file, '--line-length', '120']);
    stdout.write(formatResult.stdout);
    stderr.write(formatResult.stderr);
    if (formatResult.exitCode != 0) {
      stderr.writeln('Ошибка при форматировании файла $file');
      formatError = true;
    }
  }

  if (formatError) {
    stderr.writeln('Произошли ошибки при форматировании файлов.');
    exit(1);
  }

  // Добавляем отформатированные файлы обратно в индекс
  final addResult = await Process.run('git', ['add', ...changedFiles]);
  if (addResult.exitCode != 0) {
    stderr.writeln('Ошибка при добавлении файлов в индекс.');
    exit(1);
  }

  print('Форматирование завершено успешно.');
}
