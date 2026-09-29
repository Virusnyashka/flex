import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/app_store.dart';
import '../logic/pay_calculator.dart';
import '../models/shift.dart';
import '../widgets/format.dart';

Future<void> showShiftEditor(
  BuildContext context,
  AppStore store,
  DateTime day,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => ShiftEditor(store: store, day: day),
  );
}

/// Ввод смены за день с предварительным расчётом оплаты.
class ShiftEditor extends StatefulWidget {
  const ShiftEditor({super.key, required this.store, required this.day});

  final AppStore store;
  final DateTime day;

  @override
  State<ShiftEditor> createState() => _ShiftEditorState();
}

class _ShiftEditorState extends State<ShiftEditor> {
  late final bool _exists;
  late Shift _shift;

  @override
  void initState() {
    super.initState();
    final existing = widget.store.shiftOn(widget.day);
    _exists = existing != null;
    _shift = existing ?? widget.store.newShift(widget.day);
  }

  void _setType(ShiftType type) =>
      setState(() => _shift = widget.store.newShift(widget.day, type));

  Future<void> _pickTime({required bool start}) async {
    final current = start ? _shift.startMinutes : _shift.endMinutes;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current ~/ 60, minute: current % 60),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    final minutes = picked.hour * 60 + picked.minute;
    setState(() {
      _shift = start
          ? _shift.copyWith(startMinutes: minutes)
          : _shift.copyWith(endMinutes: minutes);
    });
  }

  Future<void> _save() async {
    await widget.store.saveShift(_shift);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    await widget.store.deleteShift(widget.day);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = widget.store.profile;
    final pay = widget.store.preview(_shift);
    final title = capitalize(DateFormat.MMMMEEEEd('ru').format(widget.day));

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in ShiftType.values)
                  ChoiceChip(
                    avatar: Icon(shiftIcon(t), size: 18, color: shiftColor(t)),
                    label: Text(t.title),
                    selected: _shift.type == t,
                    onSelected: (_) => _setType(t),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: 'Начало',
                    value: formatTime(_shift.startMinutes),
                    onTap: () => _pickTime(start: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeField(
                    label: _shift.endMinutes <= _shift.startMinutes
                        ? 'Конец (след. день)'
                        : 'Конец',
                    value: formatTime(_shift.endMinutes),
                    onTap: () => _pickTime(start: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _PayPreview(
              pay: pay,
              rate: profile.hourlyRate,
              currency: profile.currency,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (_exists)
                  TextButton.icon(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Удалить'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: const Text('Сохранить'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.schedule),
        ),
        child: Text(value, style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}

class _PayPreview extends StatelessWidget {
  const _PayPreview({
    required this.pay,
    required this.rate,
    required this.currency,
  });

  final ShiftPay pay;
  final double rate;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = pay.baseMinutesAfter / 60;
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Оплачиваемых часов', style: theme.textTheme.bodyMedium),
                const Spacer(),
                Text(
                  formatHours(pay.hours),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(),
            for (final part in pay.parts)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text(formatHours(part.hours)),
                    Text(
                      '  × ${formatPercent(part.percent)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (rate > 0)
                      Text(formatMoney(part.weightedHours * rate, currency)),
                  ],
                ),
              ),
            if (rate > 0) ...[
              const Divider(),
              Row(
                children: [
                  Text('За смену', style: theme.textTheme.titleSmall),
                  const Spacer(),
                  Text(
                    formatMoney(pay.amount(rate), currency),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Норма недели на 100%: ${formatHours(base > 42 ? 42 : base)} из 42 ч',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
