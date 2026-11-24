import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/state/app_view_state.dart';
import '../../../core/widgets/app_state_panel.dart';
import '../domain/dg_models.dart';
import '../domain/dg_providers.dart';
import 'dg_copy.dart';
import 'dg_cubits.dart';
import 'dg_widgets.dart';

class DgSearch extends StatelessWidget {
  const DgSearch({
    super.key,
    required this.copy,
    required this.repository,
    this.mode,
  });
  final DgCopy copy;
  final ClassificationRepository repository;
  final DgMode? mode;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => DgSearchCubit(repository, mode: mode)..update(),
    child: _SearchPage(copy: copy),
  );
}

class _SearchPage extends StatefulWidget {
  const _SearchPage({required this.copy});
  final DgCopy copy;

  @override
  State<_SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<_SearchPage> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = widget.copy;
    final cubit = context.read<DgSearchCubit>();
    return BlocBuilder<DgSearchCubit, DgSearchState>(
      builder: (context, state) {
        final query = state.query;
        return DgPage(
          title: copy.tr('Classification search', 'بحث التصنيفات'),
          children: [
            DgNotice(copy: copy),
            Text(
              copy.tr(
                'Search results are reference records for review. A product name alone cannot establish classification.',
                'نتائج البحث سجلات مرجعية للمراجعة. اسم المنتج وحده لا يثبت التصنيف.',
              ),
            ),
            TextField(
              key: const ValueKey('dg-search'),
              controller: controller,
              decoration: InputDecoration(
                labelText: copy.tr(
                  'UN number or substance',
                  'الرقم الأممي أو اسم المادة',
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (text) => cubit.update(text: text),
            ),
            AdaptiveGrid(
              children: [
                DgChoice(
                  key: const ValueKey('dg-hazard-filter'),
                  title: copy.tr('Hazard class', 'فئة الخطر'),
                  options: HazardClass.values,
                  value: query.hazard,
                  copy: copy,
                  onSelected: (hazard) => cubit.update(hazard: hazard),
                  clear: () => cubit.update(clearHazard: true),
                ),
                DgChoice(
                  key: const ValueKey('dg-mode-filter'),
                  title: copy.field(DgField.mode),
                  options: DgMode.values,
                  value: query.mode,
                  copy: copy,
                  onSelected: (mode) => cubit.update(mode: mode),
                  clear: () => cubit.update(clearMode: true),
                ),
              ],
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const ValueKey('dg-toggle-demo'),
                onPressed: () {
                  controller.clear();
                  cubit.update(text: '', demo: !query.demo);
                },
                icon: const Icon(Icons.science_outlined),
                label: Text(
                  query.demo
                      ? copy.tr(
                          'Hide synthetic examples',
                          'أخفِ الأمثلة الاصطناعية',
                        )
                      : copy.tr(
                          'Show synthetic examples',
                          'اعرض الأمثلة الاصطناعية',
                        ),
                ),
              ),
            ),
            if (query.demo)
              ContentPanel(highlight: true, children: [Text(copy.demo)]),
            switch (state.status) {
              SearchStatus.loading => AppStatePanel(
                state: AppViewState.loading,
                copy: copy.app,
              ),
              SearchStatus.error => AppStatePanel(
                state: AppViewState.error,
                copy: copy.app,
                message: copy.tr(
                  'The classification source could not be read.',
                  'تعذر قراءة مصدر التصنيفات.',
                ),
                onAction: () => cubit.update(),
              ),
              SearchStatus.unavailable => ContentPanel(
                title: copy.unavailable,
                children: [
                  Text(
                    copy.tr(
                      'A verified match is unavailable in the current data source.',
                      'لا تتوفر نتيجة مطابقة موثّقة في مصدر البيانات الحالي.',
                    ),
                  ),
                ],
              ),
              SearchStatus.invalid => Semantics(
                liveRegion: true,
                child: Text(
                  copy.invalidUn,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              SearchStatus.empty => AppStatePanel(
                state: AppViewState.empty,
                copy: copy.app,
                message: copy.tr(
                  'No matching synthetic records.',
                  'لا توجد سجلات اصطناعية مطابقة.',
                ),
                actionLabel: copy.app.clearSearch,
                onAction: () {
                  controller.clear();
                  cubit.update(text: '', clearMode: true, clearHazard: true);
                },
              ),
              SearchStatus.results => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      copy.tr(
                        'Results (${state.results.length})',
                        'النتائج (${state.results.length})',
                      ),
                    ),
                  ),
                  for (final item in state.results)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: DgAction(
                        key: ValueKey('dg-record-${item.un}-${item.name}'),
                        icon: Icons.description_outlined,
                        title:
                            'UN ${item.un} · ${copy.name(item)} · ${copy.option(item.verification)}',
                        onTap: () => Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (_) => _Record(copy: copy, item: item),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            },
          ],
        );
      },
    );
  }
}

class _Record extends StatelessWidget {
  const _Record({required this.copy, required this.item});
  final DgCopy copy;
  final Classification item;

  @override
  Widget build(BuildContext context) {
    final missing = copy.tr(
      'Unavailable or not established',
      'غير متاح أو غير محدد',
    );
    return DgPage(
      title: 'UN ${item.un}',
      children: [
        DgNotice(copy: copy),
        if (item.verification == DgVerification.synthetic)
          ContentPanel(highlight: true, children: [Text(copy.demo)]),
        ContentPanel(
          title: copy.name(item),
          children: [
            LabelValue(
              copy.tr('Proper shipping name field', 'حقل اسم الشحن الصحيح'),
              copy.name(item),
            ),
            LabelValue(
              copy.tr('Primary hazard class', 'فئة الخطر الأساسية'),
              copy.option(item.hazard),
            ),
            if (item.division case final division?)
              LabelValue(copy.tr('Division', 'القسم'), division),
            LabelValue(
              copy.tr('Subsidiary risks', 'المخاطر الفرعية'),
              item.subsidiary.isEmpty ? missing : item.subsidiary.join(', '),
            ),
            LabelValue(
              copy.tr(
                'Packing group, if applicable',
                'مجموعة التعبئة عند انطباقها',
              ),
              item.packingGroup ?? missing,
            ),
            LabelValue(
              copy.tr('Verification', 'التحقق'),
              copy.option(item.verification),
            ),
            if (item.alternatives.isNotEmpty)
              LabelValue(
                copy.tr('Alternative names', 'أسماء بديلة'),
                item.alternatives.join(' / '),
              ),
            if (item.verification == DgVerification.synthetic &&
                item.demoModes.isNotEmpty)
              LabelValue(
                copy.tr('Synthetic filter tags', 'وسوم التصفية الاصطناعية'),
                item.demoModes.map(copy.option).join(' / '),
              ),
          ],
        ),
        ContentPanel(
          title: copy.tr(
            'Transport restrictions and sources',
            'قيود النقل والمصادر',
          ),
          children: [
            for (final mode in DgMode.values)
              LabelValue(copy.option(mode), copy.unavailable),
            for (final source in item.sources)
              LabelValue(
                copy.framework(source.framework),
                '${source.edition} · ${source.jurisdiction} · ${copy.option(source.verification)}',
              ),
          ],
        ),
      ],
    );
  }
}
