import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/cubit/app_cubit.dart';
import 'app/cubit/app_state.dart';
import 'core/localization/app_copy.dart';
import 'core/theme/app_theme.dart';
import 'features/home/data/home_mock_data.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/home/presentation/home_screen.dart';

class IndexLogisticsApp extends StatelessWidget {
  const IndexLogisticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit(),
      child: const _IndexLogisticsAppView(),
    );
  }
}

class _IndexLogisticsAppView extends StatelessWidget {
  const _IndexLogisticsAppView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final language = state.language;
        final isArabic = language == AppLanguage.arabic;
        return MaterialApp(
          title: 'Index Logistics',
          debugShowCheckedModeBanner: false,
          theme: IndexTheme.light,
          locale: Locale(
            language.languageCode,
            language.countryCode.isEmpty ? null : language.countryCode,
          ),
          supportedLocales: AppLanguage.values.map(
            (language) => Locale(
              language.languageCode,
              language.countryCode.isEmpty ? null : language.countryCode,
            ),
          ),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          builder: (context, child) => Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
          home: BlocProvider(
            create: (_) => HomeCubit(HomeMockData())..loadHome(),
            child: HomeScreen(
              language: language,
              onToggleLanguage: context.read<AppCubit>().toggleLanguage,
            ),
          ),
        );
      },
    );
  }
}
