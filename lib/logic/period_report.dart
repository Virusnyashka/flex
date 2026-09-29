import '../models/shift.dart';
import 'pay_calculator.dart';
import 'pay_period.dart';

/// Отчёт за расчётный период: смены, разбивка часов по процентам и недели.
class PeriodReport {
  PeriodReport({required this.period, required Map<String, ShiftPay> allPays}) {
    for (final pay in allPays.values) {
      if (period.contains(pay.shift.date)) shifts.add(pay);
    }
    shifts.sort((a, b) => a.shift.date.compareTo(b.shift.date));

    for (final pay in shifts) {
      for (final part in pay.parts) {
        minutesByPercent.update(
          part.percent,
          (m) => m + part.minutes,
          ifAbsent: () => part.minutes,
        );
      }
      countByType.update(pay.shift.type, (c) => c + 1, ifAbsent: () => 1);
    }

    // Недели, которые пересекаются с периодом, — по всем их сменам.
    final weekStarts = <DateTime>{
      for (final p in shifts) PayCalculator.weekStart(p.shift.date),
    }.toList()..sort();
    for (final start in weekStarts) {
      final weekPays = allPays.values.where(
        (p) => PayCalculator.weekStart(p.shift.date) == start,
      );
      weeks.add(PayCalculator.summarizeWeek(start, weekPays));
    }
  }

  final PayPeriod period;
  final List<ShiftPay> shifts = [];
  final Map<double, int> minutesByPercent = {};
  final Map<ShiftType, int> countByType = {};
  final List<WeekSummary> weeks = [];

  List<double> get percents => minutesByPercent.keys.toList()..sort();

  int get totalMinutes => shifts.fold(0, (s, p) => s + p.minutes);
  double get totalHours => totalMinutes / 60;
  double get weightedHours => shifts.fold(0.0, (s, p) => s + p.weightedHours);
  double amount(double hourlyRate) => weightedHours * hourlyRate;
}
