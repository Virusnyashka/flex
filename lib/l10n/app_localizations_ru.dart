// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Моя зарплата Flex';

  @override
  String get tabCalendar => 'Календарь';

  @override
  String get tabProfile => 'Кабинет';

  @override
  String get back => 'Назад';

  @override
  String get forward => 'Вперёд';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get gotIt => 'Понятно';

  @override
  String get shiftMorning => 'Утренняя смена';

  @override
  String get shiftMorningPlus => 'Утро+';

  @override
  String get shiftEvening => 'Вечер';

  @override
  String get shiftNight => 'Ночная смена';

  @override
  String get shiftFriday => 'Пятница';

  @override
  String get shiftSaturdayNight => 'Исход субботы';

  @override
  String get shiftMorningShort => 'Утро';

  @override
  String get shiftMorningPlusShort => 'Утро+';

  @override
  String get shiftEveningShort => 'Вечер';

  @override
  String get shiftNightShort => 'Ночь';

  @override
  String get shiftFridayShort => 'Пятница';

  @override
  String get shiftSaturdayNightShort => 'Исход сб.';

  @override
  String get weekdaysShort => 'Вс,Пн,Вт,Ср,Чт,Пт,Сб';

  @override
  String hoursValue(String hours) {
    return '$hours ч';
  }

  @override
  String shiftsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count смены',
      many: '$count смен',
      few: '$count смены',
      one: '$count смена',
    );
    return '$_temp0';
  }

  @override
  String get payPeriods => 'Расчётные периоды';

  @override
  String currentPeriodHours(String hours) {
    return 'Текущий период · $hours';
  }

  @override
  String get setRateShort => 'укажите ставку';

  @override
  String get profileTitle => 'Личный кабинет';

  @override
  String get nameLabel => 'Имя';

  @override
  String get notSpecified => 'не указано';

  @override
  String get hourlyRateLabel => 'Часовая ставка (100%)';

  @override
  String get hourlyRateDialogTitle => 'Часовая ставка';

  @override
  String get rateNotSet => 'не указана — нажмите, чтобы указать';

  @override
  String get payPeriodLabel => 'Расчётный период';

  @override
  String get languageLabel => 'Язык';

  @override
  String get currentPeriod => 'текущий период';

  @override
  String get backupSave => 'Сохранить резервную копию';

  @override
  String get backupSaveSubtitle => 'Копирует все смены и настройки';

  @override
  String get backupRestore => 'Восстановить из копии';

  @override
  String get backupRestoreSubtitle => 'Заменяет текущие данные';

  @override
  String get backupCopiedTitle => 'Копия скопирована';

  @override
  String get backupCopiedBody =>
      'Данные скопированы в буфер обмена. Вставьте их в Заметки или отправьте себе в сообщении, чтобы не потерять.';

  @override
  String get restoreHint => 'Вставьте сюда текст резервной копии';

  @override
  String get restoreAction => 'Восстановить';

  @override
  String restoredCount(String shifts) {
    return 'Восстановлено: $shifts';
  }

  @override
  String get restoreFailedWrongApp =>
      'Не получилось: это не резервная копия приложения';

  @override
  String get restoreFailedUnreadable =>
      'Не получилось: не удалось прочитать данные';

  @override
  String get noShiftsInPeriod =>
      'В этом периоде смен нет.\nЗаполните часы в календаре.';

  @override
  String get grossPay => 'Зарплата за период (брутто)';

  @override
  String get setHourlyRate => 'Укажите часовую ставку';

  @override
  String reportSummary(String worked, String shifts, String weighted) {
    return '$worked отработано · $shifts · $weighted в пересчёте на 100%';
  }

  @override
  String get hoursByPercent => 'Часы по процентам';

  @override
  String get weeksSection => 'Недели (норма 42 ч на 100%)';

  @override
  String get shiftsSection => 'Смены';

  @override
  String get startLabel => 'Начало';

  @override
  String get endLabel => 'Конец';

  @override
  String get endNextDayLabel => 'Конец (след. день)';

  @override
  String get paidHours => 'Оплачиваемых часов';

  @override
  String get forShift => 'За смену';

  @override
  String weekNorm(String hours, String norm) {
    return 'Норма недели на 100%: $hours из $norm';
  }

  @override
  String get rulesTitle => 'Правила расчёта';

  @override
  String get rulesText =>
      'Зарплата считается за расчётный период: календарный месяц (с 1 числа по последнее) или с 20 числа по 19 число следующего месяца — выбирается выше, в пункте «Расчётный период». Неделя — с воскресенья по субботу. Часы считаются от начала до конца смены, перерывы не вычитаются.\n\nУтренняя смена (7:00–16:15, доп. часы до 19:15): 8,4 ч — 100%, 2 ч — 125%, дальше — 150%.\n\nУтро+ (7:00–19:00) и Вечер (16:00–23:45) считаются по той же таблице, что и утренняя смена.\n\nНочная смена (19:00–7:15): 3 ч — 100%, 4 ч — 142,5%, 2 ч — 178,1%, остальное — 213,7%.\n\nПятница (7:00–13:00, опция до 16:15): если норма 42 ч на 100% за неделю выполнена — 2 ч по 125%, остальное по 150%. Иначе — 100% до восполнения 42 ч, затем 125% и 150%.\n\nИсход субботы: если норма выполнена — 7 ч по 142,5%, 2 ч по 178,1%, остальное до 7:15 по 213,7%. Иначе — 100% до 22:00; после 22:00 до восполнения 42 ч — 142,5%; после восполнения 2 ч по 178,1% и далее 213,7%.\n\nВ норму 42 ч засчитываются часы на 100% утренних и ночных смен и часы пятницы/субботы, которыми норма восполняется.';
}
