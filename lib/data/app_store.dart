import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logic/pay_calculator.dart';
import '../logic/pay_period.dart';
import '../logic/period_report.dart';
import '../models/shift.dart';

/// Данные личного кабинета.
class Profile {
  const Profile({
    this.name = '',
    this.hourlyRate = 0,
    this.currency = '₪',
    this.periodStartDay = 20,
  });

  final String name;
  final double hourlyRate;
  final String currency;

  /// С какого числа начинается расчётный период (1–28).
  final int periodStartDay;

  Profile copyWith({
    String? name,
    double? hourlyRate,
    String? currency,
    int? periodStartDay,
  }) => Profile(
    name: name ?? this.name,
    hourlyRate: hourlyRate ?? this.hourlyRate,
    currency: currency ?? this.currency,
    periodStartDay: periodStartDay ?? this.periodStartDay,
  );

  Map<String, Object> toJson() => {
    'name': name,
    'hourlyRate': hourlyRate,
    'currency': currency,
    'periodStartDay': periodStartDay,
  };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    name: (json['name'] as String?) ?? '',
    hourlyRate: ((json['hourlyRate'] as num?) ?? 0).toDouble(),
    currency: (json['currency'] as String?) ?? '₪',
    periodStartDay: (json['periodStartDay'] as int?) ?? 20,
  );
}

/// Хранилище смен и профиля (локально на устройстве).
class AppStore extends ChangeNotifier {
  AppStore._(this._prefs, this._shifts, this._profile);

  static const _shiftsKey = 'shifts';
  static const _profileKey = 'profile';

  final SharedPreferences _prefs;
  final Map<String, Shift> _shifts;
  Profile _profile;
  Map<String, ShiftPay>? _pays;

  static Future<AppStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final shifts = <String, Shift>{};
    final rawShifts = prefs.getString(_shiftsKey);
    if (rawShifts != null) {
      for (final item in jsonDecode(rawShifts) as List) {
        final shift = Shift.fromJson(item as Map<String, dynamic>);
        shifts[shift.dateKey] = shift;
      }
    }
    final rawProfile = prefs.getString(_profileKey);
    final profile = rawProfile == null
        ? const Profile()
        : Profile.fromJson(jsonDecode(rawProfile) as Map<String, dynamic>);
    return AppStore._(prefs, shifts, profile);
  }

  Profile get profile => _profile;

  Shift? shiftOn(DateTime date) => _shifts[Shift.dateKeyOf(date)];

  Map<String, ShiftPay> get pays =>
      _pays ??= PayCalculator.computeAll(_shifts.values);

  ShiftPay? payOn(DateTime date) => pays[Shift.dateKeyOf(date)];

  /// Расчёт смены так, как если бы она была сохранена (с учётом недели).
  ShiftPay preview(Shift shift) {
    final start = PayCalculator.weekStart(shift.date);
    final week = [
      for (final s in _shifts.values)
        if (PayCalculator.weekStart(s.date) == start &&
            s.dateKey != shift.dateKey)
          s,
      shift,
    ];
    return PayCalculator.computeWeek(week)
        .firstWhere((p) => p.shift.dateKey == shift.dateKey);
  }

  PayPeriod periodContaining(DateTime date) =>
      PayPeriod.containing(date, _profile.periodStartDay);

  /// Период, который начинается в указанном месяце.
  PayPeriod periodStartingIn(int year, int month) =>
      PayPeriod(year, month, _profile.periodStartDay);

  PeriodReport report(PayPeriod period) =>
      PeriodReport(period: period, allPays: pays);

  /// Новая смена со значениями по умолчанию для этого дня.
  Shift newShift(DateTime date, [ShiftType? type]) {
    final t = type ?? ShiftType.defaultFor(date);
    final (start, end) = t.defaultTimes;
    return Shift(date: date, type: t, startMinutes: start, endMinutes: end);
  }

  Future<void> saveShift(Shift shift) async {
    _shifts[shift.dateKey] = shift;
    await _persistShifts();
  }

  Future<void> deleteShift(DateTime date) async {
    _shifts.remove(Shift.dateKeyOf(date));
    await _persistShifts();
  }

  Future<void> updateProfile(Profile profile) async {
    _profile = profile;
    notifyListeners();
    await _prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  /// Все данные одной строкой JSON — для резервной копии.
  String exportJson() => const JsonEncoder.withIndent('  ').convert({
    'app': 'moya_zarplata_flex',
    'version': 1,
    'profile': _profile.toJson(),
    'shifts': [for (final s in _shifts.values) s.toJson()],
  });

  /// Заменяет все данные данными из резервной копии.
  /// Возвращает число загруженных смен; при неверных данных — FormatException.
  Future<int> importJson(String text) async {
    final Map<String, dynamic> data;
    final List<Shift> shifts;
    final Profile profile;
    try {
      data = jsonDecode(text) as Map<String, dynamic>;
      if (data['app'] != 'moya_zarplata_flex') {
        throw const FormatException('это не резервная копия приложения');
      }
      shifts = [
        for (final item in data['shifts'] as List)
          Shift.fromJson(item as Map<String, dynamic>),
      ];
      profile = Profile.fromJson(data['profile'] as Map<String, dynamic>);
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('не удалось прочитать данные ($e)');
    }
    _shifts
      ..clear()
      ..addEntries(shifts.map((s) => MapEntry(s.dateKey, s)));
    await updateProfile(profile);
    await _persistShifts();
    return shifts.length;
  }

  Future<void> _persistShifts() async {
    _pays = null;
    notifyListeners();
    await _prefs.setString(
      _shiftsKey,
      jsonEncode([for (final s in _shifts.values) s.toJson()]),
    );
  }
}
