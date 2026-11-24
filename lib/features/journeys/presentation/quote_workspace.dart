import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/widgets/adaptive_content.dart';
import '../../dangerous_goods/domain/dg_models.dart';
import '../../dangerous_goods/presentation/dg_hub.dart';
import '../../trade/domain/shipment.dart';
import '../../trade/presentation/trade_screen.dart';
import '../../../app/cubit/app_cubit.dart';
import '../data/package_preferences.dart';
import '../domain/package_group.dart';
import 'package_editor.dart';
import 'quote_comparison.dart';
import '../domain/commercial_models.dart';
import '../domain/local_workspace.dart';
import 'workspace_widgets.dart';

enum _QuoteStep { route, cargo, services, review }

class _PackageStorage extends StatefulWidget {
  const _PackageStorage({required this.copy, required this.cubit});
  final AppCopy copy;
  final _QuoteCubit cubit;

  @override
  State<_PackageStorage> createState() => _PackageStorageState();
}

class _PackageStorageState extends State<_PackageStorage> {
  bool _busy = false;
  String? _message;

  Future<void> _run(int action) async {
    setState(() => _busy = true);
    const preferences = PackagePreferences();
    final before = widget.cubit.state.draft.packages;
    final stored = action == 1 ? await preferences.load() : null;
    final ok = switch (action) {
      0 => await preferences.save(before),
      1 =>
        stored != null &&
            !widget.cubit.isClosed &&
            identical(before, widget.cubit.state.draft.packages),
      _ => await preferences.clear(),
    };
    if (!mounted) return;
    if (ok && stored != null) widget.cubit.edit(packages: stored);
    final copy = widget.copy;
    setState(() {
      _busy = false;
      _message = ok
          ? copy.local(
              'Local package template updated.',
              'تم تحديث قالب الطرود المحلي.',
            )
          : copy.local(
              'No change. Check the package inputs or local storage.',
              'لم يحدث تغيير. تحقق من بيانات الطرود أو التخزين المحلي.',
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    final copy = widget.copy;
    return ContentPanel(
      title: copy.local('Local package template', 'قالب الطرود المحلي'),
      children: [
        Text(
          copy.local(
            'Only package types, units and numbers are stored. Restoring replaces the current groups.',
            'يُحفظ فقط نوع العبوة والوحدات والأرقام. تستبدل الاستعادة المجموعات الحالية.',
          ),
        ),
        Wrap(
          spacing: 8,
          children: [
            for (final (index, title) in [
              (0, copy.local('Save template', 'احفظ القالب')),
              (1, copy.local('Restore template', 'استعد القالب')),
              (2, copy.local('Clear stored template', 'امسح القالب المحفوظ')),
            ])
              TextButton(
                onPressed: _busy ? null : () => _run(index),
                child: Text(title),
              ),
          ],
        ),
        if (_message case final message?)
          Semantics(liveRegion: true, child: Text(message)),
      ],
    );
  }
}

typedef _QuoteState = ({QuoteDraft draft, _QuoteStep step, bool invalid});

class _QuoteCubit extends Cubit<_QuoteState> {
  _QuoteCubit(QuoteDraft draft)
    : super((draft: draft, step: _QuoteStep.route, invalid: false));

  void edit({
    QuoteField? field,
    String? value,
    FreightMode? mode,
    FreightService? service,
    List<PackageInput>? packages,
  }) {
    final services = {...state.draft.services};
    if (service != null && !services.remove(service)) services.add(service);
    emit((
      draft: QuoteDraft(
        fields: {...state.draft.fields, ?field: value ?? ''},
        mode: mode ?? state.draft.mode,
        services: services,
        packages: packages ?? state.draft.packages,
      ),
      step: state.step,
      invalid: state.invalid,
    ));
  }

  List<QuoteField> fields(_QuoteStep step) => switch (step) {
    _QuoteStep.route => [
      QuoteField.origin,
      QuoteField.destination,
      QuoteField.readyDate,
    ],
    _QuoteStep.cargo => [QuoteField.cargo],
    _QuoteStep.services => [QuoteField.equipment, QuoteField.handling],
    _ => [],
  };

  void go(_QuoteStep step) =>
      emit((draft: state.draft, step: step, invalid: false));

  void next() {
    final invalid =
        state.draft.missing.any(fields(state.step).contains) ||
        (state.step == _QuoteStep.cargo &&
            CargoTotals.fromInputs(state.draft.packages) == null) ||
        (state.step == _QuoteStep.route && state.draft.mode == null);
    if (invalid) {
      emit((draft: state.draft, step: state.step, invalid: true));
    } else if (state.step != _QuoteStep.review) {
      go(_QuoteStep.values[state.step.index + 1]);
    }
  }
}

class QuoteWorkspace extends StatelessWidget {
  const QuoteWorkspace({
    super.key,
    required this.copy,
    required this.workspace,
    this.mode,
  });
  final AppCopy copy;
  final LocalWorkspace workspace;
  final FreightMode? mode;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppCubit?>();
    final copy = app == null ? this.copy : AppCopy(app.state.language);
    return BlocProvider(
      create: (_) =>
          _QuoteCubit(workspace.state.quote ?? QuoteDraft(mode: mode)),
      child: BlocBuilder<_QuoteCubit, _QuoteState>(
        builder: (context, form) {
          final cubit = context.read<_QuoteCubit>();
          final draft = form.draft;
          final progress = form.step.index + 1;
          return WorkspacePage(
            key: ValueKey(form.step),
            title: copy.local('Freight quotation draft', 'مسودة طلب سعر الشحن'),
            children: [
              WorkspaceNotice(
                copy: copy,
                message: copy.local(
                  'Drafts stay in this app session. Requests and quotations are unavailable for transmission.',
                  'تبقى المسودات خلال جلسة التطبيق. إرسال الطلبات وعروض الأسعار غير متاح.',
                ),
              ),
              Text(
                copy.local(
                  'Step $progress of 4 · ${_step(copy, form.step)}',
                  'الخطوة $progress من 4 · ${_step(copy, form.step)}',
                ),
              ),
              LinearProgressIndicator(value: progress / 4),
              if (app != null)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    key: const ValueKey('quote-language'),
                    onPressed: app.toggleLanguage,
                    child: Text(copy.local('???????', 'English')),
                  ),
                ),
              if (form.step == _QuoteStep.cargo) ...[
                PackageEditor(
                  copy: copy,
                  inputs: draft.packages,
                  onChanged: (packages) => cubit.edit(packages: packages),
                  showErrors: form.invalid,
                ),
                if (form.invalid && draft.packages.isEmpty)
                  Text(
                    copy.local(
                      'Add at least one package group.',
                      '??? ?????? ???? ????? ??? ?????.',
                    ),
                  ),
                _PackageStorage(copy: copy, cubit: cubit),
              ],
              if (form.step == _QuoteStep.route)
                WorkspaceSelect(
                  title: copy.local('Transport mode', 'وسيلة النقل'),
                  options: FreightMode.values,
                  selected: draft.mode,
                  copy: copy,
                  label: (mode) => _mode(copy, mode),
                  onChanged: (value) => cubit.edit(mode: value),
                ),
              for (final field in cubit.fields(form.step))
                TextFormField(
                  key: ValueKey('quote-${field.name}'),
                  initialValue: draft.text(field),
                  decoration: InputDecoration(
                    labelText: _field(copy, field),
                    errorText: form.invalid && draft.missing.contains(field)
                        ? copy.local('Required', 'مطلوب')
                        : null,
                  ),
                  onChanged: (value) => cubit.edit(field: field, value: value),
                ),
              if (form.invalid && draft.mode == null)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    copy.local('Select a transport mode.', 'اختر وسيلة النقل.'),
                  ),
                ),
              if (form.step == _QuoteStep.services) ...[
                ContentPanel(
                  title: copy.local('Required services', 'الخدمات المطلوبة'),
                  children: [
                    for (final service in FreightService.values)
                      CheckboxListTile(
                        value: draft.services.contains(service),
                        title: Text(_service(copy, service)),
                        onChanged: (_) => cubit.edit(service: service),
                      ),
                  ],
                ),
                WorkspaceLink(
                  label: copy.local(
                    'Dangerous goods preparation',
                    'تجهيز البضائع الخطرة',
                  ),
                  onTap: () => openDgHub(
                    context,
                    copy,
                    mode: switch (draft.mode) {
                      FreightMode.air => DgMode.air,
                      FreightMode.sea => DgMode.sea,
                      FreightMode.road => DgMode.road,
                      null => null,
                    },
                  ),
                ),
              ],
              if (form.step == _QuoteStep.review) ...[
                ContentPanel(
                  title: copy.local('Review draft', 'راجع المسودة'),
                  children: [
                    if (CargoTotals.fromInputs(draft.packages)
                        case final totals?) ...[
                      LabelValue(
                        copy.local('Total gross weight', '????? ????????'),
                        '${totals.kg.format(3)} kg',
                      ),
                      LabelValue(
                        copy.local('Total cargo volume', '?????? ??? ??????'),
                        '${totals.cbm.format(6)} m?',
                      ),
                    ],
                    for (final field in QuoteField.values)
                      LabelValue(
                        _field(copy, field),
                        draft.text(field).isEmpty
                            ? copy.unavailable
                            : draft.text(field),
                      ),
                    LabelValue(
                      copy.local('Transport mode', 'وسيلة النقل'),
                      draft.mode == null
                          ? copy.unavailable
                          : _mode(copy, draft.mode!),
                    ),
                    LabelValue(
                      copy.local('Required services', 'الخدمات المطلوبة'),
                      draft.services.isEmpty
                          ? copy.local('None selected', 'لم تحدد خدمات')
                          : draft.services
                                .map((service) => _service(copy, service))
                                .join(' · '),
                    ),
                  ],
                ),
                WorkspaceLink(
                  label: copy.local(
                    'Quotation comparison preview',
                    'معاينة مقارنة العروض',
                  ),
                  onTap: () =>
                      openWorkspace(context, QuoteComparison(copy: copy)),
                ),
                WorkspaceLink(
                  label: copy.local(
                    'Open freight estimate',
                    'افتح تقدير تكلفة الشحن',
                  ),
                  onTap: () => openTrade(context, copy, TradeMode.freight),
                ),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (form.step.index > 0)
                    OutlinedButton(
                      onPressed: () =>
                          cubit.go(_QuoteStep.values[form.step.index - 1]),
                      child: Text(copy.local('Back', 'السابق')),
                    ),
                  if (form.step != _QuoteStep.review)
                    FilledButton(
                      key: const ValueKey('quote-next'),
                      onPressed: cubit.next,
                      child: Text(copy.local('Next', 'التالي')),
                    ),
                  OutlinedButton(
                    key: const ValueKey('quote-save'),
                    onPressed: () {
                      workspace.saveQuote(cubit.state.draft);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            copy.local(
                              'Draft saved for this session.',
                              'حُفظت المسودة لهذه الجلسة.',
                            ),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      copy.local('Save local draft', 'احفظ المسودة محليًا'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _mode(AppCopy copy, FreightMode mode) => switch (mode) {
    FreightMode.sea => copy.local('Sea', 'بحري'),
    FreightMode.air => copy.local('Air', 'جوي'),
    FreightMode.road => copy.local('Road', 'بري'),
  };
  String _step(AppCopy copy, _QuoteStep step) => switch (step) {
    _QuoteStep.route => copy.local('Route', 'المسار'),
    _QuoteStep.cargo => copy.local('Cargo', 'البضاعة'),
    _QuoteStep.services => copy.local('Services', 'الخدمات'),
    _QuoteStep.review => copy.local('Review', 'المراجعة'),
  };
  String _field(AppCopy copy, QuoteField field) => switch (field) {
    QuoteField.origin => copy.local('Origin', 'المنشأ'),
    QuoteField.destination => copy.local('Destination', 'الوجهة'),
    QuoteField.readyDate => copy.local(
      'Ready date (optional)',
      'تاريخ الجاهزية (اختياري)',
    ),
    QuoteField.cargo => copy.local('Cargo description', 'وصف البضاعة'),
    QuoteField.equipment => copy.local(
      'Equipment type (optional)',
      'نوع المعدات (اختياري)',
    ),
    QuoteField.handling => copy.local(
      'Special handling (optional)',
      'المناولة الخاصة (اختياري)',
    ),
  };
  String _service(AppCopy copy, FreightService service) => switch (service) {
    FreightService.pickup => copy.local('Pickup', 'الاستلام'),
    FreightService.clearance => copy.local(
      'Customs clearance',
      'التخليص الجمركي',
    ),
    FreightService.insurance => copy.local('Insurance', 'التأمين'),
    FreightService.storage => copy.local('Storage', 'التخزين'),
    FreightService.delivery => copy.local('Delivery', 'التوصيل'),
  };
}
