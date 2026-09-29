import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Заголовок со стрелками «назад / вперёд» — для месяцев и периодов.
class StepSwitcher extends StatelessWidget {
  const StepSwitcher({
    super.key,
    required this.title,
    required this.onPrevious,
    required this.onNext,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);
    // Иконки-шевроны сами зеркалятся в RTL (иврит).
    return Row(
      children: [
        IconButton(
          tooltip: l.back,
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrevious,
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (subtitle != null)
                Text(subtitle!, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        IconButton(
          tooltip: l.forward,
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
        ),
      ],
    );
  }
}
