import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_logistic/features/directory/domain/company.dart';
import 'package:index_logistic/features/home/domain/home_repository.dart';
import 'package:index_logistic/features/home/domain/sector.dart';
import 'package:index_logistic/features/home/presentation/cubit/home_cubit.dart';
import 'package:index_logistic/features/home/presentation/cubit/home_state.dart';

void main() {
  test('emits loading then loaded with repository content', () async {
    final sectorsCompleter = Completer<List<Sector>>();
    final companiesCompleter = Completer<List<Company>>();
    final sector = Sector(
      id: 'freight',
      titleEn: 'Freight',
      titleAr: 'fixture',
      icon: Icons.local_shipping_outlined,
      tint: Colors.blue,
    );
    const company = Company(
      name: 'Sample Company',
      category: 'Logistics',
      location: 'Alexandria',
      initials: 'SC',
      accent: 0xFF1D5B8F,
    );
    final cubit = HomeCubit(
      _FakeHomeRepository(
        sectors: sectorsCompleter.future,
        companies: companiesCompleter.future,
      ),
    );

    final loading = cubit.loadHome();
    expect(cubit.state.status, HomeStatus.loading);
    sectorsCompleter.complete([sector]);
    companiesCompleter.complete([company]);
    await loading;

    expect(cubit.state.status, HomeStatus.loaded);
    expect(cubit.state.sectors, [sector]);
    expect(cubit.state.featuredCompanies, [company]);
    await cubit.close();
  });

  test('emits empty when both repository collections are empty', () async {
    final cubit = HomeCubit(
      _FakeHomeRepository(
        sectors: Future.value(const []),
        companies: Future.value(const []),
      ),
    );

    await cubit.loadHome();

    expect(cubit.state.status, HomeStatus.empty);
    await cubit.close();
  });

  test('emits error when the repository throws', () async {
    final cubit = HomeCubit(
      _FakeHomeRepository(
        sectors: Future.error(Exception('fixture failure')),
        companies: Future.value(const []),
      ),
    );

    await cubit.loadHome();

    expect(cubit.state.status, HomeStatus.error);
    expect(cubit.state.errorMessage, contains('fixture failure'));
    await cubit.close();
  });

  test(
    'tracks selection within the existing four navigation destinations',
    () async {
      final cubit = HomeCubit(
        _FakeHomeRepository(
          sectors: Future.value(const []),
          companies: Future.value(const []),
        ),
      );

      cubit.selectTab(2);
      expect(cubit.state.selectedTab, 2);
      cubit.selectTab(4);
      expect(cubit.state.selectedTab, 2);

      await cubit.close();
    },
  );
}

class _FakeHomeRepository implements HomeRepository {
  const _FakeHomeRepository({required this.sectors, required this.companies});

  final Future<List<Sector>> sectors;
  final Future<List<Company>> companies;

  @override
  Future<List<Sector>> getSectors() => sectors;

  @override
  Future<List<Company>> getFeaturedCompanies() => companies;
}
