import 'package:flutter/widgets.dart';
import 'package:index_logistic/app.dart';
import 'package:index_logistic/features/home/data/home_mock_data.dart';

// Run with --dart-define=INDEX_LOGISTICS_DEMO_STATE=error (or empty/offline).
// This entry point uses local fixtures only; it does not enable a live service.
void main() {
  const scenarioName = String.fromEnvironment(
    'INDEX_LOGISTICS_DEMO_STATE',
    defaultValue: 'error',
  );
  final scenario = HomeMockScenario.values.firstWhere(
    (value) => value.name == scenarioName,
    orElse: () => HomeMockScenario.error,
  );
  runApp(IndexLogisticsApp(homeRepository: HomeMockData(scenario: scenario)));
}
