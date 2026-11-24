import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/adaptive_content.dart';
import 'trade_copy.dart';

typedef TradePanel = ContentPanel;
typedef TradeGrid = AdaptiveGrid;
typedef TradeValue = LabelValue;

class TradeChoice<T extends Enum> extends StatelessWidget {
  const TradeChoice({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.copy,
    required this.onChanged,
  });
  final String label;
  final T? value;
  final List<T> options;
  final TradeCopy copy;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: AppTokens.space1),
      Semantics(
        label: label,
        child: OutlinedButton(
          onPressed: () async {
            final option = await showDialog<T>(
              context: context,
              builder: (context) => SimpleDialog(
                title: Text(label),
                children: [
                  for (final option in options)
                    SimpleDialogOption(
                      padding: const EdgeInsets.all(AppTokens.space4),
                      onPressed: () => Navigator.of(context).pop(option),
                      child: Text(copy.option(option)),
                    ),
                ],
              ),
            );
            if (context.mounted && option != null) onChanged(option);
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: AppTokens.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            padding: const EdgeInsets.all(AppTokens.space3),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value == null
                      ? copy.tr('Select', 'اختر')
                      : copy.option(value!),
                ),
              ),
              const SizedBox(width: AppTokens.space2),
              const Icon(Icons.expand_more),
            ],
          ),
        ),
      ),
    ],
  );
}
