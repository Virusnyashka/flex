import '../models/shift.dart';

/// Часть смены, оплачиваемая по одному проценту.
class PayPart {
  const PayPart(this.minutes, this.percent);

  final int minutes;
  final double percent;

  double get hours => minutes / 60;

  /// Часы, приведённые к 100% ставке.
  double get weightedHours => hours * percent / 100;

  @override
  String toString() => 'PayPart(${hours}h @ $percent%)';
}

/// Результат расчёта одной смены.
class ShiftPay {
  const ShiftPay({
    required this.shift,
    required this.parts,
    required this.baseMinutesBefore,
    required this.baseMinutesAfter,
  });

  final Shift shift;
  final List<PayPart> parts;

  /// Сколько часов недельной нормы (42 ч на 100%) было набрано до и после смены.
  final int baseMinutesBefore;
  final int baseMinutesAfter;

  int get minutes => parts.fold(0, (sum, p) => sum + p.minutes);
  double get hours => minutes / 60;
  double get weightedHours =>
      parts.fold(0.0, (sum, p) => sum + p.weightedHours);
  double amount(double hourlyRate) => weightedHours * hourlyRate;
}

/// Итог недели (воскресенье — суббота).
class WeekSummary {
  const WeekSummary(this.start, this.baseMinutes, this.totalMinutes);

  final DateTime start;
  final int baseMinutes;
  final int totalMinutes;

  bool get normReached => baseMinutes >= PayCalculator.weeklyBaseMinutes;
}

/// Расчёт по правилам «Оплата рабочего времени».
///
/// Недельная норма — 42 часа, оплаченные на 100%. В неё идут часы на 100%
/// из утренних и ночных смен, а также часы пятницы и исхода субботы,
/// которыми норма «восполняется», если к этой смене она ещё не набрана.
class PayCalculator {
  static const weeklyBaseMinutes = 42 * 60;

  /// Начало недели (воскресенье) для даты.
  static DateTime weekStart(DateTime d) =>
      DateTime(d.year, d.month, d.day - d.weekday % 7);

  /// Считает все смены; недели считаются целиком, даже если попадают
  /// на два месяца.
  static Map<String, ShiftPay> computeAll(Iterable<Shift> shifts) {
    final byWeek = <DateTime, List<Shift>>{};
    for (final s in shifts) {
      byWeek.putIfAbsent(weekStart(s.date), () => []).add(s);
    }
    final result = <String, ShiftPay>{};
    for (final week in byWeek.values) {
      for (final pay in computeWeek(week)) {
        result[pay.shift.dateKey] = pay;
      }
    }
    return result;
  }

  /// Считает смены одной недели в хронологическом порядке.
  static List<ShiftPay> computeWeek(Iterable<Shift> weekShifts) {
    final sorted = weekShifts.toList()
      ..sort((a, b) {
        final byDate = a.date.compareTo(b.date);
        return byDate != 0 ? byDate : a.startMinutes.compareTo(b.startMinutes);
      });
    var base = 0;
    final result = <ShiftPay>[];
    for (final shift in sorted) {
      final (parts, added) = _computeShift(shift, base);
      result.add(
        ShiftPay(
          shift: shift,
          parts: _merge(parts),
          baseMinutesBefore: base,
          baseMinutesAfter: base + added,
        ),
      );
      base += added;
    }
    return result;
  }

  static WeekSummary summarizeWeek(DateTime start, Iterable<ShiftPay> pays) {
    var base = 0;
    var total = 0;
    for (final p in pays) {
      if (p.baseMinutesAfter > base) base = p.baseMinutesAfter;
      total += p.minutes;
    }
    return WeekSummary(start, base, total);
  }

  /// Возвращает части оплаты и сколько минут смена добавила к недельной норме.
  static (List<PayPart>, int) _computeShift(Shift shift, int base) {
    final worked = shift.workedMinutes;
    final deficit = _max0(weeklyBaseMinutes - base);

    switch (shift.type) {
      case ShiftType.morning:
      case ShiftType.morningPlus: // 7:00–19:00 — утро с доп. часами
      case ShiftType.evening: // 16:00–23:45 — по таблице утренней смены
        // 8.4 ч — 100%, 2 ч — 125%, дальше — 150%.
        final parts = _tiers(worked, const [(504, 100), (120, 125)], 150);
        return (parts, worked < 504 ? worked : 504);

      case ShiftType.night:
        // 3 ч — 100%, 4 ч — 142.5%, 2 ч — 178.1%, остальное — 213.7%.
        final parts = _tiers(worked, const [
          (180, 100),
          (240, 142.5),
          (120, 178.1),
        ], 213.7);
        return (parts, worked < 180 ? worked : 180);

      case ShiftType.friday:
        // Пока норма 42 ч не набрана — 100%; затем 2 ч — 125%, дальше — 150%.
        final fill = worked < deficit ? worked : deficit;
        return (
          [
            if (fill > 0) PayPart(fill, 100),
            ..._tiers(worked - fill, const [(120, 125)], 150),
          ],
          fill,
        );

      case ShiftType.saturdayNight:
        if (deficit == 0) {
          // Норма набрана: 7 ч — 142.5%, 2 ч — 178.1%, остальное — 213.7%.
          return (_tiers(worked, const [(420, 142.5), (120, 178.1)], 213.7), 0);
        }
        // Норма не набрана: до 22:00 — 100%; после 22:00 до восполнения
        // 42 ч — 142.5%; после восполнения 2 ч — 178.1%, дальше — 213.7%.
        final before22 = _minutesBefore22(shift.startMinutes);
        final at100 = worked < before22 ? worked : before22;
        final rest = worked - at100;
        final deficitAfter22 = _max0(deficit - at100);
        final at1425 = rest < deficitAfter22 ? rest : deficitAfter22;
        return (
          [
            if (at100 > 0) PayPart(at100, 100),
            if (at1425 > 0) PayPart(at1425, 142.5),
            ..._tiers(rest - at1425, const [(120, 178.1)], 213.7),
          ],
          at100 + at1425,
        );
    }
  }

  /// Минуты от начала смены до 22:00. Начало до полудня считается уже
  /// следующими сутками (после 22:00).
  static int _minutesBefore22(int start) {
    if (start < 12 * 60) return 0;
    return _max0(22 * 60 - start);
  }

  static List<PayPart> _tiers(
    int minutes,
    List<(int, double)> tiers,
    double restPercent,
  ) {
    final parts = <PayPart>[];
    var left = minutes;
    for (final (limit, percent) in tiers) {
      if (left <= 0) break;
      final take = left < limit ? left : limit;
      parts.add(PayPart(take, percent));
      left -= take;
    }
    if (left > 0) parts.add(PayPart(left, restPercent));
    return parts;
  }

  static List<PayPart> _merge(List<PayPart> parts) {
    final merged = <PayPart>[];
    for (final p in parts) {
      if (p.minutes <= 0) continue;
      if (merged.isNotEmpty && merged.last.percent == p.percent) {
        merged[merged.length - 1] = PayPart(
          merged.last.minutes + p.minutes,
          p.percent,
        );
      } else {
        merged.add(p);
      }
    }
    return merged;
  }

  static int _max0(int v) => v < 0 ? 0 : v;
}
