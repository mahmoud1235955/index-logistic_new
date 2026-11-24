import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/adaptive_content.dart' show ContentPanel;
import 'dg_copy.dart';

export '../../../core/widgets/adaptive_content.dart'
    show AdaptiveGrid, ContentPanel, LabelValue;

class DgPage extends StatelessWidget {
  const DgPage({
    super.key,
    required this.title,
    required this.children,
    this.controller,
    this.actions = const [],
  });
  final String title;
  final List<Widget> children;
  final ScrollController? controller;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: actions,
    ),
    body: SafeArea(
      child: ListView(
        controller: controller,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(AppTokens.space4),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1050),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (index, child) in children.indexed) ...[
                    if (index > 0) const SizedBox(height: AppTokens.space3),
                    child,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class DgNotice extends StatelessWidget {
  const DgNotice({super.key, required this.copy});
  final DgCopy copy;

  @override
  Widget build(BuildContext context) =>
      ContentPanel(highlight: true, children: [Text(copy.disclaimer)]);
}

class DgAction extends StatelessWidget {
  const DgAction({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      backgroundColor: AppTokens.white,
      padding: const EdgeInsets.all(AppTokens.space4),
      minimumSize: const Size.fromHeight(64),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
    ),
    child: Row(
      children: [
        Icon(icon),
        const SizedBox(width: AppTokens.space3),
        Expanded(child: Text(title)),
        const SizedBox(width: AppTokens.space2),
        const Icon(Icons.arrow_forward_ios, size: 15),
      ],
    ),
  );
}

class DgChoice<T extends Enum> extends StatelessWidget {
  const DgChoice({
    super.key,
    required this.title,
    required this.options,
    required this.value,
    required this.copy,
    required this.onSelected,
    this.clear,
  });
  final String title;
  final List<T> options;
  final T? value;
  final DgCopy copy;
  final ValueChanged<T> onSelected;
  final VoidCallback? clear;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: AppTokens.space1),
      Semantics(
        label: title,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            backgroundColor: AppTokens.white,
            padding: const EdgeInsets.all(AppTokens.space3),
          ),
          onPressed: () async {
            final result = await showDialog<Enum>(
              context: context,
              builder: (context) => SimpleDialog(
                title: Text(title),
                children: [
                  if (clear != null)
                    SimpleDialogOption(
                      padding: const EdgeInsets.all(AppTokens.space4),
                      onPressed: () => Navigator.of(context).pop(_Clear.all),
                      child: Text(copy.tr('All', 'الكل')),
                    ),
                  for (final option in options)
                    SimpleDialogOption(
                      padding: const EdgeInsets.all(AppTokens.space4),
                      onPressed: () => Navigator.of(context).pop(option),
                      child: Text(copy.option(option)),
                    ),
                ],
              ),
            );
            if (!context.mounted) return;
            if (result is T) onSelected(result);
            if (result == _Clear.all) clear?.call();
          },
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value != null
                      ? copy.option(value!)
                      : clear != null
                      ? copy.tr('All', 'الكل')
                      : copy.tr('Select', 'اختر'),
                ),
              ),
              const Icon(Icons.expand_more),
            ],
          ),
        ),
      ),
    ],
  );
}

enum _Clear { all }
