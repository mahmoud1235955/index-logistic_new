import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/cubit/app_cubit.dart';
import '../../../app/cubit/app_state.dart';
import '../../../core/localization/app_copy.dart';
import '../../../core/theme/app_tokens.dart';
import '../domain/access_flow.dart';
import 'access_brand.dart';
import 'access_copy.dart';
import 'cubit/access_cubit.dart';

class AuthPreviewScreen extends StatelessWidget {
  const AuthPreviewScreen({super.key, required this.initialStep});
  final AccessStep initialStep;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AccessCubit(initialStep: initialStep),
    child: BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) => BlocBuilder<AccessCubit, AccessState>(
        builder: (context, state) =>
            _AuthBody(language: appState.language, state: state),
      ),
    ),
  );
}

class _AuthBody extends StatefulWidget {
  const _AuthBody({required this.language, required this.state});
  final AppLanguage language;
  final AccessState state;
  @override
  State<_AuthBody> createState() => _AuthBodyState();
}

class _AuthBodyState extends State<_AuthBody> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _company = TextEditingController();
  AccessCopy get copy => AccessCopy(widget.language);
  AccessCubit get cubit => context.read<AccessCubit>();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _company.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            if (state.step == AccessStep.signIn ||
                state.step == AccessStep.signUp) {
              Navigator.of(context).pop();
            } else {
              cubit.back();
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const AccessBrand(compact: true),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(constraints.maxWidth < 500 ? 20 : 32),
                child: Form(key: _formKey, child: _buildStep(state)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(AccessState state) {
    final content = switch (state.step) {
      AccessStep.signIn => _credentials(isSignUp: false),
      AccessStep.signUp => _credentials(isSignUp: true),
      AccessStep.forgotPassword => _forgotPassword(),
      AccessStep.verification => _verification(),
      AccessStep.accountType => _accountType(state),
      AccessStep.profileSetup => _profileSetup(),
    };
    if (state.notice == AccessNotice.none) return content;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: _noticePanel(copy.notice(state.notice)),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _heading(String title, String subtitle) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 22),
    ],
  );

  Widget _credentials({required bool isSignUp}) {
    final title = isSignUp ? copy.signUp : copy.signIn;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _heading(title, copy.localOnly),
        if (isSignUp) ...[
          _field(_name, copy.fullName, validator: _required),
          const SizedBox(height: 14),
        ],
        _field(
          _email,
          copy.email,
          keyboard: TextInputType.emailAddress,
          validator: _emailValidator,
        ),
        const SizedBox(height: 14),
        _field(
          _password,
          copy.password,
          obscure: true,
          validator: _passwordValidator,
        ),
        if (!isSignUp)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => cubit.goTo(AccessStep.forgotPassword),
              child: Text(copy.forgot),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: () {
              if (!(_formKey.currentState?.validate() ?? false)) return;
              if (isSignUp) {
                cubit.goTo(AccessStep.verification);
              } else {
                cubit.showNotice(AccessNotice.signInUnavailable);
                _showNotice(AccessNotice.signInUnavailable);
              }
            },
            child: Text(isSignUp ? copy.continueLabel : copy.signIn),
          ),
        ),
        const SizedBox(height: 20),
        _previewFootnote(),
        if (!isSignUp)
          TextButton(
            onPressed: () => cubit.goTo(AccessStep.signUp),
            child: Text(copy.signUp),
          ),
      ],
    );
  }

  Widget _forgotPassword() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(copy.forgot, copy.localOnly),
      _field(
        _email,
        copy.email,
        keyboard: TextInputType.emailAddress,
        validator: _emailValidator,
      ),
      const SizedBox(height: 18),
      FilledButton(
        onPressed: () {
          if (!(_formKey.currentState?.validate() ?? false)) return;
          _showNotice(AccessNotice.recoveryUnavailable);
        },
        child: Text(copy.continueLabel),
      ),
      const SizedBox(height: 20),
      _previewFootnote(),
    ],
  );

  Widget _verification() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(copy.verification, copy.verificationBody),
      _previewFootnote(),
      const SizedBox(height: 18),
      FilledButton(
        onPressed: () => cubit.goTo(AccessStep.accountType),
        child: Text(copy.accessPreview),
      ),
    ],
  );

  Widget _accountType(AccessState state) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(copy.accountType, copy.localOnly),
      RadioGroup<AccountType>(
        groupValue: state.accountType,
        onChanged: (value) {
          if (value != null) cubit.selectAccountType(value);
        },
        child: Column(
          children: AccountType.values
              .map(
                (type) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: RadioListTile<AccountType>(
                    value: type,
                    title: Text(copy.accountTypeLabel(type)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      side: const BorderSide(color: AppTokens.line),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
      const SizedBox(height: 10),
      FilledButton(
        onPressed: state.accountType == null
            ? null
            : () => cubit.goTo(AccessStep.profileSetup),
        child: Text(copy.continueLabel),
      ),
      const SizedBox(height: 20),
      _previewFootnote(),
    ],
  );

  Widget _profileSetup() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _heading(copy.profileSetup, copy.profileBody),
      _field(_name, copy.fullName, validator: _required),
      const SizedBox(height: 14),
      _field(_company, copy.company),
      const SizedBox(height: 18),
      FilledButton(
        onPressed: () {
          if (!(_formKey.currentState?.validate() ?? false)) return;
          _showNotice(AccessNotice.profilePreview);
        },
        child: Text(copy.continueLabel),
      ),
      const SizedBox(height: 20),
      _previewFootnote(),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
    TextInputType? keyboard,
    bool obscure = false,
    String? hint,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboard,
    obscureText: obscure,
    validator: validator,
    textInputAction: TextInputAction.next,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        obscure
            ? Icons.lock_outline
            : keyboard == TextInputType.emailAddress
            ? Icons.alternate_email
            : null,
      ),
    ),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? copy.required : null;
  String? _emailValidator(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return copy.required;
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)
        ? null
        : copy.invalidEmail;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) return copy.required;
    return value.length >= 8 ? null : copy.shortPassword;
  }

  Widget _previewFootnote() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTokens.canvas,
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: AppTokens.green),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            copy.localOnly,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    ),
  );

  Widget _noticePanel(String text) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTokens.greenSoft,
      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      border: Border.all(color: AppTokens.green),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: AppTokens.green),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    ),
  );

  void _showNotice(AccessNotice notice) {
    cubit.showNotice(notice);
  }
}
