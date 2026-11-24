import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/cubit/app_cubit.dart';
import '../../../app/cubit/app_state.dart';
import '../../../core/theme/app_tokens.dart';
import '../domain/access_flow.dart';
import 'access_brand.dart';
import 'access_copy.dart';
import 'auth_preview_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<AppCubit, AppState>(
    builder: (context, appState) {
      final copy = AccessCopy(appState.language);
      return Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 800;
              final content = ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: EdgeInsets.all(wide ? 36 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: TextButton.icon(
                          onPressed: context.read<AppCubit>().toggleLanguage,
                          icon: const Icon(Icons.language),
                          label: Text(copy.languageLabel),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const AccessBrand(),
                      const SizedBox(height: 42),
                      Text(
                        copy.welcome,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        copy.welcomeBody,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      _PreviewNotice(text: copy.localOnly),
                      const SizedBox(height: 20),
                      Semantics(
                        button: true,
                        label: copy.continueGuest,
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            key: const ValueKey('continue-as-guest'),
                            onPressed: () => Navigator.of(
                              context,
                            ).pushNamedAndRemoveUntil('/home', (_) => false),
                            icon: const Icon(Icons.explore_outlined),
                            label: Text(copy.continueGuest),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        copy.guestNote,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 28),
                      OutlinedButton(
                        onPressed: () => _openAuth(context, AccessStep.signIn),
                        child: Text(copy.signIn),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => _openAuth(context, AccessStep.signUp),
                        child: Text(copy.signUp),
                      ),
                    ],
                  ),
                ),
              );
              if (wide) {
                return Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: AppTokens.navy,
                        padding: const EdgeInsets.all(56),
                        child: const Align(
                          alignment: AlignmentDirectional.bottomStart,
                          child: AccessBrand(inverse: true),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(child: content),
                      ),
                    ),
                  ],
                );
              }
              return Center(child: SingleChildScrollView(child: content));
            },
          ),
        ),
      );
    },
  );

  void _openAuth(BuildContext context, AccessStep step) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => AuthPreviewScreen(initialStep: step),
        ),
      );
}

class _PreviewNotice extends StatelessWidget {
  const _PreviewNotice({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTokens.greenSoft,
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      border: Border.all(color: AppTokens.line),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: AppTokens.green),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    ),
  );
}
