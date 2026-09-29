// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Salary Flex';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabProfile => 'Account';

  @override
  String get back => 'Back';

  @override
  String get forward => 'Forward';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get shiftMorning => 'Morning shift';

  @override
  String get shiftMorningPlus => 'Morning+';

  @override
  String get shiftEvening => 'Evening';

  @override
  String get shiftNight => 'Night shift';

  @override
  String get shiftFriday => 'Friday';

  @override
  String get shiftSaturdayNight => 'Saturday night (Motzei Shabbat)';

  @override
  String get shiftMorningShort => 'Morning';

  @override
  String get shiftMorningPlusShort => 'Morning+';

  @override
  String get shiftEveningShort => 'Evening';

  @override
  String get shiftNightShort => 'Night';

  @override
  String get shiftFridayShort => 'Friday';

  @override
  String get shiftSaturdayNightShort => 'Sat. night';

  @override
  String get weekdaysShort => 'Sun,Mon,Tue,Wed,Thu,Fri,Sat';

  @override
  String hoursValue(String hours) {
    return '$hours h';
  }

  @override
  String shiftsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shifts',
      one: '1 shift',
    );
    return '$_temp0';
  }

  @override
  String get payPeriods => 'Pay periods';

  @override
  String currentPeriodHours(String hours) {
    return 'Current period · $hours';
  }

  @override
  String get setRateShort => 'set your rate';

  @override
  String get profileTitle => 'My account';

  @override
  String get nameLabel => 'Name';

  @override
  String get notSpecified => 'not specified';

  @override
  String get hourlyRateLabel => 'Hourly rate (100%)';

  @override
  String get hourlyRateDialogTitle => 'Hourly rate';

  @override
  String get rateNotSet => 'not set — tap to set';

  @override
  String get payPeriodLabel => 'Pay period';

  @override
  String get languageLabel => 'Language';

  @override
  String get currentPeriod => 'current period';

  @override
  String get backupSave => 'Save a backup';

  @override
  String get backupSaveSubtitle => 'A file with all shifts and settings';

  @override
  String get backupRestore => 'Restore from a file';

  @override
  String get backupRestoreSubtitle => 'Replaces the current data';

  @override
  String get backupRestoreText => 'Restore from text';

  @override
  String get backupRestoreTextSubtitle => 'For older backups pasted into Notes';

  @override
  String get restoreConfirmBody =>
      'Your current shifts and settings will be replaced with the data from the file.';

  @override
  String get chooseFile => 'Choose file';

  @override
  String backupSaved(String file) {
    return 'Saved: $file';
  }

  @override
  String get restoreHint => 'Paste the backup text here';

  @override
  String get restoreAction => 'Restore';

  @override
  String restoredCount(String shifts) {
    return 'Restored: $shifts';
  }

  @override
  String get restoreFailedWrongApp =>
      'Couldn\'t restore: this is not a backup of this app';

  @override
  String get restoreFailedUnreadable =>
      'Couldn\'t restore: the data can\'t be read';

  @override
  String get noShiftsInPeriod =>
      'No shifts in this period.\nFill in your hours in the calendar.';

  @override
  String get grossPay => 'Pay for the period (gross)';

  @override
  String get setHourlyRate => 'Set your hourly rate';

  @override
  String reportSummary(String worked, String shifts, String weighted) {
    return '$worked worked · $shifts · $weighted at 100% equivalent';
  }

  @override
  String get hoursByPercent => 'Hours by rate';

  @override
  String get weeksSection => 'Weeks (norm: 42 h at 100%)';

  @override
  String get shiftsSection => 'Shifts';

  @override
  String get startLabel => 'Start';

  @override
  String get endLabel => 'End';

  @override
  String get endNextDayLabel => 'End (next day)';

  @override
  String get paidHours => 'Paid hours';

  @override
  String get forShift => 'For the shift';

  @override
  String weekNorm(String hours, String norm) {
    return 'Weekly norm at 100%: $hours of $norm';
  }

  @override
  String get rulesTitle => 'Calculation rules';

  @override
  String get rulesText =>
      'Pay is calculated for a pay period: either a calendar month (from the 1st to the last day) or from the 20th to the 19th of the next month — choose it above under “Pay period”. The week runs from Sunday to Saturday. Hours are counted from the start to the end of a shift; breaks are not deducted.\n\nMorning shift (7:00–16:15, extra hours until 19:15): 8.4 h at 100%, 2 h at 125%, then 150%.\n\nMorning+ (7:00–19:00) and Evening (16:00–23:45) are calculated with the same table as the morning shift.\n\nNight shift (19:00–7:15): 3 h at 100%, 4 h at 142.5%, 2 h at 178.1%, the rest at 213.7%.\n\nFriday (7:00–13:00, optionally until 16:15): if the weekly norm of 42 h at 100% has been reached — 2 h at 125%, the rest at 150%. Otherwise — 100% until the 42 h are made up, then 125% and 150%.\n\nSaturday night (Motzei Shabbat): if the norm has been reached — 7 h at 142.5%, 2 h at 178.1%, the rest until 7:15 at 213.7%. Otherwise — 100% until 22:00; after 22:00, 142.5% until the 42 h are made up; after that, 2 h at 178.1% and then 213.7%.\n\nThe 42 h norm counts the 100% hours of morning and night shifts and the Friday/Saturday night hours that make up the norm.';
}
