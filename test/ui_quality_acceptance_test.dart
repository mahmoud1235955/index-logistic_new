import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/app.dart';
import 'package:index_logistic/core/localization/app_copy.dart';
import 'package:index_logistic/core/state/app_view_state.dart';
import 'package:index_logistic/core/theme/app_theme.dart';
import 'package:index_logistic/core/theme/app_tokens.dart';
import 'package:index_logistic/core/widgets/app_state_panel.dart';

void main() {
  test('brand palette and keyboard focus styling match the specification', () {
    expect(AppTokens.navy, const Color(0xFF12304A));
    expect(AppTokens.white, const Color(0xFFFFFFFF));
    expect(AppTokens.green, const Color(0xFF17806A));
    expect(AppTokens.canvas, const Color(0xFFF5F8FA));
    expect(AppTokens.ink, const Color(0xFF172B3A));
    expect(IndexTheme.light.focusColor, AppTokens.focus.withValues(alpha: .22));
    final focusState = {WidgetState.focused};
    final buttonStyles = [
      IndexTheme.light.filledButtonTheme.style,
      IndexTheme.light.outlinedButtonTheme.style,
      IndexTheme.light.textButtonTheme.style,
      IndexTheme.light.iconButtonTheme.style,
    ];
    for (final style in buttonStyles) {
      expect(
        style?.side?.resolve(focusState),
        const BorderSide(color: AppTokens.focus, width: 2),
      );
    }
    final focusedBorder =
        IndexTheme.light.inputDecorationTheme.focusedBorder
            as OutlineInputBorder;
    expect(focusedBorder.borderSide.color, AppTokens.focus);
    expect(focusedBorder.borderSide.width, 2);
  });

  test('brand text and state colors meet WCAG AA contrast pairs', () {
    const pairs = <(Color, Color, double)>[
      (AppTokens.ink, AppTokens.white, 4.5),
      (AppTokens.muted, AppTokens.white, 4.5),
      (AppTokens.muted, AppTokens.canvas, 4.5),
      (AppTokens.green, AppTokens.white, 4.5),
      (AppTokens.green, AppTokens.greenSoft, 4.5),
      (AppTokens.navy, AppTokens.white, 4.5),
      (AppTokens.navy, AppTokens.canvas, 4.5),
      (Color(0xFFD7E1E8), Color(0xFF0A2035), 4.5),
      (AppTokens.focus, AppTokens.white, 3),
    ];

    for (final (foreground, background, minimum) in pairs) {
      expect(
        _contrast(foreground, background),
        greaterThanOrEqualTo(minimum),
        reason: '$foreground on $background must meet $minimum:1',
      );
    }
  });

  testWidgets('loading panel respects reduced-motion preference', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: AppStatePanel(
              state: AppViewState.loading,
              copy: const AppCopy(AppLanguage.english),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.hourglass_top_rounded), findsOneWidget);
    expect(find.text('Loading'), findsOneWidget);
  });

  testWidgets('footer brand remains readable on the navy surface', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const IndexLogisticsApp());
    await tester.pumpAndSettle();

    final footerText = find.text(const AppCopy(AppLanguage.english).footer);
    final homeScroll = find.byKey(const ValueKey('home-page-scroll'));
    for (
      var attempt = 0;
      attempt < 8 && footerText.evaluate().isEmpty;
      attempt++
    ) {
      await tester.drag(homeScroll, const Offset(0, -600));
      await tester.pumpAndSettle();
    }
    expect(footerText, findsOneWidget);
    await Scrollable.ensureVisible(
      tester.element(footerText),
      duration: Duration.zero,
    );
    await tester.pump();
    final brandLabels = tester.widgetList<Text>(
      find.text(const AppCopy(AppLanguage.english).brand),
    );
    expect(
      brandLabels.any((label) => label.style?.color == Colors.white),
      isTrue,
    );
  });
}

double _contrast(Color foreground, Color background) {
  final first = _luminance(foreground);
  final second = _luminance(background);
  return (first > second ? first + 0.05 : second + 0.05) /
      (first > second ? second + 0.05 : first + 0.05);
}

double _luminance(Color color) {
  double channel(int value) {
    final normalized = value / 255;
    return normalized <= 0.04045
        ? normalized / 12.92
        : math.pow((normalized + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel((color.r * 255).round()) +
      0.7152 * channel((color.g * 255).round()) +
      0.0722 * channel((color.b * 255).round());
}
