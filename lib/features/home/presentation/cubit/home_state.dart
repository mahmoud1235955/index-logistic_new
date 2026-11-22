import 'package:equatable/equatable.dart';

import '../../../../features/directory/domain/company.dart';
import '../../domain/sector.dart';

enum HomeStatus { initial, loading, loaded, empty, error }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.sectors = const [],
    this.featuredCompanies = const [],
    this.selectedTab = 0,
    this.errorMessage,
  });

  final HomeStatus status;
  final List<Sector> sectors;
  final List<Company> featuredCompanies;
  final int selectedTab;
  final String? errorMessage;

  HomeState copyWith({
    HomeStatus? status,
    List<Sector>? sectors,
    List<Company>? featuredCompanies,
    int? selectedTab,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      sectors: sectors ?? this.sectors,
      featuredCompanies: featuredCompanies ?? this.featuredCompanies,
      selectedTab: selectedTab ?? this.selectedTab,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    sectors,
    featuredCompanies,
    selectedTab,
    errorMessage,
  ];
}
