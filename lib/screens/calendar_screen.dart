import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../logic/pay_calculator.dart';
import '../logic/pay_period.dart';
import '../models/shift.dart';
import '../widgets/format.dart';
import '../widgets/step_switcher.dart';
import 'shift_editor.dart';

/// Календарь месяца: нажатие на день открывает ввод часов.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, required this.store});

  final AppStore store;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const _weekdays = ['Вс', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];

  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  Future<void> _openDay(DateTime day) =>
      showShiftEditor(context, widget.store, day);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Моя зарплата Flex')),
      body: ListenableBuilder(
        listenable: widget.store,
        builder: (context, _) {
          final store = widget.store;
          final profile = store.profile;
          final current = store.periodContaining(DateTime.now());
          // Два расчётных периода, которые попадают на этот месяц.
          final periods = [
            store.periodStartingIn(_month.year, _month.month - 1),
            store.periodStartingIn(_month.year, _month.month),
          ];
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            children: [
              StepSwitcher(
                title: monthTitle(_month.year, _month.month),
                onPrevious: () => setState(
                  () => _month = DateTime(_month.year, _month.month - 1),
                ),
                onNext: () => setState(
                  () => _month = DateTime(_month.year, _month.month + 1),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < 7; i++)
                    Expanded(
                      child: Center(
                        child: Text(
                          _weekdays[i],
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: i >= 5
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              _buildGrid(context),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  for (final t in ShiftType.values)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: shiftColor(t),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(t.shortTitle, style: theme.textTheme.bodySmall),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Расчётные периоды', style: theme.textTheme.titleSmall),
              const SizedBox(height: 4),
              for (final period in periods)
                _PeriodTile(
                  period: period,
                  isCurrent: period == current,
                  hours: store.report(period).totalHours,
                  amount: profile.hourlyRate > 0
                      ? formatMoney(
                          store.report(period).amount(profile.hourlyRate),
                          profile.currency,
                        )
                      : 'укажите ставку',
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final first = DateTime(_month.year, _month.month);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = first.weekday % 7;
    final cells = ((leading + daysInMonth) / 7).ceil() * 7;
    final today = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 0.72,
      ),
      itemCount: cells,
      itemBuilder: (context, index) {
        final dayNumber = index - leading + 1;
        if (dayNumber < 1 || dayNumber > daysInMonth) {
          return const SizedBox.shrink();
        }
        final day = DateTime(_month.year, _month.month, dayNumber);
        final isToday =
            day.year == today.year &&
            day.month == today.month &&
            day.day == today.day;
        return _DayCell(
          day: day,
          pay: widget.store.payOn(day),
          isToday: isToday,
          onTap: () => _openDay(day),
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.pay,
    required this.isToday,
    required this.onTap,
  });

  final DateTime day;
  final ShiftPay? pay;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shift = pay?.shift;
    final color = shift == null ? null : shiftColor(shift.type);
    return Material(
      color:
          color?.withValues(alpha: 0.16) ??
          theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isToday
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Column(
            children: [
              Text(
                '${day.day}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (shift != null) ...[
                Icon(shiftIcon(shift.type), size: 14, color: color),
                const SizedBox(height: 2),
                FittedBox(
                  child: Text(
                    formatHours(pay!.hours),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PeriodTile extends StatelessWidget {
  const _PeriodTile({
    required this.period,
    required this.isCurrent,
    required this.hours,
    required this.amount,
  });

  final PayPeriod period;
  final bool isCurrent;
  final double hours;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: isCurrent ? theme.colorScheme.primaryContainer : null,
      child: ListTile(
        title: Text(periodTitle(period)),
        subtitle: Text(
          isCurrent
              ? 'Текущий период · ${formatHours(hours)}'
              : formatHours(hours),
        ),
        trailing: Text(amount, style: theme.textTheme.titleMedium),
      ),
    );
  }
}
