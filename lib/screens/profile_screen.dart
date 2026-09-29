import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/app_store.dart';
import '../logic/period_report.dart';
import '../widgets/format.dart';
import '../widgets/step_switcher.dart';

/// Личный кабинет: ставка, отчёт и расчёт зарплаты за период.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.store});

  final AppStore store;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Сдвиг от текущего расчётного периода: 0 — текущий, -1 — прошлый.
  int _offset = 0;

  Future<void> _editText({
    required String title,
    required String initial,
    required bool numeric,
    required void Function(String) onSave,
    String? suffix,
  }) async {
    final controller = TextEditingController(text: initial);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: InputDecoration(suffixText: suffix),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    if (result != null) onSave(result.trim());
  }

  Future<void> _export() async {
    final json = widget.store.exportJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Копия скопирована'),
        content: const Text(
          'Данные скопированы в буфер обмена. Вставьте их в Заметки '
          'или отправьте себе в сообщении, чтобы не потерять.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  Future<void> _import() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Восстановить из копии'),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Вставьте сюда текст резервной копии',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Восстановить'),
          ),
        ],
      ),
    );
    if (text == null || text.trim().isEmpty || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final count = await widget.store.importJson(text.trim());
      messenger.showSnackBar(
        SnackBar(content: Text('Восстановлено: ${shiftsCount(count)}')),
      );
    } on FormatException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Не получилось: ${e.message}')),
      );
    }
  }

  double? _parseNumber(String s) => double.tryParse(s.replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Личный кабинет')),
      body: ListenableBuilder(
        listenable: widget.store,
        builder: (context, _) {
          final profile = widget.store.profile;
          final now = DateTime.now();
          final current = widget.store.periodContaining(now);
          final period = widget.store.periodStartingIn(
            current.start.year,
            current.start.month + _offset,
          );
          final report = widget.store.report(period);
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('Имя'),
                      subtitle: Text(
                        profile.name.isEmpty ? 'не указано' : profile.name,
                      ),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _editText(
                        title: 'Имя',
                        initial: profile.name,
                        numeric: false,
                        onSave: (v) => widget.store.updateProfile(
                          profile.copyWith(name: v),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.payments_outlined),
                      title: const Text('Часовая ставка (100%)'),
                      subtitle: Text(
                        profile.hourlyRate > 0
                            ? formatMoney(profile.hourlyRate, profile.currency)
                            : 'не указана — нажмите, чтобы указать',
                      ),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _editText(
                        title: 'Часовая ставка',
                        initial: profile.hourlyRate > 0
                            ? NumberFormat('0.##').format(profile.hourlyRate)
                            : '',
                        numeric: true,
                        suffix: profile.currency,
                        onSave: (v) {
                          final rate = _parseNumber(v);
                          if (rate != null && rate >= 0) {
                            widget.store.updateProfile(
                              profile.copyWith(hourlyRate: rate),
                            );
                          }
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.currency_exchange),
                      title: const Text('Валюта'),
                      subtitle: Text(profile.currency),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _editText(
                        title: 'Валюта',
                        initial: profile.currency,
                        numeric: false,
                        onSave: (v) {
                          if (v.isNotEmpty) {
                            widget.store.updateProfile(
                              profile.copyWith(currency: v),
                            );
                          }
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.date_range_outlined),
                      title: const Text('Расчётный период'),
                      subtitle: Text(
                        'с ${profile.periodStartDay} числа '
                        'по ${profile.periodStartDay - 1 == 0 ? 'конец месяца' : '${profile.periodStartDay - 1} число следующего'}',
                      ),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _editText(
                        title: 'Период начинается с числа',
                        initial: '${profile.periodStartDay}',
                        numeric: true,
                        suffix: '(1–28)',
                        onSave: (v) {
                          final day = _parseNumber(v)?.round();
                          if (day != null && day >= 1 && day <= 28) {
                            widget.store.updateProfile(
                              profile.copyWith(periodStartDay: day),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              StepSwitcher(
                title: periodTitle(period),
                subtitle: _offset == 0 ? 'текущий период' : null,
                onPrevious: () => setState(() => _offset--),
                onNext: () => setState(() => _offset++),
              ),
              _ReportView(
                report: report,
                rate: profile.hourlyRate,
                currency: profile.currency,
              ),
              const SizedBox(height: 12),
              const _RulesCard(),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.upload_outlined),
                      title: const Text('Сохранить резервную копию'),
                      subtitle: const Text('Копирует все смены и настройки'),
                      onTap: _export,
                    ),
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: const Text('Восстановить из копии'),
                      subtitle: const Text('Заменяет текущие данные'),
                      onTap: _import,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView({
    required this.report,
    required this.rate,
    required this.currency,
  });

  final PeriodReport report;
  final double rate;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM, EE', 'ru');

    if (report.shifts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'В этом периоде смен нет.\nЗаполните часы в календаре.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: theme.colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Зарплата за период (брутто)',
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  rate > 0
                      ? formatMoney(report.amount(rate), currency)
                      : 'Укажите часовую ставку',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${formatHours(report.totalHours)} отработано · '
                  '${shiftsCount(report.shifts.length)} · '
                  '${formatHours(report.weightedHours)} в пересчёте на 100%',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        _Section(
          title: 'Часы по процентам',
          children: [
            for (final percent in report.percents)
              _row(
                context,
                formatPercent(percent),
                formatHours(report.minutesByPercent[percent]! / 60),
                rate > 0
                    ? formatMoney(
                        report.minutesByPercent[percent]! /
                            60 *
                            percent /
                            100 *
                            rate,
                        currency,
                      )
                    : null,
              ),
          ],
        ),
        _Section(
          title: 'Недели (норма 42 ч на 100%)',
          children: [
            for (final w in report.weeks)
              Row(
                children: [
                  Icon(
                    w.normReached
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: w.normReached
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${DateFormat('d MMM', 'ru').format(w.start)} – '
                      '${DateFormat('d MMM', 'ru').format(w.start.add(const Duration(days: 6)))}',
                    ),
                  ),
                  Text(
                    '${formatHours(w.baseMinutes > 2520 ? 42 : w.baseMinutes / 60)} / 42 ч',
                  ),
                ],
              ),
          ],
        ),
        _Section(
          title: 'Смены',
          children: [
            for (final pay in report.shifts)
              Row(
                children: [
                  Icon(
                    shiftIcon(pay.shift.type),
                    size: 18,
                    color: shiftColor(pay.shift.type),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(capitalize(dateFormat.format(pay.shift.date))),
                        Text(
                          '${formatTime(pay.shift.startMinutes)}–'
                          '${formatTime(pay.shift.endMinutes)} · '
                          '${pay.parts.map((p) => '${formatHours(p.hours)}×${formatPercent(p.percent)}').join(', ')}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatHours(pay.hours)),
                      if (rate > 0)
                        Text(
                          formatMoney(pay.amount(rate), currency),
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _row(BuildContext context, String a, String b, String? c) {
    return Row(
      children: [
        SizedBox(width: 72, child: Text(a)),
        Expanded(child: Text(b)),
        if (c != null) Text(c),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final child in children)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: child,
              ),
          ],
        ),
      ),
    );
  }
}

class _RulesCard extends StatelessWidget {
  const _RulesCard();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.rule),
        title: const Text('Правила расчёта'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        shape: const Border(),
        children: [
          Text(
            'Зарплата считается за расчётный период (по умолчанию с 20 числа '
            'по 19 число следующего месяца). Неделя — с воскресенья по субботу. '
            'Часы считаются от начала до конца смены, перерывы не вычитаются.\n\n'
            'Утренняя смена (7:00–16:15, доп. часы до 19:15): '
            '8,4 ч — 100%, 2 ч — 125%, дальше — 150%.\n\n'
            'Утро+ (7:00–19:00) и Вечер (16:00–23:45) считаются по той же '
            'таблице, что и утренняя смена.\n\n'
            'Ночная смена (19:00–7:15): 3 ч — 100%, 4 ч — 142,5%, '
            '2 ч — 178,1%, остальное — 213,7%.\n\n'
            'Пятница (7:00–13:00, опция до 16:15): если норма 42 ч на 100% '
            'за неделю выполнена — 2 ч по 125%, остальное по 150%. '
            'Иначе — 100% до восполнения 42 ч, затем 125% и 150%.\n\n'
            'Исход субботы: если норма выполнена — 7 ч по 142,5%, '
            '2 ч по 178,1%, остальное до 7:15 по 213,7%. '
            'Иначе — 100% до 22:00; после 22:00 до восполнения 42 ч — 142,5%; '
            'после восполнения 2 ч по 178,1% и далее 213,7%.\n\n'
            'В норму 42 ч засчитываются часы на 100% утренних и ночных смен '
            'и часы пятницы/субботы, которыми норма восполняется.',
            style: style,
          ),
        ],
      ),
    );
  }
}
