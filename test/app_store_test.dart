import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:moya_zarplata_flex/data/app_store.dart';
import 'package:moya_zarplata_flex/models/shift.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('резервная копия переносит смены и профиль', () async {
    final source = await AppStore.load();
    await source.updateProfile(
      source.profile.copyWith(
        hourlyRate: 55.5,
        periodStartDay: 1,
        language: 'he',
      ),
    );
    await source.saveShift(source.newShift(DateTime(2026, 9, 27)));
    await source.saveShift(
      source.newShift(DateTime(2026, 9, 28), ShiftType.night),
    );
    final backup = source.exportJson();

    SharedPreferences.setMockInitialValues({});
    final target = await AppStore.load();
    expect(await target.importJson(backup), 2);
    expect(target.profile.hourlyRate, 55.5);
    expect(target.profile.periodStartDay, 1);
    expect(target.profile.language, 'he');
    expect(target.shiftOn(DateTime(2026, 9, 28))!.type, ShiftType.night);

    // После перезапуска данные на месте.
    final reloaded = await AppStore.load();
    expect(reloaded.shiftOn(DateTime(2026, 9, 27)), isNotNull);
  });

  test('неверная копия не портит данные', () async {
    final store = await AppStore.load();
    await store.saveShift(store.newShift(DateTime(2026, 9, 27)));
    expect(() => store.importJson('привет'), throwsFormatException);
    expect(() => store.importJson('{"app":"other"}'), throwsFormatException);
    expect(store.shiftOn(DateTime(2026, 9, 27)), isNotNull);
  });

  test('по умолчанию — английский и период с 20 числа', () async {
    final store = await AppStore.load();
    expect(store.profile.language, 'en');
    expect(store.profile.periodStartDay, 20);
    expect(jsonDecode(store.exportJson())['profile']['language'], 'en');
  });

  test('старые данные: currency игнорируется, неверный период — 20', () async {
    SharedPreferences.setMockInitialValues({
      'profile': jsonEncode({
        'name': 'Аня',
        'hourlyRate': 40,
        'currency': r'$',
        'periodStartDay': 15,
      }),
    });
    final store = await AppStore.load();
    expect(store.profile.name, 'Аня');
    expect(store.profile.hourlyRate, 40);
    expect(store.profile.periodStartDay, 20);
    expect(store.profile.language, 'en');
    expect(store.profile.toJson().containsKey('currency'), isFalse);
  });

  test('старая резервная копия с currency загружается', () async {
    final store = await AppStore.load();
    final count = await store.importJson(
      jsonEncode({
        'app': 'moya_zarplata_flex',
        'version': 1,
        'profile': {
          'name': '',
          'hourlyRate': 50,
          'currency': '₪',
          'periodStartDay': 5,
        },
        'shifts': [
          {'date': '2026-09-27', 'type': 'morning', 'start': 420, 'end': 975},
        ],
      }),
    );
    expect(count, 1);
    expect(store.profile.hourlyRate, 50);
    expect(store.profile.periodStartDay, 20);
    expect(store.profile.language, 'en');
  });

  test('неизвестный язык в данных заменяется английским', () {
    expect(Profile.fromJson({'language': 'fr'}).language, 'en');
    expect(Profile.fromJson({'language': 'ru'}).language, 'ru');
  });
}
