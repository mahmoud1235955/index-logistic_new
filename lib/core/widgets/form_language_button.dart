import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/cubit/app_cubit.dart';
import '../localization/app_copy.dart';

AppCopy liveFormCopy(BuildContext context, AppCopy fallback) {
  final app = context.watch<AppCubit?>();
  return app == null ? fallback : AppCopy(app.state.language);
}

class FormLanguageButton extends StatelessWidget {
  const FormLanguageButton({super.key, required this.copy});
  final AppCopy copy;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppCubit?>();
    return app == null
        ? const SizedBox.shrink()
        : TextButton(
            onPressed: app.toggleLanguage,
            child: Text(copy.isArabic ? 'English' : 'العربية'),
          );
  }
}
