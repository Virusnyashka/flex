/// Заглушка для тестов и платформ без браузера.
Future<bool> saveBackupFile(String fileName, String text) =>
    throw UnsupportedError('Файлы резервных копий доступны только в браузере');

Future<String?> pickBackupFile() async => null;
