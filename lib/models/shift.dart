/// Тип смены — определяет, по какой таблице считается оплата.
enum ShiftType {
  morning,
  morningPlus,
  evening,
  night,
  friday,
  saturdayNight;

  String get title => switch (this) {
    ShiftType.morning => 'Утренняя смена',
    ShiftType.morningPlus => 'Утро+',
    ShiftType.evening => 'Вечер',
    ShiftType.night => 'Ночная смена',
    ShiftType.friday => 'Пятница',
    ShiftType.saturdayNight => 'Исход субботы',
  };

  String get shortTitle => switch (this) {
    ShiftType.morning => 'Утро',
    ShiftType.morningPlus => 'Утро+',
    ShiftType.evening => 'Вечер',
    ShiftType.night => 'Ночь',
    ShiftType.friday => 'Пятница',
    ShiftType.saturdayNight => 'Исход сб.',
  };

  /// Тип смены по умолчанию для дня недели (неделя — с воскресенья).
  static ShiftType defaultFor(DateTime date) => switch (date.weekday) {
    DateTime.friday => ShiftType.friday,
    DateTime.saturday => ShiftType.saturdayNight,
    _ => ShiftType.morning,
  };

  /// Время начала и конца по умолчанию, в минутах от полуночи.
  (int start, int end) get defaultTimes => switch (this) {
    ShiftType.morning => (7 * 60, 16 * 60 + 15),
    ShiftType.morningPlus => (7 * 60, 19 * 60),
    ShiftType.evening => (16 * 60, 23 * 60 + 45),
    ShiftType.night => (19 * 60, 7 * 60 + 15),
    ShiftType.friday => (7 * 60, 13 * 60),
    ShiftType.saturdayNight => (19 * 60, 7 * 60 + 15),
  };
}

/// Одна рабочая смена. Дата — день начала смены; если конец раньше начала,
/// смена заканчивается на следующий день.
class Shift {
  Shift({
    required DateTime date,
    required this.type,
    required this.startMinutes,
    required this.endMinutes,
  }) : date = DateTime(date.year, date.month, date.day);

  final DateTime date;
  final ShiftType type;
  final int startMinutes;
  final int endMinutes;

  /// Оплачиваемые минуты — от начала до конца смены, перерывы не вычитаются.
  int get workedMinutes {
    final span = endMinutes - startMinutes;
    return span <= 0 ? span + 24 * 60 : span;
  }

  String get dateKey => dateKeyOf(date);

  static String dateKeyOf(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  Shift copyWith({ShiftType? type, int? startMinutes, int? endMinutes}) =>
      Shift(
        date: date,
        type: type ?? this.type,
        startMinutes: startMinutes ?? this.startMinutes,
        endMinutes: endMinutes ?? this.endMinutes,
      );

  Map<String, Object> toJson() => {
    'date': dateKey,
    'type': type.name,
    'start': startMinutes,
    'end': endMinutes,
  };

  factory Shift.fromJson(Map<String, dynamic> json) {
    final parts = (json['date'] as String).split('-').map(int.parse).toList();
    return Shift(
      date: DateTime(parts[0], parts[1], parts[2]),
      type: ShiftType.values.byName(json['type'] as String),
      startMinutes: json['start'] as int,
      endMinutes: json['end'] as int,
    );
  }
}
