import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../logic/pay_period.dart';
import '../models/shift.dart';

final _hours = NumberFormat('0.##', 'ru');
final _money = NumberFormat('#,##0.00', 'ru');
final _percent = NumberFormat('0.#', 'ru');

String formatHours(double hours) => '${_hours.format(hours)} ч';

String formatMoney(double amount, String currency) =>
    '${_money.format(amount)} $currency';

String formatPercent(double percent) => '${_percent.format(percent)}%';

String formatTime(int minutes) {
  final m = minutes % (24 * 60);
  return '${m ~/ 60}:${(m % 60).toString().padLeft(2, '0')}';
}

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String monthTitle(int year, int month) =>
    capitalize(DateFormat.yMMMM('ru').format(DateTime(year, month)));

/// «20 сент. – 19 окт. 2026» или «20 дек. 2026 – 19 янв. 2027».
String periodTitle(PayPeriod period) {
  final a = period.start;
  final b = period.lastDay;
  final short = DateFormat('d MMM', 'ru');
  final full = DateFormat('d MMM y', 'ru');
  return a.year == b.year
      ? '${short.format(a)} – ${full.format(b)}'
      : '${full.format(a)} – ${full.format(b)}';
}

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

/// «1 смена», «3 смены», «5 смен».
String shiftsCount(int n) {
  final mod10 = n % 10;
  final mod100 = n % 100;
  final word = mod10 == 1 && mod100 != 11
      ? 'смена'
      : mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)
      ? 'смены'
      : 'смен';
  return '$n $word';
}
