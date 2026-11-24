import 'package:equatable/equatable.dart';

enum AccessStep {
  signIn,
  signUp,
  forgotPassword,
  verification,
  accountType,
  profileSetup,
}

enum AccessNotice {
  none,
  signInUnavailable,
  recoveryUnavailable,
  verificationPreview,
  profilePreview,
}

enum AccountType { importer, exporter, serviceProvider }

class AccessState extends Equatable {
  const AccessState({
    this.step = AccessStep.signIn,
    this.notice = AccessNotice.none,
    this.accountType,
  });

  final AccessStep step;
  final AccessNotice notice;
  final AccountType? accountType;

  AccessState copyWith({
    AccessStep? step,
    AccessNotice? notice,
    AccountType? accountType,
  }) => AccessState(
    step: step ?? this.step,
    notice: notice ?? this.notice,
    accountType: accountType ?? this.accountType,
  );

  @override
  List<Object?> get props => [step, notice, accountType];
}
