import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

const _type = 'application/json';

/// Отдаёт файл пользователю. На телефоне — через меню «Поделиться»
/// (там есть «Сохранить в Файлы»), на компьютере — обычной загрузкой.
/// Возвращает false, если пользователь закрыл меню «Поделиться».
///
/// Вызывать сразу по нажатию, без await перед этим: браузер разрешает
/// «Поделиться» только в ответ на действие пользователя.
Future<bool> saveBackupFile(String fileName, String text) async {
  final parts = [text.toJS].toJS;
  final navigator = web.window.navigator;
  // canShare есть не во всех браузерах (например, в Firefox).
  if (navigator.maxTouchPoints > 0 && navigator.has('canShare')) {
    final file = web.File(parts, fileName, web.FilePropertyBag(type: _type));
    final data = web.ShareData(files: [file].toJS);
    if (navigator.canShare(data)) {
      try {
        await navigator.share(data).toDart;
        return true;
      } catch (_) {
        return false; // Меню закрыли без выбора.
      }
    }
  }
  final url = web.URL.createObjectURL(
    web.Blob(parts, web.BlobPropertyBag(type: _type)),
  );
  final link = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName;
  web.document.body!.append(link);
  link.click();
  link.remove();
  Timer(const Duration(minutes: 1), () => web.URL.revokeObjectURL(url));
  return true;
}

/// Открывает выбор файла и возвращает его текст; null — если отменили.
Future<String?> pickBackupFile() async {
  final completer = Completer<web.File?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = '.json,application/json,.txt,text/plain'
    ..style.display = 'none';
  void finish(web.File? file) {
    if (!completer.isCompleted) completer.complete(file);
  }

  input.addEventListener(
    'change',
    ((web.Event _) => finish(input.files?.item(0))).toJS,
  );
  input.addEventListener('cancel', ((web.Event _) => finish(null)).toJS);
  web.document.body!.append(input);
  input.click();
  try {
    final file = await completer.future;
    if (file == null) return null;
    return (await file.text().toDart).toDart;
  } finally {
    input.remove();
  }
}
