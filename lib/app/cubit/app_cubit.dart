import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/localization/app_copy.dart';
import 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());

  void toggleLanguage() {
    emit(
      AppState(
        language: state.language == AppLanguage.english
            ? AppLanguage.arabic
            : AppLanguage.english,
      ),
    );
  }
}
