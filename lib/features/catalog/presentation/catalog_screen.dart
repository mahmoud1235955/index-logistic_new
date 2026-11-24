import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/state/app_view_state.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_state_panel.dart';
import '../../../core/widgets/index_button.dart';
import '../../dangerous_goods/domain/dg_models.dart';
import '../../dangerous_goods/presentation/dg_copy.dart';
import '../../dangerous_goods/presentation/dg_hub.dart';
import '../../journeys/presentation/category_workspace.dart';
import '../../trade/domain/shipment.dart';
import '../../trade/presentation/trade_copy.dart';
import '../../trade/presentation/trade_screen.dart';
import '../../vehicle/presentation/vehicle_copy.dart';
import '../../vehicle/presentation/vehicle_screen.dart';
import '../data/local_category_repository.dart';
import '../domain/service_category.dart';
import 'catalog_copy.dart';
import 'catalog_cubit.dart';

class CatalogShortcut extends StatelessWidget {
  const CatalogShortcut({super.key, required this.copy, this.workspace});

  final AppCopy copy;
  final CatalogWorkspace? workspace;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: IndexButton(
      label: CatalogCopy(copy).browse,
      icon: Icons.view_list_outlined,
      onPressed: () => Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => CatalogScreen(copy: copy, workspace: workspace),
        ),
      ),
    ),
  );
}

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key, required this.copy, this.workspace});

  final AppCopy copy;
  final CatalogWorkspace? workspace;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => CatalogCubit(const LocalCategoryRepository()),
    child: _CatalogView(copy: CatalogCopy(copy), workspace: workspace),
  );
}

class _CatalogView extends StatefulWidget {
  const _CatalogView({required this.copy, this.workspace});

  final CatalogCopy copy;
  final CatalogWorkspace? workspace;

  @override
  State<_CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<_CatalogView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear(BuildContext context) {
    _controller.clear();
    context.read<CatalogCubit>().search('');
  }

  @override
  Widget build(BuildContext context) {
    final copy = widget.copy;
    return _CatalogPage(
      title: copy.title,
      child: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PreviewNotice(copy: copy),
            const SizedBox(height: AppTokens.space6),
            TextField(
              key: const ValueKey('catalog-search'),
              controller: _controller,
              textInputAction: TextInputAction.search,
              onChanged: context.read<CatalogCubit>().search,
              decoration: InputDecoration(
                labelText: copy.search,
                hintText: copy.searchHint,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: state.query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: copy.app.clearSearch,
                        onPressed: () => _clear(context),
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            Semantics(
              liveRegion: true,
              child: Text(
                copy.count(
                  state.results.length,
                  context.read<CatalogCubit>().repository.categories.length,
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppTokens.space3),
            if (state.results.isEmpty)
              AppStatePanel(
                state: AppViewState.empty,
                copy: copy.app,
                message: copy.noResults,
                actionLabel: copy.app.clearSearch,
                onAction: () => _clear(context),
              )
            else
              _CategoryResults(
                copy: copy,
                categories: state.results,
                workspace: widget.workspace,
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryResults extends StatelessWidget {
  const _CategoryResults({
    required this.copy,
    required this.categories,
    this.workspace,
  });

  final CatalogCopy copy;
  final List<ServiceCategory> categories;
  final CatalogWorkspace? workspace;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = AppTokens.space3;
      final minimum = MediaQuery.textScalerOf(context).scale(320);
      final columns = (constraints.maxWidth / minimum).floor().clamp(1, 3);
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final category in categories)
            SizedBox(
              width: width,
              child: _CategoryCard(
                key: ValueKey(category.id),
                copy: copy,
                category: category,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (_) => CategoryDetailsScreen(
                        copy: copy,
                        category: category,
                        workspace: workspace,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    },
  );
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    super.key,
    required this.copy,
    required this.category,
    required this.onTap,
  });

  final CatalogCopy copy;
  final ServiceCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    elevation: 0,
    color: AppTokens.white,
    shape: RoundedRectangleBorder(
      side: const BorderSide(color: AppTokens.line),
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 120),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.space4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryId(id: category.id),
                    const SizedBox(height: AppTokens.space2),
                    Text(
                      copy.name(category),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(copy.type(category.type)),
                  ],
                ),
              ),
              const SizedBox(width: AppTokens.space2),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    ),
  );
}

class CategoryDetailsScreen extends StatelessWidget {
  const CategoryDetailsScreen({
    super.key,
    required this.copy,
    required this.category,
    this.workspace,
  });

  final CatalogCopy copy;
  final ServiceCategory category;
  final CatalogWorkspace? workspace;

  static const _related = {
    'CAT-03': ['CAT-31'],
    'CAT-08': ['CAT-11'],
    'CAT-11': ['CAT-08', 'CAT-27'],
    'CAT-27': ['CAT-28', 'CAT-31'],
    'CAT-31': ['CAT-03', 'CAT-27', 'CAT-28'],
    'CAT-33': ['CAT-34'],
    'CAT-34': ['CAT-33'],
  };

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).textTheme;
    final future = category.futureCapability;
    final relatedIds = _related[category.id] ?? const [];
    final related = const LocalCategoryRepository().categories.where(
      (item) => relatedIds.contains(item.id),
    );
    return _CatalogPage(
      title: copy.title,
      detail: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _CategoryId(id: category.id),
          ),
          const SizedBox(height: AppTokens.space2),
          Text(copy.name(category), style: typography.headlineMedium),
          const SizedBox(height: AppTokens.space1),
          Text(copy.type(category.type), style: typography.bodyLarge),
          const SizedBox(height: AppTokens.space6),
          _PreviewNotice(copy: copy),
          const SizedBox(height: AppTokens.space6),
          _DetailPanel(
            title: copy.scope,
            text: copy.description(category),
            footnote:
                '${copy.phase} ${category.referencePhase.name.toUpperCase()}',
          ),
          if (const {
            'CAT-33',
            'CAT-09',
            'CAT-10',
            'CAT-11',
            'CAT-18',
            'CAT-34',
          }.contains(category.id)) ...[
            const SizedBox(height: AppTokens.space3),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IndexButton(
                key: const ValueKey('catalog-dg-hub'),
                label: DgCopy(copy.app).title,
                icon: Icons.warning_amber_outlined,
                onPressed: () => openDgHub(
                  context,
                  copy.app,
                  mode: switch (category.id) {
                    'CAT-09' => DgMode.sea,
                    'CAT-10' => DgMode.air,
                    'CAT-11' => DgMode.road,
                    _ => null,
                  },
                ),
              ),
            ),
          ],
          if (category.id == 'CAT-27' ||
              category.id == 'CAT-28' ||
              category.id == 'CAT-31') ...[
            const SizedBox(height: AppTokens.space3),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IndexButton(
                key: const ValueKey('catalog-trade-calculator'),
                label: TradeCopy(copy.app).title,
                icon: Icons.calculate_outlined,
                onPressed: () =>
                    openTrade(context, copy.app, switch (category.id) {
                      'CAT-27' => TradeMode.freight,
                      'CAT-28' => TradeMode.export,
                      _ => TradeMode.landed,
                    }),
              ),
            ),
          ],
          if (category.id == 'CAT-03' || category.id == 'CAT-31') ...[
            const SizedBox(height: AppTokens.space3),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: IndexButton(
                key: const ValueKey('catalog-vehicle-import'),
                icon: Icons.directions_car_outlined,
                label: VehicleCopy(copy.app).open,
                onPressed: () => openVehicleImport(context, copy.app),
              ),
            ),
          ],
          if (workspace case final local?)
            CategoryWorkspaceEntry(
              copy: copy.app,
              category: category,
              workspace: local,
            ),
          if (future != null) ...[
            const SizedBox(height: AppTokens.space3),
            _DetailPanel(
              title: copy.future,
              text: copy.capability(future),
              footnote: future.phase.name.toUpperCase(),
            ),
          ],
          if (related.isNotEmpty) ...[
            const SizedBox(height: AppTokens.space6),
            Text(copy.related, style: typography.titleLarge),
            const SizedBox(height: AppTokens.space2),
            for (final item in related)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.space2),
                child: _CategoryCard(
                  copy: copy,
                  category: item,
                  onTap: () =>
                      Navigator.of(context).pushReplacement<void, void>(
                        MaterialPageRoute(
                          builder: (_) => CategoryDetailsScreen(
                            copy: copy,
                            category: item,
                            workspace: workspace,
                          ),
                        ),
                      ),
                ),
              ),
          ],
          const SizedBox(height: AppTokens.space6),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const BackButtonIcon(),
              label: Text(copy.back),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogPage extends StatelessWidget {
  const _CatalogPage({
    required this.title,
    required this.child,
    this.detail = false,
  });

  final String title;
  final Widget child;
  final bool detail;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
    ),
    body: SafeArea(
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(AppTokens.space4),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: detail ? 840 : AppTokens.maxContentWidth,
              ),
              child: SizedBox(width: double.infinity, child: child),
            ),
          ),
        ],
      ),
    ),
  );
}

class _CategoryId extends StatelessWidget {
  const _CategoryId({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) => Text(
    id,
    textDirection: TextDirection.ltr,
    style: Theme.of(context).textTheme.labelLarge?.copyWith(
      color: AppTokens.navy,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _PreviewNotice extends StatelessWidget {
  const _PreviewNotice({required this.copy});

  final CatalogCopy copy;

  @override
  Widget build(BuildContext context) => _DetailPanel(
    title: copy.preview,
    text: copy.notice,
    color: AppTokens.greenSoft,
  );
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.title,
    required this.text,
    this.footnote,
    this.color = AppTokens.white,
  });

  final String title;
  final String text;
  final String? footnote;
  final Color color;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color: AppTokens.line),
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTokens.space2),
          Text(text, style: Theme.of(context).textTheme.bodyLarge),
          if (footnote case final note?) ...[
            const SizedBox(height: AppTokens.space3),
            Text(note, style: Theme.of(context).textTheme.labelLarge),
          ],
        ],
      ),
    ),
  );
}
