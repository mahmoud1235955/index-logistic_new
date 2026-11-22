import 'package:equatable/equatable.dart';

import '../../core/localization/app_copy.dart';

class AppState extends Equatable {
  const AppState({this.language = AppLanguage.english});

  final AppLanguage language;

  @override
  List<Object> get props => [language];
}
