// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'המשכורת שלי Flex';

  @override
  String get tabCalendar => 'לוח שנה';

  @override
  String get tabProfile => 'אזור אישי';

  @override
  String get back => 'הקודם';

  @override
  String get forward => 'הבא';

  @override
  String get cancel => 'ביטול';

  @override
  String get save => 'שמירה';

  @override
  String get delete => 'מחיקה';

  @override
  String get shiftMorning => 'משמרת בוקר';

  @override
  String get shiftMorningPlus => 'בוקר+';

  @override
  String get shiftEvening => 'ערב';

  @override
  String get shiftNight => 'משמרת לילה';

  @override
  String get shiftFriday => 'שישי';

  @override
  String get shiftSaturdayNight => 'מוצאי שבת';

  @override
  String get shiftMorningShort => 'בוקר';

  @override
  String get shiftMorningPlusShort => 'בוקר+';

  @override
  String get shiftEveningShort => 'ערב';

  @override
  String get shiftNightShort => 'לילה';

  @override
  String get shiftFridayShort => 'שישי';

  @override
  String get shiftSaturdayNightShort => 'מוצ״ש';

  @override
  String get weekdaysShort => 'א׳,ב׳,ג׳,ד׳,ה׳,ו׳,ש׳';

  @override
  String hoursValue(String hours) {
    return '$hours ש׳';
  }

  @override
  String shiftsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count משמרות',
      one: 'משמרת אחת',
    );
    return '$_temp0';
  }

  @override
  String get payPeriods => 'תקופות שכר';

  @override
  String currentPeriodHours(String hours) {
    return 'התקופה הנוכחית · $hours';
  }

  @override
  String get setRateShort => 'יש להזין תעריף';

  @override
  String get profileTitle => 'האזור האישי';

  @override
  String get nameLabel => 'שם';

  @override
  String get notSpecified => 'לא צוין';

  @override
  String get hourlyRateLabel => 'תעריף שעתי (100%)';

  @override
  String get hourlyRateDialogTitle => 'תעריף שעתי';

  @override
  String get rateNotSet => 'לא הוזן — הקישו כדי להזין';

  @override
  String get payPeriodLabel => 'תקופת שכר';

  @override
  String get languageLabel => 'שפה';

  @override
  String get currentPeriod => 'התקופה הנוכחית';

  @override
  String get backupSave => 'שמירת גיבוי';

  @override
  String get backupSaveSubtitle => 'קובץ עם כל המשמרות וההגדרות';

  @override
  String get backupRestore => 'שחזור מקובץ';

  @override
  String get backupRestoreSubtitle => 'מחליף את הנתונים הנוכחיים';

  @override
  String get backupRestoreText => 'שחזור מטקסט';

  @override
  String get backupRestoreTextSubtitle => 'לגיבויים ישנים שהודבקו בפתקים';

  @override
  String get restoreConfirmBody =>
      'המשמרות וההגדרות הנוכחיות יוחלפו בנתונים מהקובץ.';

  @override
  String get chooseFile => 'בחירת קובץ';

  @override
  String backupSaved(String file) {
    return 'נשמר: $file';
  }

  @override
  String get restoreHint => 'הדביקו כאן את טקסט הגיבוי';

  @override
  String get restoreAction => 'שחזור';

  @override
  String restoredCount(String shifts) {
    return 'שוחזרו: $shifts';
  }

  @override
  String get restoreFailedWrongApp => 'השחזור נכשל: זה לא גיבוי של האפליקציה';

  @override
  String get restoreFailedUnreadable => 'השחזור נכשל: לא ניתן לקרוא את הנתונים';

  @override
  String get noShiftsInPeriod =>
      'אין משמרות בתקופה הזו.\nמלאו את השעות בלוח השנה.';

  @override
  String get grossPay => 'שכר לתקופה (ברוטו)';

  @override
  String get setHourlyRate => 'הזינו תעריף שעתי';

  @override
  String reportSummary(String worked, String shifts, String weighted) {
    return '$worked עבודה · $shifts · $weighted בחישוב לפי 100%';
  }

  @override
  String get hoursByPercent => 'שעות לפי אחוזים';

  @override
  String get weeksSection => 'שבועות (מכסה 42 ש׳ ב-100%)';

  @override
  String get shiftsSection => 'משמרות';

  @override
  String get startLabel => 'התחלה';

  @override
  String get endLabel => 'סיום';

  @override
  String get endNextDayLabel => 'סיום (למחרת)';

  @override
  String get paidHours => 'שעות בתשלום';

  @override
  String get forShift => 'עבור המשמרת';

  @override
  String weekNorm(String hours, String norm) {
    return 'מכסה שבועית ב-100%: $hours מתוך $norm';
  }

  @override
  String get rulesTitle => 'כללי החישוב';

  @override
  String get rulesText =>
      'השכר מחושב לפי תקופת שכר: חודש קלנדרי (מה-1 ועד סוף החודש) או מה-20 בחודש ועד ה-19 בחודש הבא — בוחרים למעלה, בסעיף „תקופת שכר”. השבוע מתחיל ביום ראשון ומסתיים בשבת. השעות נספרות מתחילת המשמרת ועד סופה, ללא ניכוי הפסקות.\n\nמשמרת בוקר (7:00–16:15, שעות נוספות עד 19:15): 8.4 ש׳ ב-100%, 2 ש׳ ב-125%, ומעבר לכך 150%.\n\nבוקר+ (7:00–19:00) וערב (16:00–23:45) מחושבים לפי אותה טבלה כמו משמרת בוקר.\n\nמשמרת לילה (19:00–7:15): 3 ש׳ ב-100%, 4 ש׳ ב-142.5%, 2 ש׳ ב-178.1%, והשאר ב-213.7%.\n\nשישי (7:00–13:00, אפשרות עד 16:15): אם המכסה השבועית של 42 ש׳ ב-100% הושלמה — 2 ש׳ ב-125% והשאר ב-150%. אחרת — 100% עד להשלמת 42 ש׳, ולאחר מכן 125% ו-150%.\n\nמוצאי שבת: אם המכסה הושלמה — 7 ש׳ ב-142.5%, 2 ש׳ ב-178.1% והשאר עד 7:15 ב-213.7%. אחרת — 100% עד 22:00; אחרי 22:00 ועד להשלמת 42 ש׳ — 142.5%; לאחר ההשלמה 2 ש׳ ב-178.1% ואחר כך 213.7%.\n\nלמכסת 42 ש׳ נספרות שעות ה-100% של משמרות בוקר ולילה, ושעות שישי ומוצאי שבת שבהן המכסה מושלמת.';
}
