import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/app/cubit/app_cubit.dart';
import 'package:index_logistic/core/localization/app_copy.dart';

void main() {
  test('toggles the app language between English and Arabic', () async {
    final cubit = AppCubit();
    expect(cubit.state.language, AppLanguage.english);

    cubit.toggleLanguage();
    expect(cubit.state.language, AppLanguage.arabic);

    cubit.toggleLanguage();
    expect(cubit.state.language, AppLanguage.english);
    await cubit.close();
  });
}
