import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/theme/app_tokens.dart';
import 'access_brand.dart';
import 'access_copy.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.language,
    required this.onReady,
  });
  final AppLanguage language;
  final ValueChanged<BuildContext> onReady;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onReady(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final copy = AccessCopy(widget.language);
    return Scaffold(
      backgroundColor: AppTokens.navy,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AccessBrand(inverse: true),
              const SizedBox(height: 28),
              const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTokens.white,
                ),
              ),
              const SizedBox(height: 14),
              Semantics(
                liveRegion: true,
                child: Text(
                  copy.localOnly,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppTokens.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
