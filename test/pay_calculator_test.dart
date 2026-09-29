import 'package:flutter_test/flutter_test.dart';
import 'package:moya_zarplata_flex/logic/pay_calculator.dart';
import 'package:moya_zarplata_flex/logic/pay_period.dart';
import 'package:moya_zarplata_flex/logic/period_report.dart';
import 'package:moya_zarplata_flex/models/shift.dart';

// Неделя с воскресенья 27.09.2026 по субботу 03.10.2026.
DateTime day(int offset) => DateTime(2026, 9, 27 + offset);

Shift shift(int dayOffset, ShiftType type, String start, String end) {
  int m(String t) {
    final p = t.split(':').map(int.parse).toList();
    return p[0] * 60 + p[1];
  }

  return Shift(
    date: day(dayOffset),
    type: type,
    startMinutes: m(start),
    endMinutes: m(end),
  );
}

List<(double, double)> parts(ShiftPay p) => [
  for (final x in p.parts) (x.hours, x.percent),
];

final fullWeek = [
  for (var i = 0; i < 5; i++) shift(i, ShiftType.morning, '7:00', '16:15'),
];

void main() {
  test('неделя начинается в воскресенье', () {
    expect(day(0).weekday, DateTime.sunday);
    expect(PayCalculator.weekStart(day(6)), day(0));
    expect(PayCalculator.weekStart(day(7)), day(7));
  });

  test('утренняя смена 7:00–16:15 без вычета перерыва: 8.4×100, 0.85×125', () {
    final pay = PayCalculator.computeWeek([fullWeek.first]).single;
    expect(pay.hours, 9.25);
    final p = parts(pay);
    expect(p[0], (8.4, 100.0));
    expect(p[1].$1, closeTo(0.85, 1e-9));
    expect(p[1].$2, 125.0);
  });

  test('утренняя смена до 19:15: 8.4×100, 2×125, остальное ×150', () {
    final pay = PayCalculator.computeWeek([
      shift(0, ShiftType.morning, '7:00', '19:15'),
    ]).single;
    final p = parts(pay);
    expect(p.take(2), [(8.4, 100.0), (2.0, 125.0)]);
    expect(p[2].$1, closeTo(1.85, 1e-9));
    expect(p[2].$2, 150.0);
  });

  test('Утро+ 7:00–19:00: 8.4×100, 2×125, 1.6×150', () {
    final s = shift(0, ShiftType.morningPlus, '7:00', '19:00');
    expect((s.startMinutes, s.endMinutes), ShiftType.morningPlus.defaultTimes);
    final p = parts(PayCalculator.computeWeek([s]).single);
    expect(p.take(2), [(8.4, 100.0), (2.0, 125.0)]);
    expect(p[2].$1, closeTo(1.6, 1e-9));
    expect(p[2].$2, 150.0);
  });

  test('Вечер 16:00–23:45: 7.75 ч на 100% и идёт в норму недели', () {
    final s = shift(0, ShiftType.evening, '16:00', '23:45');
    expect((s.startMinutes, s.endMinutes), ShiftType.evening.defaultTimes);
    final pay = PayCalculator.computeWeek([s]).single;
    expect(parts(pay), [(7.75, 100.0)]);
    expect(pay.baseMinutesAfter, 465);
  });

  test('ночная смена 19:00–7:15', () {
    final pay = PayCalculator.computeWeek([
      shift(0, ShiftType.night, '19:00', '7:15'),
    ]).single;
    expect(parts(pay), [
      (3.0, 100.0),
      (4.0, 142.5),
      (2.0, 178.1),
      (3.25, 213.7),
    ]);
  });

  test('пятница при выполненной норме: 2×125, остальное 150', () {
    final pays = PayCalculator.computeWeek([
      ...fullWeek,
      shift(5, ShiftType.friday, '7:00', '16:15'),
    ]);
    expect(pays[4].baseMinutesAfter, 42 * 60);
    expect(parts(pays.last), [(2.0, 125.0), (7.25, 150.0)]);
  });

  test('пятница без нормы: 100% до восполнения 42 ч', () {
    final pays = PayCalculator.computeWeek([
      ...fullWeek.take(4), // 33.6 ч, не хватает 8.4
      shift(5, ShiftType.friday, '7:00', '16:15'), // 9.25 ч
    ]);
    expect(parts(pays.last), [(8.4, 100.0), (0.85, 125.0)]);
    expect(pays.last.baseMinutesAfter, 42 * 60);
  });

  test('исход субботы при выполненной норме', () {
    final pays = PayCalculator.computeWeek([
      ...fullWeek,
      shift(6, ShiftType.saturdayNight, '19:00', '7:15'),
    ]);
    expect(parts(pays.last), [(7.0, 142.5), (2.0, 178.1), (3.25, 213.7)]);
  });

  test('исход субботы без нормы: 100% до 22:00, потом 142.5% до 42 ч', () {
    final pays = PayCalculator.computeWeek([
      ...fullWeek.take(4), // не хватает 8.4 ч
      shift(6, ShiftType.saturdayNight, '19:00', '7:15'), // 12.25 ч
    ]);
    // 19–22: 3 ч × 100%; ещё 5.4 ч × 142.5% до 42 ч; 2 ч × 178.1%; 1.85 × 213.7%.
    final p = parts(pays.last);
    expect(p[0], (3.0, 100.0));
    expect(p[1].$1, closeTo(5.4, 1e-9));
    expect(p[1].$2, 142.5);
    expect(p[2], (2.0, 178.1));
    expect(p[3].$1, closeTo(1.85, 1e-9));
    expect(p[3].$2, 213.7);
  });

  test('исход субботы, пустая неделя: норма так и не набирается', () {
    final pay = PayCalculator.computeWeek([
      shift(6, ShiftType.saturdayNight, '18:30', '7:15'),
    ]).single;
    expect(parts(pay), [(3.5, 100.0), (9.25, 142.5)]);
  });

  test('расчётный период — с 20 числа по 19 следующего месяца', () {
    final p = PayPeriod.containing(DateTime(2026, 9, 29), 20);
    expect(p.start, DateTime(2026, 9, 20));
    expect(p.lastDay, DateTime(2026, 10, 19));
    expect(p.contains(DateTime(2026, 10, 19)), isTrue);
    expect(p.contains(DateTime(2026, 10, 20)), isFalse);
    expect(p.contains(DateTime(2026, 9, 19)), isFalse);
    expect(PayPeriod.containing(DateTime(2026, 10, 19), 20), p);
    expect(PayPeriod.containing(DateTime(2026, 10, 20), 20), p.next);
    // Переход через год.
    final jan = PayPeriod.containing(DateTime(2027, 1, 5), 20);
    expect(jan.start, DateTime(2026, 12, 20));
    expect(jan.lastDay, DateTime(2027, 1, 19));
  });

  test('отчёт берёт смены периода, а норму недели — по всей неделе', () {
    // Неделя 18–24 октября 2026 пересекает начало периода 20 октября.
    Shift at(int d, ShiftType type, int start, int end) => Shift(
      date: DateTime(2026, 10, d),
      type: type,
      startMinutes: start,
      endMinutes: end,
    );
    final all = PayCalculator.computeAll([
      for (var d = 18; d <= 22; d++)
        at(d, ShiftType.morning, 7 * 60, 15 * 60 + 24), // ровно 8.4 ч
      at(23, ShiftType.friday, 7 * 60, 13 * 60),
    ]);
    final before = PayPeriod(2026, 9, 20);
    final period = PayPeriod(2026, 10, 20);
    expect(PeriodReport(period: before, allPays: all).shifts.length, 2);
    final report = PeriodReport(period: period, allPays: all);
    expect(report.shifts.length, 4);
    // Норма 42 ч набрана 22-го, пятница: 2 ч × 125%, 4 ч × 150%.
    expect(parts(report.shifts.last), [(2.0, 125.0), (4.0, 150.0)]);
    expect(report.weeks.single.normReached, isTrue);
    expect(report.amount(50), closeTo((3 * 8.4 + 2.5 + 6) * 50, 1e-9));
  });
}
