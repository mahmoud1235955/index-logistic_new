import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class ContentPanel extends StatelessWidget {
  const ContentPanel({
    super.key,
    required this.children,
    this.title,
    this.highlight = false,
  });
  final List<Widget> children;
  final String? title;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppTokens.space4),
    decoration: BoxDecoration(
      color: highlight ? AppTokens.greenSoft : AppTokens.white,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      border: Border.all(color: AppTokens.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title case final heading?) ...[
          Semantics(
            header: true,
            child: Text(heading, style: Theme.of(context).textTheme.titleLarge),
          ),
          const SizedBox(height: AppTokens.space2),
        ],
        ...children,
      ],
    ),
  );
}

class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = AppTokens.space4;
      final two =
          constraints.maxWidth >= MediaQuery.textScalerOf(context).scale(580);
      final width = two
          ? (constraints.maxWidth - gap) / 2
          : constraints.maxWidth;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final child in children)
            SizedBox(
              key: child.key == null ? null : ValueKey(child.key),
              width: width,
              child: child,
            ),
        ],
      );
    },
  );
}

class LabelValue extends StatelessWidget {
  const LabelValue(this.label, this.value, {super.key, this.emphasis = false});
  final String label, value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final style = emphasis ? Theme.of(context).textTheme.titleMedium : null;
    final left = Text(label, style: style);
    final right = Text(value, style: style);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.space1),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <
              MediaQuery.textScalerOf(context).scale(275)) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [left, right],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: left),
              const SizedBox(width: AppTokens.space3),
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: right,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
