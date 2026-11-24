import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/adaptive_content.dart';
import '../../directory/domain/company.dart';
import '../../directory/presentation/company_details_screen.dart';
import '../../home/domain/sector.dart';
import '../domain/local_workspace.dart';
import 'quote_workspace.dart';
import 'workspace_widgets.dart';

enum DirectoryKind { products, companies }

typedef ProductSample = ({
  String id,
  String english,
  String arabic,
  String country,
  String sector,
  String category,
  String hs,
});

const _products = <ProductSample>[
  (
    id: 'sample-berries',
    english: 'Sample strawberry product',
    arabic: 'منتج فراولة توضيحي',
    country: 'Egypt',
    sector: 'SEC-01',
    category: 'Fruit',
    hs: 'DEMO-HS-01',
  ),
  (
    id: 'sample-cotton',
    english: 'Sample cotton fabric',
    arabic: 'نسيج قطني توضيحي',
    country: 'Egypt',
    sector: 'SEC-02',
    category: 'Textiles',
    hs: 'DEMO-HS-02',
  ),
  (
    id: 'sample-furniture',
    english: 'Sample wooden furniture',
    arabic: 'أثاث خشبي توضيحي',
    country: 'Jordan',
    sector: 'SEC-08',
    category: 'Furniture',
    hs: 'DEMO-HS-08',
  ),
];

class DirectoryFilter {
  const DirectoryFilter({
    this.kind = DirectoryKind.products,
    this.query = '',
    this.country,
    this.sector,
    this.category,
  });
  final DirectoryKind kind;
  final String query;
  final String? country, sector, category;

  bool matches(
    String name,
    String? country,
    String? sector,
    String? category,
  ) =>
      (this.country == null || country == this.country) &&
      (this.sector == null || sector == this.sector) &&
      (this.category == null || category == this.category) &&
      name.toLowerCase().contains(query.trim().toLowerCase());
}

class DirectoryCubit extends Cubit<DirectoryFilter> {
  DirectoryCubit([DirectoryKind kind = DirectoryKind.products])
    : super(DirectoryFilter(kind: kind));
  void kind(DirectoryKind kind) => emit(
    DirectoryFilter(
      kind: kind,
      query: state.query,
      country: state.country,
      sector: state.sector,
    ),
  );
  void query(String query) => emit(
    DirectoryFilter(
      kind: state.kind,
      query: query,
      country: state.country,
      sector: state.sector,
      category: state.category,
    ),
  );
  void filters(String? country, String? sector, String? category) => emit(
    DirectoryFilter(
      kind: state.kind,
      query: state.query,
      country: country,
      sector: sector,
      category: category,
    ),
  );
}

class DirectoryWorkspace extends StatelessWidget {
  const DirectoryWorkspace({
    super.key,
    required this.copy,
    required this.workspace,
    required this.sectors,
    required this.companies,
    this.exporter,
    this.sectorsFirst = false,
  });
  final AppCopy copy;
  final LocalWorkspace workspace;
  final List<Sector> sectors;
  final List<Company> companies;
  final bool? exporter;
  final bool sectorsFirst;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => DirectoryCubit(
      sectorsFirst ? DirectoryKind.companies : DirectoryKind.products,
    ),
    child: BlocBuilder<DirectoryCubit, DirectoryFilter>(
      builder: (context, filter) {
        final cubit = context.read<DirectoryCubit>();
        final products = filter.kind == DirectoryKind.products;
        final countries = <String>{
          for (final item in _products) item.country,
          for (final company in companies) ?company.country,
        }.toList()..sort();
        final categories = products
            ? {for (final item in _products) item.category}
            : {for (final company in companies) ?company.productCategory};
        final rows = [
          if (products)
            for (final item in _products)
              if (filter.matches(
                '${item.english} ${item.arabic} ${item.hs} ${item.category}',
                item.country,
                item.sector,
                item.category,
              ))
                WorkspaceLink(
                  label: copy.local(item.english, item.arabic),
                  onTap: () => _product(context, item),
                ),
          if (!products)
            for (final company in companies)
              if (filter.matches(
                '${company.name} ${company.businessActivity} ${company.businessActivityAr ?? ''} ${company.productCategory ?? ''} ${company.productCategoryAr ?? ''}',
                company.country,
                company.sectorId,
                company.productCategory,
              ))
                WorkspaceLink(
                  label: company.name,
                  onTap: () => _company(context, company),
                ),
        ];
        return WorkspacePage(
          title: sectorsFirst && exporter == null
              ? copy.local('Industry sector filters', 'مرشحات قطاعات الصناعة')
              : copy.local('Commercial discovery', 'الاكتشاف التجاري'),
          children: [
            WorkspaceNotice(
              copy: copy,
              message: copy.local(
                'Sample profiles represent potential contacts. Sample product codes are for search practice.',
                'تمثل الملفات التوضيحية جهات اتصال محتملة. رموز المنتجات مخصصة لتجربة البحث.',
              ),
            ),
            if (exporter != null)
              ContentPanel(
                title: exporter!
                    ? copy.local(
                        'Exporter profile preview',
                        'معاينة ملف المصدر',
                      )
                    : copy.local(
                        'Importer profile preview',
                        'معاينة ملف المستورد',
                      ),
                children: [
                  Text(
                    copy.local(
                      'Browse potential trading partners and product categories.',
                      'تصفح الشركاء التجاريين المحتملين وفئات المنتجات.',
                    ),
                  ),
                ],
              ),
            TextField(
              key: const ValueKey('workspace-directory-search'),
              onChanged: cubit.query,
              decoration: InputDecoration(
                labelText: copy.local(
                  'Product, company or sample HS code',
                  'منتج أو شركة أو رمز جمركي توضيحي',
                ),
              ),
            ),
            AdaptiveGrid(
              children: [
                WorkspaceSelect(
                  title: copy.local('Record type', 'نوع السجل'),
                  options: DirectoryKind.values,
                  selected: filter.kind,
                  copy: copy,
                  label: (kind) => kind == DirectoryKind.products
                      ? copy.local('Products', 'المنتجات')
                      : copy.local('Companies', 'الشركات'),
                  onChanged: (value) => cubit.kind(value!),
                ),
                WorkspaceSelect(
                  title: copy.local('Industry sector', 'قطاع الصناعة'),
                  options: sectors.map((sector) => sector.id),
                  selected: filter.sector,
                  copy: copy,
                  canClear: true,
                  label: (id) {
                    final sector = sectors.firstWhere(
                      (sector) => sector.id == id,
                    );
                    return copy.local(sector.titleEn, sector.titleAr);
                  },
                  onChanged: (value) =>
                      cubit.filters(filter.country, value, filter.category),
                ),
                WorkspaceSelect(
                  title: copy.countryLabel,
                  options: countries,
                  selected: filter.country,
                  copy: copy,
                  canClear: true,
                  label: _country,
                  onChanged: (value) =>
                      cubit.filters(value, filter.sector, filter.category),
                ),
                WorkspaceSelect(
                  title: copy.local('Product category', 'فئة المنتج'),
                  options: categories,
                  selected: filter.category,
                  copy: copy,
                  canClear: true,
                  label: (value) => value,
                  onChanged: (value) =>
                      cubit.filters(filter.country, filter.sector, value),
                ),
              ],
            ),
            if (rows.isEmpty) ContentPanel(children: [Text(copy.noResults)]),
            ...rows,
            WorkspaceLink(
              label: copy.local(
                'Saved companies and products',
                'الشركات والمنتجات المحفوظة',
              ),
              onTap: () => openWorkspace(
                context,
                SavedWorkspace(copy: copy, workspace: workspace),
              ),
            ),
          ],
        );
      },
    ),
  );

  String _country(String name) {
    for (final company in companies) {
      if (company.country == name && company.countryAr != null) {
        return copy.local(name, company.countryAr!);
      }
    }
    return switch (name) {
      'Egypt' => copy.local(name, 'مصر'),
      'Jordan' => copy.local(name, 'الأردن'),
      _ => name,
    };
  }

  void _product(BuildContext context, ProductSample product) {
    final item = (
      kind: SavedKind.product,
      id: product.id,
      english: product.english,
      arabic: product.arabic,
    );
    openWorkspace(
      context,
      WorkspacePage(
        title: copy.local(product.english, product.arabic),
        children: [
          WorkspaceNotice(copy: copy),
          ContentPanel(
            children: [
              LabelValue(copy.countryLabel, _country(product.country)),
              LabelValue(
                copy.local('Product category', 'فئة المنتج'),
                product.category,
              ),
              LabelValue(
                copy.local(
                  'Synthetic HS search key',
                  'رمز البحث الجمركي الاصطناعي',
                ),
                product.hs,
              ),
            ],
          ),
          SaveWorkspaceButton(copy: copy, workspace: workspace, item: item),
          Builder(
            builder: (context) => WorkspaceLink(
              label: copy.local(
                'Prepare quotation request',
                'جهّز طلب عرض سعر',
              ),
              onTap: () => openWorkspace(
                context,
                QuoteWorkspace(copy: copy, workspace: workspace),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _company(BuildContext context, Company company) {
    final item = (
      kind: SavedKind.company,
      id: company.name,
      english: company.name,
      arabic: company.name,
    );
    openWorkspace(
      context,
      WorkspacePage(
        title: company.name,
        children: [
          WorkspaceNotice(copy: copy),
          WorkspaceLink(
            label: copy.local('Company profile', 'ملف الشركة'),
            onTap: () => openWorkspace(
              context,
              CompanyDetailsScreen(company: company, copy: copy),
            ),
          ),
          SaveWorkspaceButton(copy: copy, workspace: workspace, item: item),
          Builder(
            builder: (context) => WorkspaceLink(
              label: copy.local('Contact preview', 'معاينة التواصل'),
              onTap: () => guestPreview(
                context,
                copy,
                copy.local('Contact preview', 'معاينة التواصل'),
              ),
            ),
          ),
          Builder(
            builder: (context) => WorkspaceLink(
              label: copy.local(
                'Prepare quotation request',
                'جهّز طلب عرض سعر',
              ),
              onTap: () => openWorkspace(
                context,
                QuoteWorkspace(copy: copy, workspace: workspace),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SaveWorkspaceButton extends StatelessWidget {
  const SaveWorkspaceButton({
    super.key,
    required this.copy,
    required this.workspace,
    required this.item,
  });
  final AppCopy copy;
  final LocalWorkspace workspace;
  final SavedItem item;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<LocalWorkspace, WorkspaceState>(
        bloc: workspace,
        builder: (context, state) => WorkspaceLink(
          label: workspace.saved(item)
              ? copy.local('Remove from saved', 'إزالة من المحفوظات')
              : copy.local('Save locally', 'حفظ محلي'),
          icon: workspace.saved(item)
              ? Icons.bookmark
              : Icons.bookmark_add_outlined,
          onTap: () => workspace.toggleSaved(item),
        ),
      );
}

class SavedWorkspace extends StatelessWidget {
  const SavedWorkspace({
    super.key,
    required this.copy,
    required this.workspace,
  });
  final AppCopy copy;
  final LocalWorkspace workspace;

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<LocalWorkspace, WorkspaceState>(
    bloc: workspace,
    builder: (context, state) => WorkspacePage(
      title: copy.local('Saved items', 'المحفوظات'),
      children: [
        WorkspaceNotice(
          copy: copy,
          message: copy.local(
            'Available during this app session.',
            'متاحة خلال جلسة التطبيق الحالية.',
          ),
        ),
        if (state.saved.isEmpty)
          Text(copy.local('No saved items yet.', 'لا توجد عناصر محفوظة بعد.')),
        for (final item in state.saved)
          ContentPanel(
            title: copy.local(item.english, item.arabic),
            children: [
              SaveWorkspaceButton(copy: copy, workspace: workspace, item: item),
            ],
          ),
      ],
    ),
  );
}
