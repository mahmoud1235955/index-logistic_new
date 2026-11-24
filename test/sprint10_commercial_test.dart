import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/core/localization/app_copy.dart';
import 'package:index_logistic/features/journeys/domain/commercial_models.dart';
import 'package:index_logistic/features/journeys/domain/local_workspace.dart';
import 'package:index_logistic/features/journeys/presentation/commercial_board.dart';
import 'package:index_logistic/features/journeys/presentation/quote_workspace.dart';

const copy = AppCopy(AppLanguage.english);

void main() {
  testWidgets('freight draft validates route and resumes saved inputs', (
    tester,
  ) async {
    final workspace = LocalWorkspace();
    addTearDown(workspace.close);
    await tester.pumpWidget(
      MaterialApp(
        home: QuoteWorkspace(copy: copy, workspace: workspace),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('quote-next')));
    await tester.pumpAndSettle();
    expect(find.text('Select a transport mode.'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('quote-origin')), 'Cairo');
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('quote-destination')),
      'Amman',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('quote-save')));
    await tester.pumpAndSettle();
    expect(workspace.state.quote!.text(QuoteField.origin), 'Cairo');
    expect(workspace.state.quote!.text(QuoteField.destination), 'Amman');
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      MaterialApp(
        home: QuoteWorkspace(copy: copy, workspace: workspace),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Cairo'), findsOneWidget);
    expect(find.text('Amman'), findsOneWidget);
  });

  testWidgets('commercial report and block stay local', (tester) async {
    final workspace = LocalWorkspace();
    addTearDown(workspace.close);
    await tester.pumpWidget(
      MaterialApp(
        home: CommercialBoard(
          copy: copy,
          workspace: workspace,
          initialType: CommercialType.buying,
        ),
      ),
    );
    await tester.tap(find.text('Sample fruit purchase request'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Report preview'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Potentially inaccurate'));
    await tester.pumpAndSettle();
    expect(workspace.state.reports.single.reason, ReportReason.inaccurate);
    await tester.tap(find.text('Hide sample source'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Sample fruit purchase request'), findsNothing);
  });
}
