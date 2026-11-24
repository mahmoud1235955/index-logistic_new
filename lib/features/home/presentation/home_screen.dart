import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/state/app_view_state.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_state_panel.dart';
import '../../../core/widgets/index_search_field.dart';
import '../../../core/widgets/section_heading.dart';
import '../../catalog/presentation/catalog_screen.dart';
import '../../journeys/domain/local_workspace.dart';
import '../../journeys/presentation/account_workspace.dart';
import '../../journeys/presentation/commercial_board.dart';
import '../../journeys/presentation/directory_workspace.dart';
import '../../journeys/presentation/workspace_widgets.dart';
import '../../vehicle/presentation/vehicle_screen.dart';
import '../../../features/directory/domain/company.dart';
import '../../../features/directory/presentation/company_card.dart';
import '../../../features/directory/presentation/company_details_screen.dart';
import '../domain/home_entry_point.dart';
import '../domain/sector.dart';
import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';
import 'entry_point_preview_screen.dart';
import 'initial_tab_screen.dart';
import 'sector_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.language,
    required this.onToggleLanguage,
  });

  final AppLanguage language;
  final VoidCallback onToggleLanguage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _searchController;
  final _workspace = LocalWorkspace();

  AppLanguage get language => widget.language;
  VoidCallback get onToggleLanguage => widget.onToggleLanguage;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _workspace.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy(language);
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, homeState) {
        if (_searchController.text != homeState.searchQuery) {
          _searchController.value = TextEditingValue(
            text: homeState.searchQuery,
            selection: TextSelection.collapsed(
              offset: homeState.searchQuery.length,
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 760;
            final tablet = constraints.maxWidth < 1080;
            return PopScope<Object?>(
              canPop: homeState.selectedTab == 0,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop && homeState.selectedTab != 0) {
                  context.read<HomeCubit>().selectTab(0);
                }
              },
              child: Scaffold(
                appBar: mobile ? _mobileBar(context, copy) : null,
                body: Column(
                  children: [
                    if (!mobile)
                      _desktopHeader(
                        context,
                        copy,
                        tablet,
                        homeState.selectedTab,
                      ),
                    Expanded(
                      child: _tabContent(
                        context,
                        copy,
                        homeState,
                        mobile: mobile,
                        tablet: tablet,
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: mobile
                    ? _mobileNavigation(context, copy, homeState.selectedTab)
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _tabContent(
    BuildContext context,
    AppCopy copy,
    HomeState state, {
    required bool mobile,
    required bool tablet,
  }) {
    return switch (state.selectedTab) {
      0 => _homePage(context, copy, state, mobile: mobile, tablet: tablet),
      1 => _discoverPage(context, copy, state, mobile: mobile, tablet: tablet),
      2 => InitialTabScreen(
        title: copy.communityTab,
        description: copy.communityDescription,
        icon: Icons.groups_outlined,
        emptyMessage: copy.communityDescription,
        copy: copy,
        actionLabel: copy.discoverTab,
        onAction: () => context.read<HomeCubit>().selectTab(1),
        actions: [
          WorkspaceLink(
            key: const ValueKey('community-board-entry'),
            label: copy.local(
              'Browse commercial community preview',
              'تصفح معاينة المجتمع التجاري',
            ),
            onTap: () => openWorkspace(
              context,
              CommercialBoard(copy: copy, workspace: _workspace),
            ),
          ),
        ],
      ),
      3 => InitialTabScreen(
        title: copy.messagesTab,
        description: copy.messagesDescription,
        icon: Icons.forum_outlined,
        emptyMessage: copy.messagesDescription,
        copy: copy,
        actionLabel: copy.homeLabel,
        onAction: () => context.read<HomeCubit>().selectTab(0),
        actions: [
          WorkspaceLink(
            key: const ValueKey('messages-preview-entry'),
            label: copy.local(
              'Open local conversations',
              'افتح المحادثات المحلية',
            ),
            onTap: () => openWorkspace(
              context,
              MessagesWorkspace(copy: copy, workspace: _workspace),
            ),
          ),
        ],
      ),
      _ => InitialTabScreen(
        title: copy.myAccountTab,
        description: copy.accountDescription,
        icon: Icons.person_outline_rounded,
        showVisitorMode: true,
        copy: copy,
        emptyMessage: copy.accountDescription,
        actionLabel: copy.homeLabel,
        onAction: () => context.read<HomeCubit>().selectTab(0),
        actions: [
          WorkspaceLink(
            key: const ValueKey('account-preview-entry'),
            label: copy.local('Open account workspace', 'افتح مساحة الحساب'),
            onTap: () => openWorkspace(
              context,
              AccountWorkspace(
                copy: copy,
                workspace: _workspace,
                onToggleLanguage: onToggleLanguage,
              ),
            ),
          ),
        ],
      ),
    };
  }

  Widget _homePage(
    BuildContext context,
    AppCopy copy,
    HomeState state, {
    required bool mobile,
    required bool tablet,
  }) {
    final cubit = context.read<HomeCubit>();
    return CustomScrollView(
      key: const ValueKey('home-page-scroll'),
      slivers: [
        SliverToBoxAdapter(
          child: _contentFrame(
            mobile: mobile,
            tablet: tablet,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 18),
                _welcomeBanner(context, copy),
                const SizedBox(height: 22),
                _entryPoints(
                  context,
                  copy,
                  mobile: mobile,
                  tablet: tablet,
                  onDiscover: () => cubit.selectTab(1),
                ),
                const SizedBox(height: 16),
                CatalogShortcut(
                  key: const ValueKey('home-catalog-shortcut'),
                  copy: copy,
                  workspace: (
                    session: _workspace,
                    sectors: state.sectors,
                    companies: state.featuredCompanies,
                  ),
                ),
                const SizedBox(height: 32),
                if (state.status == HomeStatus.loaded) ...[
                  _sectors(
                    context,
                    copy,
                    state.sectors,
                    mobile: mobile,
                    onSectorSelected: (sector) => _openSector(
                      context,
                      copy,
                      sector,
                      state.featuredCompanies,
                    ),
                    onSeeAll: () => cubit.selectTab(1),
                  ),
                  const SizedBox(height: 38),
                  _companies(
                    context,
                    copy,
                    state.featuredCompanies,
                    mobile: mobile,
                    tablet: tablet,
                    onSeeAll: () {
                      cubit.setSearchQuery('');
                      cubit.selectTab(1);
                    },
                  ),
                ] else
                  _homeStatusContent(context, state, copy),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: _footer(context, copy)),
      ],
    );
  }

  Widget _discoverPage(
    BuildContext context,
    AppCopy copy,
    HomeState state, {
    required bool mobile,
    required bool tablet,
  }) {
    final query = state.searchQuery.trim().toLowerCase();
    final sectors = state.sectors.where((sector) {
      return query.isEmpty ||
          sector.titleEn.toLowerCase().contains(query) ||
          sector.titleAr.contains(state.searchQuery.trim());
    }).toList();
    final companies = state.featuredCompanies.where((company) {
      return query.isEmpty ||
          company.name.toLowerCase().contains(query) ||
          company.businessActivity.toLowerCase().contains(query) ||
          (company.productCategory?.toLowerCase().contains(query) ?? false) ||
          (company.country?.toLowerCase().contains(query) ?? false) ||
          company.location.toLowerCase().contains(query);
    }).toList();

    return CustomScrollView(
      key: const ValueKey('discover-page-scroll'),
      slivers: [
        SliverToBoxAdapter(
          child: _contentFrame(
            mobile: mobile,
            tablet: tablet,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                _pageHeading(
                  context,
                  copy.discoverTab,
                  copy.discoverDescription,
                ),
                const SizedBox(height: 20),
                IndexSearchField(
                  hint: copy.searchHint,
                  controller: _searchController,
                  onChanged: context.read<HomeCubit>().setSearchQuery,
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                ),
                const SizedBox(height: 16),
                CatalogShortcut(
                  key: const ValueKey('discover-catalog-shortcut'),
                  copy: copy,
                  workspace: (
                    session: _workspace,
                    sectors: state.sectors,
                    companies: state.featuredCompanies,
                  ),
                ),
                if (state.status == HomeStatus.loaded) ...[
                  const SizedBox(height: 12),
                  WorkspaceLink(
                    key: const ValueKey('sector-filter-entry'),
                    label: copy.local(
                      'Industry sector filters',
                      'مرشحات قطاعات الصناعة',
                    ),
                    onTap: () => openWorkspace(
                      context,
                      DirectoryWorkspace(
                        copy: copy,
                        workspace: _workspace,
                        sectors: state.sectors,
                        companies: state.featuredCompanies,
                        sectorsFirst: true,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                if (state.status != HomeStatus.loaded)
                  _homeStatusContent(context, state, copy)
                else ...[
                  if (sectors.isNotEmpty)
                    _sectors(
                      context,
                      copy,
                      sectors,
                      mobile: mobile,
                      onSectorSelected: (sector) => _openSector(
                        context,
                        copy,
                        sector,
                        state.featuredCompanies,
                      ),
                      onSeeAll: () =>
                          context.read<HomeCubit>().setSearchQuery(''),
                    ),
                  if (companies.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _companies(
                      context,
                      copy,
                      companies,
                      mobile: mobile,
                      tablet: tablet,
                      onSeeAll: () =>
                          context.read<HomeCubit>().setSearchQuery(''),
                    ),
                  ],
                  if (sectors.isEmpty && companies.isEmpty)
                    AppStatePanel(
                      state: AppViewState.empty,
                      copy: copy,
                      message: copy.noResults,
                      actionLabel: copy.clearSearch,
                      onAction: () =>
                          context.read<HomeCubit>().setSearchQuery(''),
                    ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: _footer(context, copy)),
      ],
    );
  }

  PreferredSizeWidget _mobileBar(BuildContext context, AppCopy copy) => AppBar(
    automaticallyImplyLeading: false,
    titleSpacing: 18,
    title: _brand(copy, compact: true),
    actions: [
      IconButton(
        tooltip: copy.searchHint,
        onPressed: () => _showSearch(context, copy),
        icon: const Icon(Icons.search_rounded),
      ),
      IconButton(
        tooltip: copy.languageButton,
        onPressed: onToggleLanguage,
        icon: const Icon(Icons.language_rounded),
      ),
      const SizedBox(width: 8),
    ],
  );

  Widget _desktopHeader(
    BuildContext context,
    AppCopy copy,
    bool tablet,
    int selectedTab,
  ) {
    final cubit = context.read<HomeCubit>();
    final labels = [
      copy.homeTab,
      copy.discoverTab,
      copy.communityTab,
      copy.messagesTab,
      copy.myAccountTab,
    ];
    return Container(
      color: AppTokens.white,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.maxContentWidth,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tablet ? 20 : 40,
                vertical: 10,
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  _brand(copy),
                  if (!tablet)
                    SizedBox(
                      width: 210,
                      child: IndexSearchField(
                        hint: copy.searchHint,
                        compact: true,
                        controller: _searchController,
                        onChanged: cubit.setSearchQuery,
                        onSubmitted: (_) => cubit.selectTab(1),
                      ),
                    ),
                  for (var index = 0; index < labels.length; index++)
                    _navLink(
                      labels[index],
                      selectedTab == index,
                      () => cubit.selectTab(index),
                    ),
                  TextButton(
                    onPressed: onToggleLanguage,
                    child: Text(copy.languageButton),
                  ),
                  _visitorBadge(context, copy),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _visitorBadge(BuildContext context, AppCopy copy) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: AppTokens.canvas,
      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.visibility_outlined, size: 16, color: AppTokens.muted),
        const SizedBox(width: 6),
        Text(
          copy.visitorMode,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppTokens.navy),
        ),
      ],
    ),
  );

  Widget _brand(
    AppCopy copy, {
    bool compact = false,
    bool onDarkSurface = false,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: compact ? 36 : 40,
        height: compact ? 36 : 40,
        decoration: BoxDecoration(
          color: AppTokens.navy,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.route_rounded, color: Colors.white, size: 22),
      ),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            copy.brand,
            style: TextStyle(
              fontSize: 15,
              letterSpacing: 1.7,
              height: 1.1,
              fontWeight: FontWeight.w800,
              color: onDarkSurface ? AppTokens.white : AppTokens.navy,
            ),
          ),
          Text(
            copy.brandSub,
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.8,
              height: 1.45,
              fontWeight: FontWeight.w700,
              color: onDarkSurface ? const Color(0xFFD7E1E8) : AppTokens.muted,
            ),
          ),
        ],
      ),
    ],
  );

  Widget _navLink(String label, bool selected, VoidCallback onPressed) =>
      TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: selected ? AppTokens.navy : AppTokens.muted,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      );

  Widget _welcomeBanner(BuildContext context, AppCopy copy) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 19),
    decoration: BoxDecoration(
      color: AppTokens.navyDeep,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.homeWelcomeTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontSize: 25,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          copy.homeWelcomeBody,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFFD7E1E8),
            fontSize: 14,
          ),
        ),
      ],
    ),
  );

  Widget _entryPoints(
    BuildContext context,
    AppCopy copy, {
    required bool mobile,
    required bool tablet,
    required VoidCallback onDiscover,
  }) {
    const points = HomeEntryPoint.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(
          title: copy.quickAccess,
          subtitle: copy.entryPointSubtitle,
          action: copy.seeAll,
          onAction: onDiscover,
        ),
        GridView.builder(
          key: const ValueKey('home-entry-points'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: points.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: mobile
                ? 2
                : tablet
                ? 3
                : 3,
            mainAxisExtent: _scaledCardHeight(context, mobile ? 94 : 98),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final point = points[index];
            return _entryPointCard(
              context,
              copy,
              point,
              mobile: mobile,
              onTap: () => _openEntryPoint(context, copy, point),
            );
          },
        ),
      ],
    );
  }

  Widget _entryPointCard(
    BuildContext context,
    AppCopy copy,
    HomeEntryPoint point, {
    required bool mobile,
    required VoidCallback onTap,
  }) => Material(
    color: AppTokens.white,
    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
    child: InkWell(
      key: ValueKey('entry-${point.name}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? 8 : 14,
          vertical: mobile ? 5 : 10,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppTokens.line),
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        child: mobile
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTokens.greenSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _entryIcon(point),
                      color: AppTokens.navy,
                      size: 19,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    copy.entryPointTitle(point),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTokens.greenSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _entryIcon(point),
                      color: AppTokens.navy,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      copy.entryPointTitle(point),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: AppTokens.muted,
                  ),
                ],
              ),
      ),
    ),
  );

  IconData _entryIcon(HomeEntryPoint point) => switch (point) {
    HomeEntryPoint.exporter => Icons.outbound_outlined,
    HomeEntryPoint.importer => Icons.input_rounded,
    HomeEntryPoint.vehicles => Icons.directions_car_outlined,
    HomeEntryPoint.jobs => Icons.work_outline_rounded,
    HomeEntryPoint.community => Icons.groups_outlined,
    HomeEntryPoint.leopard => Icons.local_shipping_outlined,
  };

  void _openEntryPoint(
    BuildContext context,
    AppCopy copy,
    HomeEntryPoint point,
  ) {
    final cubit = context.read<HomeCubit>();
    if (point == HomeEntryPoint.community) {
      cubit.selectTab(2);
      return;
    }
    if (point == HomeEntryPoint.vehicles) {
      openVehicleImport(context, copy);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EntryPointPreviewScreen(
          entryPoint: point,
          copy: copy,
          workspace: _workspace,
          sectors: cubit.state.sectors,
          companies: cubit.state.featuredCompanies,
          onExploreSectors: () {
            Navigator.of(context).pop();
            cubit.selectTab(1);
          },
        ),
      ),
    );
  }

  Widget _sectors(
    BuildContext context,
    AppCopy copy,
    List<Sector> sectors, {
    required bool mobile,
    required ValueChanged<Sector> onSectorSelected,
    required VoidCallback onSeeAll,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionHeading(
        title: copy.sectorsTitle,
        subtitle: copy.sectorsSubtitle,
        action: copy.seeAll,
        onAction: onSeeAll,
      ),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sectors.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: mobile ? 2 : 4,
          mainAxisExtent: _scaledCardHeight(context, mobile ? 94 : 98),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final sector = sectors[index];
          return _sectorCard(
            context,
            sector,
            copy.isArabic,
            onTap: () => onSectorSelected(sector),
          );
        },
      ),
    ],
  );

  Widget _sectorCard(
    BuildContext context,
    Sector sector,
    bool arabic, {
    required VoidCallback onTap,
  }) => Material(
    color: AppTokens.white,
    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
    child: InkWell(
      key: ValueKey('sector-${sector.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppTokens.line),
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: sector.tint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(sector.icon, color: AppTokens.navy, size: 21),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                arabic ? sector.titleAr : sector.titleEn,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontSize: 13, height: 1.3),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_back_ios_new_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: 12,
              color: AppTokens.muted,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _companies(
    BuildContext context,
    AppCopy copy,
    List<Company> companies, {
    required bool mobile,
    required bool tablet,
    required VoidCallback onSeeAll,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionHeading(
        title: copy.featuredTitle,
        subtitle: copy.featuredSubtitle,
        action: copy.seeAll,
        onAction: onSeeAll,
      ),
      if (companies.isEmpty)
        AppStatePanel(
          state: AppViewState.empty,
          copy: copy,
          message: copy.noCompanies,
          actionLabel: copy.seeAll,
          onAction: onSeeAll,
        )
      else
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: companies
              .map(
                (company) => SizedBox(
                  width: mobile
                      ? double.infinity
                      : tablet
                      ? 320
                      : 340,
                  child: CompanyCard(
                    company: company,
                    copy: copy,
                    onPrimaryAction: () => _openCompany(context, copy, company),
                  ),
                ),
              )
              .toList(),
        ),
    ],
  );

  void _openCompany(BuildContext context, AppCopy copy, Company company) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CompanyDetailsScreen(company: company, copy: copy),
      ),
    );
  }

  void _openSector(
    BuildContext context,
    AppCopy copy,
    Sector sector,
    List<Company> companies,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SectorDetailsScreen(
          sector: sector,
          companies: companies,
          copy: copy,
          onHome: () {
            Navigator.of(context).pop();
            context.read<HomeCubit>().selectTab(0);
          },
        ),
      ),
    );
  }

  Widget _homeStatusContent(
    BuildContext context,
    HomeState state,
    AppCopy copy,
  ) {
    final homeCubit = context.read<HomeCubit>();
    final viewState = switch (state.status) {
      HomeStatus.initial || HomeStatus.loading => AppViewState.loading,
      HomeStatus.empty => AppViewState.empty,
      HomeStatus.error => AppViewState.error,
      HomeStatus.offline => AppViewState.offline,
      HomeStatus.expired => AppViewState.expired,
      HomeStatus.permissionDenied => AppViewState.permissionDenied,
      HomeStatus.loaded => null,
    };
    if (viewState == null) return const SizedBox.shrink();

    final canRetry = switch (viewState) {
      AppViewState.error || AppViewState.offline => true,
      _ => false,
    };
    final canChangeDestination =
        viewState == AppViewState.expired ||
        viewState == AppViewState.permissionDenied ||
        viewState == AppViewState.empty;
    final destinationTab = state.selectedTab == 0 ? 1 : 0;
    return AppStatePanel(
      state: viewState,
      copy: copy,
      message: viewState == AppViewState.empty ? copy.homeEmpty : null,
      actionLabel: canChangeDestination
          ? destinationTab == 1
                ? copy.exploreSectors
                : copy.homeLabel
          : null,
      onAction: canRetry
          ? homeCubit.loadHome
          : canChangeDestination
          ? () => homeCubit.selectTab(destinationTab)
          : null,
    );
  }

  Widget _footer(BuildContext context, AppCopy copy) => Container(
    color: AppTokens.navyDeep,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppTokens.maxContentWidth),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 10,
          children: [
            _brand(copy, onDarkSurface: true),
            Text(
              copy.footer,
              style: const TextStyle(color: Color(0xFFDAE5EC), fontSize: 13),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _mobileNavigation(
    BuildContext context,
    AppCopy copy,
    int selectedTab,
  ) => NavigationBar(
    selectedIndex: selectedTab,
    onDestinationSelected: context.read<HomeCubit>().selectTab,
    destinations: [
      NavigationDestination(
        icon: const Icon(Icons.home_outlined),
        selectedIcon: const Icon(Icons.home_rounded),
        label: copy.homeTab,
      ),
      NavigationDestination(
        icon: const Icon(Icons.explore_outlined),
        selectedIcon: const Icon(Icons.explore_rounded),
        label: copy.discoverTab,
      ),
      NavigationDestination(
        icon: const Icon(Icons.groups_outlined),
        selectedIcon: const Icon(Icons.groups_rounded),
        label: copy.communityTab,
      ),
      NavigationDestination(
        icon: const Icon(Icons.forum_outlined),
        selectedIcon: const Icon(Icons.forum_rounded),
        label: copy.messagesTab,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: copy.myAccountTab,
      ),
    ],
  );

  Widget _pageHeading(BuildContext context, String title, String description) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(description, style: Theme.of(context).textTheme.bodyLarge),
        ],
      );

  Widget _contentFrame({
    required bool mobile,
    required bool tablet,
    required Widget child,
  }) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppTokens.maxContentWidth),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: mobile
              ? 16
              : tablet
              ? 24
              : 40,
        ),
        child: child,
      ),
    ),
  );

  Future<void> _showSearch(BuildContext context, AppCopy copy) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (sheetContext) => _SearchSheet(
          copy: copy,
          initialQuery: context.read<HomeCubit>().state.searchQuery,
          onChanged: context.read<HomeCubit>().setSearchQuery,
          onSearch: (query) {
            context.read<HomeCubit>().setSearchQuery(query);
            context.read<HomeCubit>().selectTab(1);
            Navigator.of(sheetContext).pop();
          },
        ),
      );

  double _scaledCardHeight(BuildContext context, double baseHeight) {
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    return baseHeight * scale;
  }
}

class _SearchSheet extends StatefulWidget {
  const _SearchSheet({
    required this.copy,
    required this.initialQuery,
    required this.onChanged,
    required this.onSearch,
  });

  final AppCopy copy;
  final String initialQuery;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSearch;

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      24,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 24,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IndexSearchField(
          hint: widget.copy.searchHint,
          controller: _controller,
          onChanged: (value) {
            widget.onChanged(value);
          },
          onSubmitted: widget.onSearch,
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => widget.onSearch(_controller.text),
            icon: const Icon(Icons.search_rounded),
            label: Text(widget.copy.discoverTab),
          ),
        ),
      ],
    ),
  );
}
