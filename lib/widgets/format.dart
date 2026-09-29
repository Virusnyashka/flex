import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../logic/pay_period.dart';
import '../models/shift.dart';

/// Числа и даты форматируются по языку интерфейса ([AppLocalizations.localeName]).

String formatHours(AppLocalizations l, double hours) =>
    l.hoursValue(NumberFormat('0.##', l.localeName).format(hours));

/// Сумма в шекелях.
String formatMoney(AppLocalizations l, double amount) => NumberFormat.currency(
  locale: l.localeName,
  symbol: '₪',
  decimalDigits: 2,
).format(amount);

String formatPercent(AppLocalizations l, double percent) =>
    '${NumberFormat('0.#', l.localeName).format(percent)}%';

String formatTime(int minutes) {
  final m = minutes % (24 * 60);
  return '${m ~/ 60}:${(m % 60).toString().padLeft(2, '0')}';
}

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String monthTitle(AppLocalizations l, int year, int month) =>
    capitalize(DateFormat.yMMMM(l.localeName).format(DateTime(year, month)));

/// «20 сент. – 19 окт.» — без года.
String dateRange(AppLocalizations l, DateTime a, DateTime b) {
  final short = DateFormat.MMMd(l.localeName);
  return '${short.format(a)} – ${short.format(b)}';
}

/// «20 сент. – 19 окт. 2026 г.» или «20 дек. 2026 г. – 19 янв. 2027 г.».
String periodTitle(AppLocalizations l, PayPeriod period) {
  final a = period.start;
  final b = period.lastDay;
  final short = DateFormat.MMMd(l.localeName);
  final full = DateFormat.yMMMd(l.localeName);
  return a.year == b.year
      ? '${short.format(a)} – ${full.format(b)}'
      : '${full.format(a)} – ${full.format(b)}';
}

/// Короткие названия дней недели, начиная с воскресенья.
List<String> weekdayNames(AppLocalizations l) => l.weekdaysShort.split(',');

String shiftTitle(AppLocalizations l, ShiftType type) => switch (type) {
  ShiftType.morning => l.shiftMorning,
  ShiftType.morningPlus => l.shiftMorningPlus,
  ShiftType.evening => l.shiftEvening,
  ShiftType.night => l.shiftNight,
  ShiftType.friday => l.shiftFriday,
  ShiftType.saturdayNight => l.shiftSaturdayNight,
};

String shiftShortTitle(AppLocalizations l, ShiftType type) => switch (type) {
  ShiftType.morning => l.shiftMorningShort,
  ShiftType.morningPlus => l.shiftMorningPlusShort,
  ShiftType.evening => l.shiftEveningShort,
  ShiftType.night => l.shiftNightShort,
  ShiftType.friday => l.shiftFridayShort,
  ShiftType.saturdayNight => l.shiftSaturdayNightShort,
};

Color shiftColor(ShiftType type) => switch (type) {
  ShiftType.morning => const Color(0xFF2E9E6B),
  ShiftType.morningPlus => const Color(0xFF0E8A9E),
  ShiftType.evening => const Color(0xFFD0603A),
  ShiftType.night => const Color(0xFF4A5BD4),
  ShiftType.friday => const Color(0xFFE09A1F),
  ShiftType.saturdayNight => const Color(0xFFB0459E),
};

IconData shiftIcon(ShiftType type) => switch (type) {
  ShiftType.morning => Icons.wb_sunny_outlined,
  ShiftType.morningPlus => Icons.more_time,
  ShiftType.evening => Icons.wb_twilight,
  ShiftType.night => Icons.nightlight_outlined,
  ShiftType.friday => Icons.event_available_outlined,
  ShiftType.saturdayNight => Icons.auto_awesome_outlined,
};
