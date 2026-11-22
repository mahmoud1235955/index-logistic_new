import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/app_copy.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';

class IndexLogisticsApp extends StatefulWidget {
  const IndexLogisticsApp({super.key});

  @override
  State<IndexLogisticsApp> createState() => _IndexLogisticsAppState();
}

class _IndexLogisticsAppState extends State<IndexLogisticsApp> {
  AppLanguage _language = AppLanguage.english;

  void _toggleLanguage() => setState(() {
        _language = _language == AppLanguage.english
            ? AppLanguage.arabic
            : AppLanguage.english;
      });

  @override
  Widget build(BuildContext context) {
    final isArabic = _language == AppLanguage.arabic;
    return MaterialApp(
      title: 'Index Logistics',
      debugShowCheckedModeBanner: false,
      theme: IndexTheme.light,
      locale: Locale(_language.languageCode, _language.countryCode.isEmpty ? null : _language.countryCode),
      supportedLocales: AppLanguage.values.map((language) => Locale(language.languageCode, language.countryCode.isEmpty ? null : language.countryCode)),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) => Directionality(
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        child: child ?? const SizedBox.shrink(),
      ),
      home: HomeScreen(
        language: _language,
        onToggleLanguage: _toggleLanguage,
      ),
    );
  }
}
