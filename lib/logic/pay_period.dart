/// Расчётный период зарплаты: с дня [startDay] одного месяца
/// до дня перед [startDay] следующего (например, 20 сентября — 19 октября).
class PayPeriod {
  PayPeriod(int year, int month, this.startDay)
    : start = DateTime(year, month, startDay),
      end = DateTime(year, month + 1, startDay);

  /// Период, в который попадает дата.
  factory PayPeriod.containing(DateTime date, int startDay) =>
      date.day >= startDay
      ? PayPeriod(date.year, date.month, startDay)
      : PayPeriod(date.year, date.month - 1, startDay);

  final int startDay;

  /// Первый день периода.
  final DateTime start;

  /// Первый день следующего периода (не входит в этот).
  final DateTime end;

  /// Последний день периода.
  DateTime get lastDay => DateTime(end.year, end.month, end.day - 1);

  bool contains(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return !d.isBefore(start) && d.isBefore(end);
  }

  PayPeriod get previous => PayPeriod(start.year, start.month - 1, startDay);
  PayPeriod get next => PayPeriod(start.year, start.month + 1, startDay);

  @override
  bool operator ==(Object other) =>
      other is PayPeriod && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}
