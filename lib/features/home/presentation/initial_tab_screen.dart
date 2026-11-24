import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/state/app_view_state.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_state_panel.dart';

class InitialTabScreen extends StatelessWidget {
  const InitialTabScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.copy,
    required this.actionLabel,
    required this.onAction,
    this.emptyMessage,
    this.showVisitorMode = false,
    this.actions = const [],
  });

  final String title;
  final String description;
  final IconData icon;
  final AppCopy copy;
  final String actionLabel;
  final VoidCallback onAction;
  final String? emptyMessage;
  final bool showVisitorMode;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppTokens.maxContentWidth),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTokens.white,
                borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                border: Border.all(color: AppTokens.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTokens.greenSoft,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(icon, color: AppTokens.navy),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 22),
                  for (final action in actions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(width: double.infinity, child: action),
                    ),
                  if (showVisitorMode) ...[
                    Text(
                      copy.visitorMode,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                  ],
                  AppStatePanel(
                    state: AppViewState.empty,
                    copy: copy,
                    message: emptyMessage ?? copy.destinationInitialBody,
                    actionLabel: actionLabel,
                    onAction: onAction,
                  ),
                  if (showVisitorMode) ...[
                    const SizedBox(height: 14),
                    Text(
                      copy.previewOnly,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
