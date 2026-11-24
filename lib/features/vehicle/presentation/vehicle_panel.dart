import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

class VehiclePanel extends StatelessWidget {
  const VehiclePanel({super.key, this.title, this.text, this.child});
  final String? title;
  final String? text;
  final Widget? child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: AppTokens.white,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      border: Border.all(color: AppTokens.line),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title case final heading?) ...[
            Semantics(
              header: true,
              child: Text(
                heading,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: AppTokens.space2),
          ],
          if (text case final body?)
            Text(body, style: Theme.of(context).textTheme.bodyLarge),
          ?child,
        ],
      ),
    ),
  );
}
