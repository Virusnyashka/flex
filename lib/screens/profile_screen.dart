import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/app_store.dart';
import '../l10n/app_localizations.dart';
import '../logic/pay_period.dart';
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
    final l = AppLocalizations.of(context);
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
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l.save),
          ),
        ],
      ),
    );
    if (result != null) onSave(result.trim());
  }

  Future<void> _export() async {
    final l = AppLocalizations.of(context);
    final json = widget.store.exportJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.backupCopiedTitle),
        content: Text(l.backupCopiedBody),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.gotIt),
          ),
        ],
      ),
    );
  }

  Future<void> _import() async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.backupRestore),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: l.restoreHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(l.restoreAction),
          ),
        ],
      ),
    );
    if (text == null || text.trim().isEmpty || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final count = await widget.store.importJson(text.trim());
      // После восстановления мог смениться язык — берём строки заново.
      if (!mounted) return;
      final restored = AppLocalizations.of(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(restored.restoredCount(restored.shiftsCount(count))),
        ),
      );
    } on BackupFormatException catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.wrongApp ? l.restoreFailedWrongApp : l.restoreFailedUnreadable,
          ),
        ),
      );
    }
  }

  double? _parseNumber(String s) => double.tryParse(s.replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.profileTitle)),
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
                      title: Text(l.nameLabel),
                      subtitle: Text(
                        profile.name.isEmpty ? l.notSpecified : profile.name,
                      ),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _editText(
                        title: l.nameLabel,
                        initial: profile.name,
                        numeric: false,
                        onSave: (v) => widget.store.updateProfile(
                          profile.copyWith(name: v),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.payments_outlined),
                      title: Text(l.hourlyRateLabel),
                      subtitle: Text(
                        profile.hourlyRate > 0
                            ? formatMoney(l, profile.hourlyRate)
                            : l.rateNotSet,
                      ),
                      trailing: const Icon(Icons.edit_outlined),
                      onTap: () => _editText(
                        title: l.hourlyRateDialogTitle,
                        initial: profile.hourlyRate > 0
                            ? NumberFormat('0.##').format(profile.hourlyRate)
                            : '',
                        numeric: true,
                        suffix: '₪',
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
                    _ChoiceTile<int>(
                      icon: Icons.date_range_outlined,
                      title: l.payPeriodLabel,
                      selected: profile.periodStartDay,
                      options: {
                        // Подписи — диапазоны дат для текущего месяца.
                        for (final day in Profile.periodStartDays)
                          day: () {
                            final example = PayPeriod(now.year, now.month, day);
                            return dateRange(l, example.start, example.lastDay);
                          }(),
                      },
                      onChanged: (day) => widget.store.updateProfile(
                        profile.copyWith(periodStartDay: day),
                      ),
                    ),
                    _ChoiceTile<String>(
                      icon: Icons.language,
                      title: l.languageLabel,
                      selected: profile.language,
                      // Названия языков — на самих языках.
                      options: const {
                        'en': 'English',
                        'he': 'עברית',
                        'ru': 'Русский',
                      },
                      onChanged: (language) => widget.store.updateProfile(
                        profile.copyWith(language: language),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              StepSwitcher(
                title: periodTitle(l, period),
                subtitle: _offset == 0 ? l.currentPeriod : null,
                onPrevious: () => setState(() => _offset--),
                onNext: () => setState(() => _offset++),
              ),
              _ReportView(report: report, rate: profile.hourlyRate),
              const SizedBox(height: 12),
              const _RulesCard(),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.upload_outlined),
                      title: Text(l.backupSave),
                      subtitle: Text(l.backupSaveSubtitle),
                      onTap: _export,
                    ),
                    ListTile(
                      leading: const Icon(Icons.download_outlined),
                      title: Text(l.backupRestore),
                      subtitle: Text(l.backupRestoreSubtitle),
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

/// Пункт кабинета с выбором одного из нескольких вариантов.
class _ChoiceTile<T> extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final T selected;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(leading: Icon(icon), title: Text(title)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SegmentedButton<T>(
            showSelectedIcon: false,
            segments: [
              for (final MapEntry(:key, :value) in options.entries)
                ButtonSegment(
                  value: key,
                  // Длинные подписи (например, на иврите) ужимаются.
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(value, maxLines: 1),
                  ),
                ),
            ],
            selected: {selected},
            onSelectionChanged: (values) => onChanged(values.single),
          ),
        ),
      ],
    );
  }
}

class _ReportView extends StatelessWidget {
  const _ReportView({required this.report, required this.rate});

  final PeriodReport report;
  final double rate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    final dateFormat = DateFormat.MMMEd(l.localeName);
    final weekFormat = DateFormat.MMMd(l.localeName);

    if (report.shifts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(l.noShiftsInPeriod, textAlign: TextAlign.center),
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
                Text(l.grossPay, style: theme.textTheme.labelLarge),
                const SizedBox(height: 6),
                Text(
                  rate > 0
                      ? formatMoney(l, report.amount(rate))
                      : l.setHourlyRate,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.reportSummary(
                    formatHours(l, report.totalHours),
                    l.shiftsCount(report.shifts.length),
                    formatHours(l, report.weightedHours),
                  ),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        _Section(
          title: l.hoursByPercent,
          children: [
            for (final percent in report.percents)
              _row(
                context,
                formatPercent(l, percent),
                formatHours(l, report.minutesByPercent[percent]! / 60),
                rate > 0
                    ? formatMoney(
                        l,
                        report.minutesByPercent[percent]! /
                            60 *
                            percent /
                            100 *
                            rate,
                      )
                    : null,
              ),
          ],
        ),
        _Section(
          title: l.weeksSection,
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
                      '${weekFormat.format(w.start)} – '
                      '${weekFormat.format(w.start.add(const Duration(days: 6)))}',
                    ),
                  ),
                  Text(
                    '${formatHours(l, w.baseMinutes > 2520 ? 42 : w.baseMinutes / 60)} / '
                    '${formatHours(l, 42)}',
                  ),
                ],
              ),
          ],
        ),
        _Section(
          title: l.shiftsSection,
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
                          '${pay.parts.map((p) => '${formatHours(l, p.hours)}×${formatPercent(l, p.percent)}').join(', ')}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formatHours(l, pay.hours)),
                      if (rate > 0)
                        Text(
                          formatMoney(l, pay.amount(rate)),
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
    final l = AppLocalizations.of(context);
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.rule),
        title: Text(l.rulesTitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        shape: const Border(),
        children: [Text(l.rulesText, style: style)],
      ),
    );
  }
}
