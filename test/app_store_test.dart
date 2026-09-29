import 'package:flutter_test/flutter_test.dart';
import 'package:moya_zarplata_flex/data/app_store.dart';
import 'package:moya_zarplata_flex/models/shift.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('резервная копия переносит смены и профиль', () async {
    final source = await AppStore.load();
    await source.updateProfile(
      source.profile.copyWith(hourlyRate: 55.5, periodStartDay: 15),
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
    expect(target.profile.periodStartDay, 15);
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
}
