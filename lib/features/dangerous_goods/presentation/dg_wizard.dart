import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/form_language_button.dart';

import '../../../core/theme/app_tokens.dart';
import '../domain/dg_assessment.dart';
import '../domain/dg_models.dart';
import 'dg_copy.dart';
import 'dg_cubits.dart';
import 'dg_reference_widgets.dart';
import 'dg_widgets.dart';

class DgWizard extends StatelessWidget {
  const DgWizard({
    super.key,
    required this.copy,
    required this.service,
    this.mode,
  });
  final DgCopy copy;
  final DgAssessmentService service;
  final DgMode? mode;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => DgWizardCubit(service, mode: mode),
    child: _WizardPage(copy: DgCopy(liveFormCopy(context, copy.app))),
  );
}

class _WizardPage extends StatefulWidget {
  const _WizardPage({required this.copy});
  final DgCopy copy;
  @override
  State<_WizardPage> createState() => _WizardPageState();
}

class _WizardPageState extends State<_WizardPage> {
  final scroll = ScrollController();
  DgCopy get copy => widget.copy;

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  String stepLabel(DgStep step) => switch (step) {
    DgStep.shipment => copy.tr('Shipment details', 'بيانات الشحنة'),
    DgStep.documents => copy.tr('Document readiness', 'جاهزية الوثائق'),
    DgStep.review => copy.tr('Review inputs', 'مراجعة المدخلات'),
    DgStep.result => copy.tr('Readiness result', 'نتيجة الجاهزية'),
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DgWizardCubit>();
    return BlocConsumer<DgWizardCubit, DgWizardState>(
      listenWhen: (old, next) =>
          old.step != next.step || (!old.submitted && next.submitted),
      listener: (context, state) {
        FocusScope.of(context).unfocus();
        if (scroll.hasClients) scroll.jumpTo(0);
      },
      builder: (context, state) {
        final progress = state.step.index + 1;
        return PopScope<void>(
          canPop: state.step == DgStep.shipment,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) cubit.back();
          },
          child: DgPage(
            title: copy.tr('Shipment readiness', 'جاهزية الشحنة'),
            controller: scroll,
            actions: [FormLanguageButton(copy: copy.app)],
            children: [
              Text(copy.tr('Step $progress of 4', 'الخطوة $progress من 4')),
              LinearProgressIndicator(value: progress / 4),
              Semantics(
                header: true,
                child: Text(
                  stepLabel(state.step),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              DgNotice(copy: copy),
              if (state.demo)
                ContentPanel(highlight: true, children: [Text(copy.demo)]),
              if (state.submitted)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    copy.tr(
                      'Check the highlighted inputs.',
                      'راجع المدخلات المميزة.',
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ...switch (state.step) {
                DgStep.shipment => [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      key: const ValueKey('dg-wizard-demo'),
                      onPressed: cubit.example,
                      icon: const Icon(Icons.science_outlined),
                      label: Text(
                        state.demo
                            ? copy.tr(
                                'Start with blank inputs',
                                'ابدأ بمدخلات فارغة',
                              )
                            : copy.tr(
                                'Load synthetic example',
                                'حمّل مثالًا اصطناعيًا',
                              ),
                      ),
                    ),
                  ),
                  _fields(state, cubit, state.draft.shipmentFields),
                ],
                DgStep.documents => [
                  Text(
                    copy.tr(
                      'Record availability only. Keep documents and sensitive details out of this preview.',
                      'سجّل التوفر فقط. احتفظ بالوثائق والتفاصيل الحساسة خارج هذه المعاينة.',
                    ),
                  ),
                  _fields(state, cubit, state.draft.readinessFields),
                  DgDocuments(
                    copy: copy,
                    mode: state.draft.mode,
                    battery: state.draft.battery == BatteryFlag.yes,
                  ),
                ],
                DgStep.review => [
                  for (final (step, fields) in [
                    (DgStep.shipment, state.draft.shipmentFields),
                    (DgStep.documents, state.draft.readinessFields),
                  ])
                    ContentPanel(
                      title: stepLabel(step),
                      children: [
                        for (final field in fields)
                          LabelValue(
                            copy.field(field),
                            _value(state.draft, field),
                          ),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: TextButton(
                            onPressed: state.loading
                                ? null
                                : () => cubit.go(step),
                            child: Text(
                              copy.tr(
                                'Edit ${stepLabel(step).toLowerCase()}',
                                'تعديل ${stepLabel(step)}',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
                DgStep.result => _result(state),
              },
              Wrap(
                spacing: AppTokens.space3,
                runSpacing: AppTokens.space2,
                children: [
                  if (state.step != DgStep.shipment)
                    OutlinedButton(
                      key: const ValueKey('dg-back'),
                      onPressed: state.loading ? null : cubit.back,
                      child: Text(
                        state.step == DgStep.result
                            ? copy.tr(
                                'Edit and reassess',
                                'تعديل وإعادة التقييم',
                              )
                            : copy.tr('Back', 'السابق'),
                      ),
                    ),
                  if (state.step != DgStep.result)
                    FilledButton(
                      key: const ValueKey('dg-next'),
                      onPressed: state.loading
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              cubit.next();
                            },
                      child: Text(
                        state.loading
                            ? copy.tr('Checking sources…', 'جارٍ فحص المصادر…')
                            : state.step == DgStep.review
                            ? copy.tr('Assess readiness', 'قيّم الجاهزية')
                            : copy.tr('Next', 'التالي'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _fields(
    DgWizardState state,
    DgWizardCubit cubit,
    List<DgField> fields,
  ) => AdaptiveGrid(
    key: ValueKey((state.step, state.demo)),
    children: [
      for (final field in fields)
        if (_options(field) case final options?)
          DgChoice(
            key: ValueKey('dg-input-${field.name}'),
            title: copy.field(field),
            options: options,
            value: state.draft.option(field, options),
            copy: copy,
            onSelected: (option) => cubit.edit(field, option.name),
          )
        else
          Column(
            key: ValueKey('dg-input-${field.name}'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                copy.field(field),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTokens.space1),
              Semantics(
                label: copy.field(field),
                child: TextFormField(
                  initialValue: state.draft.text(field),
                  onChanged: (text) => cubit.edit(field, text),
                  decoration: const InputDecoration(),
                  keyboardType:
                      field == DgField.quantity || field == DgField.packages
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
                ),
              ),
              if (state.submitted && state.draft.invalid(field))
                Text(
                  switch (field) {
                    DgField.un => copy.invalidUn,
                    DgField.packages => copy.tr(
                      'Enter a positive whole number.',
                      'أدخل عددًا صحيحًا موجبًا.',
                    ),
                    _ => copy.tr(
                      'Enter a positive quantity without grouping separators.',
                      'أدخل كمية موجبة دون فواصل الآلاف.',
                    ),
                  },
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
    ],
  );

  String _value(ShipmentDraft draft, DgField field) {
    final options = _options(field);
    final selected = options == null ? null : draft.option(field, options);
    if (selected != null) return copy.option(selected);
    final text = draft.text(field);
    return text.isEmpty ? copy.tr('Not provided', 'غير مذكور') : text;
  }

  List<Widget> _result(DgWizardState state) {
    final assessed = state.assessment!;
    final draft = state.draft;
    return [
      ContentPanel(
        title: copy.status(assessed.status),
        children: [
          Text(
            copy.tr(
              'The result describes preparation for human review. Carrier and regulatory decisions are separate.',
              'تصف النتيجة التجهيز للمراجعة البشرية. قرارات الناقل والجهات التنظيمية منفصلة.',
            ),
          ),
          LabelValue(
            copy.tr('Assessment date', 'تاريخ التقييم'),
            state.date!.toIso8601String().substring(0, 10),
          ),
          LabelValue(copy.field(DgField.mode), _value(draft, DgField.mode)),
          LabelValue(copy.field(DgField.un), _value(draft, DgField.un)),
          if (assessed.lookupFailed)
            Text(
              copy.tr(
                'The source could not be checked. Reassess to retry.',
                'تعذر فحص المصدر. أعد التقييم للمحاولة مرة أخرى.',
              ),
            ),
          if (assessed.restriction == null)
            Text(
              copy.tr(
                'Verified applicable restrictions are unavailable for this assessment.',
                'القيود الموثقة والمنطبقة غير متاحة لهذا التقييم.',
              ),
            )
          else ...[
            Text(
              copy.tr(
                assessed.restriction!.english,
                assessed.restriction!.arabic,
              ),
            ),
            _source(assessed.restriction!.source),
          ],
        ],
      ),
      if (assessed.missing.isNotEmpty)
        ContentPanel(
          title: copy.tr('Missing information', 'معلومات ناقصة'),
          children: [
            for (final field in assessed.missing)
              Text('• ${copy.field(field)}'),
          ],
        ),
      if (assessed.status == DgStatus.specialistReview)
        ContentPanel(
          title: copy.tr('Assumptions to confirm', 'افتراضات تستلزم التأكيد'),
          children: [
            Text(
              copy.tr(
                'Uncertain details or reported battery condition need specialist or carrier review.',
                'تتطلب التفاصيل غير المؤكدة أو حالة البطارية المبلغ عنها مراجعة المختص أو الناقل.',
              ),
            ),
          ],
        ),
      DgDocuments(
        copy: copy,
        mode: draft.mode,
        battery: draft.battery == BatteryFlag.yes,
      ),
      DgReferences(copy: copy, mode: draft.mode),
    ];
  }

  Widget _source(RegulatorySource source) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      LabelValue(
        copy.framework(source.framework),
        '${source.edition} · ${source.jurisdiction}',
      ),
      LabelValue(
        copy.tr('Effective dates', 'تواريخ السريان'),
        '${source.effectiveFrom.toIso8601String().substring(0, 10)} – ${source.effectiveThrough?.toIso8601String().substring(0, 10) ?? copy.tr('Open-ended', 'مفتوح')}',
      ),
      if (source.amendment case final amendment?) Text(amendment),
      SelectableText(source.citation),
    ],
  );
}

List<Enum>? _options(DgField field) => switch (field) {
  DgField.mode => DgMode.values,
  DgField.physical => PhysicalState.values,
  DgField.battery => BatteryFlag.values,
  DgField.chemistry => Chemistry.values,
  DgField.configuration => Configuration.values,
  DgField.condition => BatteryCondition.values,
  DgField.sds ||
  DgField.classification ||
  DgField.packaging ||
  DgField.batteryTests => Readiness.values,
  _ => null,
};
