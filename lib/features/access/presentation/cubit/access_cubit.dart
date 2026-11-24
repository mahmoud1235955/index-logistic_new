import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/access_flow.dart';

class AccessCubit extends Cubit<AccessState> {
  AccessCubit({AccessStep initialStep = AccessStep.signIn})
    : super(AccessState(step: initialStep));

  void goTo(AccessStep step) =>
      emit(state.copyWith(step: step, notice: AccessNotice.none));

  void back() {
    final previous = switch (state.step) {
      AccessStep.signIn || AccessStep.signUp => null,
      AccessStep.forgotPassword => AccessStep.signIn,
      AccessStep.verification => AccessStep.signUp,
      AccessStep.accountType => AccessStep.verification,
      AccessStep.profileSetup => AccessStep.accountType,
    };
    if (previous != null) goTo(previous);
  }

  void selectAccountType(AccountType type) =>
      emit(state.copyWith(accountType: type, notice: AccessNotice.none));

  void showNotice(AccessNotice notice) => emit(state.copyWith(notice: notice));
}
