import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/cubit/app_cubit.dart';
import 'app/cubit/app_state.dart';
import 'core/localization/app_copy.dart';
import 'core/theme/app_theme.dart';
import 'features/access/presentation/splash_screen.dart';
import 'features/access/presentation/welcome_screen.dart';
import 'features/home/data/home_mock_data.dart';
import 'features/home/domain/home_repository.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/home/presentation/home_screen.dart';

class IndexLogisticsApp extends StatelessWidget {
  const IndexLogisticsApp({
    super.key,
    this.homeRepository,
    this.showSplash = false,
  });

  final HomeRepository? homeRepository;
  final bool showSplash;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppCubit(),
      child: _IndexLogisticsAppView(
        homeRepository: homeRepository,
        showSplash: showSplash,
      ),
    );
  }
}

class _IndexLogisticsAppView extends StatelessWidget {
  const _IndexLogisticsAppView({
    required this.homeRepository,
    required this.showSplash,
  });

  final HomeRepository? homeRepository;
  final bool showSplash;

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
          locale: language.locale,
          supportedLocales: const [
            AppLanguage.english,
            AppLanguage.arabic,
          ].map((language) => language.locale),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          builder: (context, child) => Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
          routes: {
            '/home': (_) => _HomeDestination(homeRepository: homeRepository),
          },
          home: showSplash
              ? SplashScreen(
                  language: language,
                  onReady: (splashContext) {
                    Navigator.of(splashContext).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const WelcomeScreen(),
                      ),
                    );
                  },
                )
              : _HomeDestination(homeRepository: homeRepository),
        );
      },
    );
  }
}

class _HomeDestination extends StatelessWidget {
  const _HomeDestination({required this.homeRepository});

  final HomeRepository? homeRepository;

  @override
  Widget build(BuildContext context) => BlocBuilder<AppCubit, AppState>(
    builder: (context, state) => BlocProvider(
      create: (_) =>
          HomeCubit(homeRepository ?? const HomeMockData())..loadHome(),
      child: HomeScreen(
        language: state.language,
        onToggleLanguage: context.read<AppCubit>().toggleLanguage,
      ),
    ),
  );
}
