import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'data/app_store.dart';
import 'l10n/app_localizations.dart';
import 'screens/calendar_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    for (final language in Profile.languages)
      initializeDateFormatting(language),
  ]);
  final store = await AppStore.load();
  runApp(SalaryApp(store: store));
}

class SalaryApp extends StatelessWidget {
  const SalaryApp({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF1F7A6D);
    // Язык берётся из профиля и меняется сразу после выбора в кабинете.
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => MaterialApp(
        // Название окна и вкладки не переводим — как у значка приложения.
        title: 'Моя зарплата Flex',
        debugShowCheckedModeBanner: false,
        locale: Locale(store.profile.language),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        themeMode: switch (store.profile.theme) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        },
        theme: ThemeData(colorSchemeSeed: seed, useMaterial3: true),
        darkTheme: ThemeData(
          colorSchemeSeed: seed,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: HomePage(store: store),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.store});

  final AppStore store;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      // На компьютере и планшете не растягиваем интерфейс на всю ширину.
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: IndexedStack(
            index: _tab,
            children: [
              CalendarScreen(store: widget.store),
              ProfileScreen(store: widget.store),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: l.tabCalendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l.tabProfile,
          ),
        ],
      ),
    );
  }
}
