import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moya_zarplata_flex/data/app_store.dart';
import 'package:moya_zarplata_flex/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    for (final language in Profile.languages) {
      await initializeDateFormatting(language);
    }
  });

  testWidgets('старт на английском, после выбора иврита — RTL', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await AppStore.load();
    await tester.pumpWidget(SalaryApp(store: store));
    await tester.pumpAndSettle();

    expect(find.text('My Salary Flex'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('Calendar'))),
      TextDirection.ltr,
    );

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('עברית'));
    await tester.pumpAndSettle();

    expect(store.profile.language, 'he');
    expect(find.text('לוח שנה'), findsOneWidget);
    expect(
      Directionality.of(tester.element(find.text('לוח שנה'))),
      TextDirection.rtl,
    );

    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(find.text('Календарь'), findsOneWidget);
  });

  testWidgets('тема: как на устройстве, светлая, тёмная', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = await AppStore.load();
    await tester.pumpWidget(SalaryApp(store: store));
    await tester.pumpAndSettle();
    ThemeMode mode() =>
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;
    expect(mode(), ThemeMode.system);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(store.profile.theme, 'dark');
    expect(mode(), ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.text('Dark'))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(mode(), ThemeMode.light);
  });
}
