import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/home_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState());

  final HomeRepository _repository;

  Future<void> loadHome() async {
    emit(state.copyWith(status: HomeStatus.loading, clearError: true));
    try {
      final sectors = await _repository.getSectors();
      final companies = await _repository.getFeaturedCompanies();
      final isEmpty = sectors.isEmpty && companies.isEmpty;
      emit(
        state.copyWith(
          status: isEmpty ? HomeStatus.empty : HomeStatus.loaded,
          sectors: sectors,
          featuredCompanies: companies,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void selectTab(int index) {
    if (index < 0 || index > 3 || index == state.selectedTab) return;
    emit(state.copyWith(selectedTab: index));
  }
}
