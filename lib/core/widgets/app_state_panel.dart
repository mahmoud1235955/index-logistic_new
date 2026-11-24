import 'package:flutter/material.dart';

import '../localization/app_copy.dart';
import '../state/app_view_state.dart';
import '../theme/app_tokens.dart';

class AppStatePanel extends StatelessWidget {
  const AppStatePanel({
    super.key,
    required this.state,
    required this.copy,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final AppViewState state;
  final AppCopy copy;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final icon = switch (state) {
      AppViewState.loading => null,
      AppViewState.empty => Icons.inbox_outlined,
      AppViewState.error => Icons.error_outline_rounded,
      AppViewState.offline => Icons.cloud_off_outlined,
      AppViewState.expired => Icons.hourglass_empty_rounded,
      AppViewState.permissionDenied => Icons.lock_outline_rounded,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTokens.white,
        border: Border.all(color: AppTokens.line),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (state == AppViewState.loading &&
              !MediaQuery.disableAnimationsOf(context))
            CircularProgressIndicator(semanticsLabel: copy.stateTitle(state))
          else if (state == AppViewState.loading)
            Semantics(
              label: copy.stateTitle(state),
              child: Icon(
                Icons.hourglass_top_rounded,
                size: 38,
                color: AppTokens.navy,
              ),
            )
          else
            Icon(icon, size: 38, color: AppTokens.navy),
          const SizedBox(height: 14),
          Text(
            copy.stateTitle(state),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            message ?? copy.stateMessage(state),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (onAction != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(actionLabel ?? copy.stateAction(state)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
