import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('he'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'My Salary Flex'**
  String get appTitle;

  /// No description provided for @tabCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tabCalendar;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get tabProfile;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @forward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get forward;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @shiftMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning shift'**
  String get shiftMorning;

  /// No description provided for @shiftMorningPlus.
  ///
  /// In en, this message translates to:
  /// **'Morning+'**
  String get shiftMorningPlus;

  /// No description provided for @shiftEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get shiftEvening;

  /// No description provided for @shiftNight.
  ///
  /// In en, this message translates to:
  /// **'Night shift'**
  String get shiftNight;

  /// No description provided for @shiftFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get shiftFriday;

  /// No description provided for @shiftSaturdayNight.
  ///
  /// In en, this message translates to:
  /// **'Saturday night (Motzei Shabbat)'**
  String get shiftSaturdayNight;

  /// No description provided for @shiftMorningShort.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get shiftMorningShort;

  /// No description provided for @shiftMorningPlusShort.
  ///
  /// In en, this message translates to:
  /// **'Morning+'**
  String get shiftMorningPlusShort;

  /// No description provided for @shiftEveningShort.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get shiftEveningShort;

  /// No description provided for @shiftNightShort.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get shiftNightShort;

  /// No description provided for @shiftFridayShort.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get shiftFridayShort;

  /// No description provided for @shiftSaturdayNightShort.
  ///
  /// In en, this message translates to:
  /// **'Sat. night'**
  String get shiftSaturdayNightShort;

  /// Short weekday names from Sunday to Saturday, separated by commas.
  ///
  /// In en, this message translates to:
  /// **'Sun,Mon,Tue,Wed,Thu,Fri,Sat'**
  String get weekdaysShort;

  /// No description provided for @hoursValue.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String hoursValue(String hours);

  /// No description provided for @shiftsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 shift} other{{count} shifts}}'**
  String shiftsCount(int count);

  /// No description provided for @payPeriods.
  ///
  /// In en, this message translates to:
  /// **'Pay periods'**
  String get payPeriods;

  /// No description provided for @currentPeriodHours.
  ///
  /// In en, this message translates to:
  /// **'Current period · {hours}'**
  String currentPeriodHours(String hours);

  /// No description provided for @setRateShort.
  ///
  /// In en, this message translates to:
  /// **'set your rate'**
  String get setRateShort;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get profileTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @notSpecified.
  ///
  /// In en, this message translates to:
  /// **'not specified'**
  String get notSpecified;

  /// No description provided for @hourlyRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Hourly rate (100%)'**
  String get hourlyRateLabel;

  /// No description provided for @hourlyRateDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Hourly rate'**
  String get hourlyRateDialogTitle;

  /// No description provided for @rateNotSet.
  ///
  /// In en, this message translates to:
  /// **'not set — tap to set'**
  String get rateNotSet;

  /// No description provided for @payPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Pay period'**
  String get payPeriodLabel;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @currentPeriod.
  ///
  /// In en, this message translates to:
  /// **'current period'**
  String get currentPeriod;

  /// No description provided for @backupSave.
  ///
  /// In en, this message translates to:
  /// **'Save a backup'**
  String get backupSave;

  /// No description provided for @backupSaveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Copies all shifts and settings'**
  String get backupSaveSubtitle;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup'**
  String get backupRestore;

  /// No description provided for @backupRestoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Replaces the current data'**
  String get backupRestoreSubtitle;

  /// No description provided for @backupCopiedTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup copied'**
  String get backupCopiedTitle;

  /// No description provided for @backupCopiedBody.
  ///
  /// In en, this message translates to:
  /// **'The data has been copied to the clipboard. Paste it into Notes or send it to yourself in a message so you don\'t lose it.'**
  String get backupCopiedBody;

  /// No description provided for @restoreHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the backup text here'**
  String get restoreHint;

  /// No description provided for @restoreAction.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreAction;

  /// No description provided for @restoredCount.
  ///
  /// In en, this message translates to:
  /// **'Restored: {shifts}'**
  String restoredCount(String shifts);

  /// No description provided for @restoreFailedWrongApp.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore: this is not a backup of this app'**
  String get restoreFailedWrongApp;

  /// No description provided for @restoreFailedUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t restore: the data can\'t be read'**
  String get restoreFailedUnreadable;

  /// No description provided for @noShiftsInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No shifts in this period.\nFill in your hours in the calendar.'**
  String get noShiftsInPeriod;

  /// No description provided for @grossPay.
  ///
  /// In en, this message translates to:
  /// **'Pay for the period (gross)'**
  String get grossPay;

  /// No description provided for @setHourlyRate.
  ///
  /// In en, this message translates to:
  /// **'Set your hourly rate'**
  String get setHourlyRate;

  /// No description provided for @reportSummary.
  ///
  /// In en, this message translates to:
  /// **'{worked} worked · {shifts} · {weighted} at 100% equivalent'**
  String reportSummary(String worked, String shifts, String weighted);

  /// No description provided for @hoursByPercent.
  ///
  /// In en, this message translates to:
  /// **'Hours by rate'**
  String get hoursByPercent;

  /// No description provided for @weeksSection.
  ///
  /// In en, this message translates to:
  /// **'Weeks (norm: 42 h at 100%)'**
  String get weeksSection;

  /// No description provided for @shiftsSection.
  ///
  /// In en, this message translates to:
  /// **'Shifts'**
  String get shiftsSection;

  /// No description provided for @startLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startLabel;

  /// No description provided for @endLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endLabel;

  /// No description provided for @endNextDayLabel.
  ///
  /// In en, this message translates to:
  /// **'End (next day)'**
  String get endNextDayLabel;

  /// No description provided for @paidHours.
  ///
  /// In en, this message translates to:
  /// **'Paid hours'**
  String get paidHours;

  /// No description provided for @forShift.
  ///
  /// In en, this message translates to:
  /// **'For the shift'**
  String get forShift;

  /// No description provided for @weekNorm.
  ///
  /// In en, this message translates to:
  /// **'Weekly norm at 100%: {hours} of {norm}'**
  String weekNorm(String hours, String norm);

  /// No description provided for @rulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculation rules'**
  String get rulesTitle;

  /// No description provided for @rulesText.
  ///
  /// In en, this message translates to:
  /// **'Pay is calculated for a pay period: either a calendar month (from the 1st to the last day) or from the 20th to the 19th of the next month — choose it above under “Pay period”. The week runs from Sunday to Saturday. Hours are counted from the start to the end of a shift; breaks are not deducted.\n\nMorning shift (7:00–16:15, extra hours until 19:15): 8.4 h at 100%, 2 h at 125%, then 150%.\n\nMorning+ (7:00–19:00) and Evening (16:00–23:45) are calculated with the same table as the morning shift.\n\nNight shift (19:00–7:15): 3 h at 100%, 4 h at 142.5%, 2 h at 178.1%, the rest at 213.7%.\n\nFriday (7:00–13:00, optionally until 16:15): if the weekly norm of 42 h at 100% has been reached — 2 h at 125%, the rest at 150%. Otherwise — 100% until the 42 h are made up, then 125% and 150%.\n\nSaturday night (Motzei Shabbat): if the norm has been reached — 7 h at 142.5%, 2 h at 178.1%, the rest until 7:15 at 213.7%. Otherwise — 100% until 22:00; after 22:00, 142.5% until the 42 h are made up; after that, 2 h at 178.1% and then 213.7%.\n\nThe 42 h norm counts the 100% hours of morning and night shifts and the Friday/Saturday night hours that make up the norm.'**
  String get rulesText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'he', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
