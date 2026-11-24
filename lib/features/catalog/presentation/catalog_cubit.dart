import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/local_category_repository.dart';
import '../domain/service_category.dart';

class CatalogState {
  const CatalogState(this.query, this.results);

  final String query;
  final List<ServiceCategory> results;
}

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this.repository)
    : super(CatalogState('', repository.categories));

  final LocalCategoryRepository repository;

  void search(String value) {
    final terms = _normalize(value).split(' ').where((term) => term.isNotEmpty);
    final results = repository.categories.where((category) {
      final searchable = _normalize(
        '${category.id} ${category.nameAr} ${category.nameEn}',
      );
      return terms.every(searchable.contains);
    });
    emit(CatalogState(value, List.unmodifiable(results)));
  }

  static String _normalize(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[\u0640\u064B-\u065F\u0670]'), '')
      .replaceAll(RegExp('[أإآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAllMapped(RegExp('[٠-٩۰-۹]'), (match) {
        final digit = match[0]!.codeUnitAt(0);
        return (digit >= 0x06F0 ? digit - 0x06F0 : digit - 0x0660).toString();
      })
      .replaceAll(RegExp(r'[-\u2010-\u2015]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
