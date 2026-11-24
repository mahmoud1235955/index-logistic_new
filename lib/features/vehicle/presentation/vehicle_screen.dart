import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/form_language_button.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/theme/app_tokens.dart';
import '../data/local_vehicle_rules.dart';
import '../domain/country_rule_provider.dart';
import '../domain/vehicle_profile.dart';
import 'vehicle_copy.dart';
import 'vehicle_cubit.dart';
import 'vehicle_panel.dart';
import 'vehicle_result.dart';

Future<void> openVehicleImport(BuildContext context, AppCopy copy) =>
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => VehicleImportScreen(copy: copy)),
    );

class VehicleImportScreen extends StatelessWidget {
  const VehicleImportScreen({
    super.key,
    required this.copy,
    this.repository = const LocalVehicleRules(),
  });

  final AppCopy copy;
  final CountryRuleProvider repository;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => VehicleCubit(repository),
    child: _VehicleFlow(copy: VehicleCopy(liveFormCopy(context, copy))),
  );
}

class _VehicleFlow extends StatefulWidget {
  const _VehicleFlow({required this.copy});
  final VehicleCopy copy;

  @override
  State<_VehicleFlow> createState() => _VehicleFlowState();
}

class _VehicleFlowState extends State<_VehicleFlow> {
  final _scroll = ScrollController();
  VehicleCopy get copy => widget.copy;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  String _step(VehicleStep step) => switch (step) {
    VehicleStep.vehicle => copy.tr('Vehicle information', 'بيانات المركبة'),
    VehicleStep.importer => copy.tr('Importer information', 'بيانات المستورد'),
    VehicleStep.finance => copy.tr('Financial information', 'البيانات المالية'),
    VehicleStep.review => copy.tr('Review your information', 'مراجعة البيانات'),
    VehicleStep.result => copy.tr(
      'Assessment and estimate',
      'التقييم والتقدير',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VehicleCubit>();
    return BlocConsumer<VehicleCubit, VehicleState>(
      listenWhen: (previous, next) =>
          previous.step != next.step || (!previous.submitted && next.submitted),
      listener: (context, state) {
        FocusScope.of(context).unfocus();
        if (_scroll.hasClients) _scroll.jumpTo(0);
      },
      builder: (context, state) {
        final progress = state.step.index + 1;
        return PopScope<void>(
          canPop: state.step == VehicleStep.vehicle,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) cubit.back();
          },
          child: Scaffold(
            appBar: AppBar(
              actions: [FormLanguageButton(copy: copy.app)],
              title: Text(
                copy.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            body: SafeArea(
              child: ListView(
                controller: _scroll,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(AppTokens.space4),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 920),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          key: ValueKey(state.step),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              copy.tr(
                                'Step $progress of 5',
                                'الخطوة $progress من 5',
                              ),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: AppTokens.space2),
                            LinearProgressIndicator(value: progress / 5),
                            const SizedBox(height: AppTokens.space4),
                            Text(
                              _step(state.step),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: AppTokens.space4),
                            VehiclePanel(text: copy.disclaimer),
                            const SizedBox(height: AppTokens.space4),
                            if (state.step == VehicleStep.review)
                              _Review(
                                copy: copy,
                                state: state,
                                stepLabel: _step,
                              )
                            else if (state.step == VehicleStep.result)
                              VehicleResult(copy: copy, state: state)
                            else
                              _FormFields(copy: copy, state: state),
                            const SizedBox(height: AppTokens.space4),
                            Wrap(
                              spacing: AppTokens.space3,
                              runSpacing: AppTokens.space2,
                              children: [
                                if (state.step != VehicleStep.vehicle)
                                  OutlinedButton(
                                    key: const ValueKey('vehicle-back'),
                                    onPressed: state.loading
                                        ? null
                                        : cubit.back,
                                    child: Text(
                                      state.step == VehicleStep.result
                                          ? copy.tr(
                                              'Edit and recalculate',
                                              'تعديل وإعادة الحساب',
                                            )
                                          : copy.tr('Back', 'السابق'),
                                    ),
                                  ),
                                if (state.step != VehicleStep.result)
                                  FilledButton(
                                    key: const ValueKey('vehicle-next'),
                                    onPressed: state.loading
                                        ? null
                                        : () {
                                            FocusScope.of(context).unfocus();
                                            cubit.next();
                                          },
                                    child: Text(
                                      state.loading
                                          ? copy.tr(
                                              'Checking rules…',
                                              'جارٍ فحص القواعد…',
                                            )
                                          : state.step == VehicleStep.review
                                          ? copy.tr('Calculate', 'احسب')
                                          : copy.tr('Next', 'التالي'),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

List<Enum>? _options(VehicleField field) => switch (field) {
  VehicleField.category => VehicleCategory.values,
  VehicleField.condition => VehicleCondition.values,
  VehicleField.fuel => Fuel.values,
  VehicleField.importer => ImporterKind.values,
  VehicleField.use => ImportUse.values,
  VehicleField.residency => Residency.values,
  VehicleField.regime => ImportRegime.values,
  VehicleField.currency => Currency.values,
  VehicleField.documents => DocumentReadiness.values,
  VehicleField.preference => PreferenceClaim.values,
  _ => null,
};

class _FormFields extends StatelessWidget {
  const _FormFields({required this.copy, required this.state});
  final VehicleCopy copy;
  final VehicleState state;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (state.step == VehicleStep.importer)
        Text(
          copy.tr(
            'Record document readiness only. Keep personal details and documents out of this form.',
            'سجّل جاهزية المستندات فقط. احتفظ بالبيانات الشخصية والمستندات خارج هذا النموذج.',
          ),
        ),
      if (state.step == VehicleStep.finance)
        Text(
          copy.tr(
            'Use one currency and enter 0 for costs you do not expect. Use a decimal point and omit grouping separators.',
            'استخدم عملة واحدة وأدخل صفرًا للتكاليف غير المتوقعة. استخدم فاصلة عشرية دون فواصل الآلاف.',
          ),
        ),
      if (state.submitted)
        Semantics(
          liveRegion: true,
          child: Text(
            copy.tr(
              'Check the highlighted fields below.',
              'راجع الحقول المميزة أدناه.',
            ),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      const SizedBox(height: AppTokens.space3),
      LayoutBuilder(
        builder: (context, constraints) {
          const gap = AppTokens.space4;
          final twoColumns =
              constraints.maxWidth >=
              MediaQuery.textScalerOf(context).scale(560);
          final width = twoColumns
              ? (constraints.maxWidth - gap) / 2
              : constraints.maxWidth;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final field in state.fields(state.step))
                SizedBox(
                  key: ValueKey(field),
                  width: width,
                  child: _VehicleFieldInput(
                    field: field,
                    copy: copy,
                    state: state,
                  ),
                ),
            ],
          );
        },
      ),
    ],
  );
}

class _VehicleFieldInput extends StatelessWidget {
  const _VehicleFieldInput({
    required this.field,
    required this.copy,
    required this.state,
  });
  final VehicleField field;
  final VehicleCopy copy;
  final VehicleState state;

  String? get _hint => switch (field) {
    VehicleField.specification => switch (state.profile.category) {
      VehicleCategory.truck || VehicleCategory.commercial => copy.tr(
        'For example, payload or axle configuration',
        'مثل الحمولة أو تكوين المحاور',
      ),
      VehicleCategory.bus => copy.tr(
        'For example, number of seats',
        'مثل عدد المقاعد',
      ),
      _ => null,
    },
    VehicleField.exchangeSource => copy.tr(
      'Provider or published reference',
      'الجهة أو المرجع المنشور',
    ),
    _ => null,
  };

  String? get _error => switch (state.submitted ? state.error(field) : null) {
    FieldError.required => copy.tr('Required.', 'مطلوب.'),
    FieldError.number => copy.tr(
      'Enter a number from 0 to 1 billion, with up to 6 decimal places.',
      'أدخل رقمًا من صفر إلى مليار، وبحد أقصى ٦ منازل عشرية.',
    ),
    FieldError.positive => copy.tr(
      'Enter a value greater than zero.',
      'أدخل قيمة أكبر من صفر.',
    ),
    FieldError.integer => copy.tr(
      'Enter a whole number.',
      'أدخل رقمًا صحيحًا.',
    ),
    FieldError.year => copy.tr(
      'Enter a plausible four-digit year.',
      'أدخل سنة معقولة من ٤ أرقام.',
    ),
    FieldError.date => copy.tr(
      'Enter a valid date in YYYY-MM-DD format. An exchange date must be on or before the assessment.',
      'أدخل تاريخًا صحيحًا بصيغة YYYY-MM-DD. يجب ألا يتجاوز تاريخ الصرف تاريخ التقييم.',
    ),
    FieldError.currency => copy.tr(
      'Enter a three-letter currency code other than EGP.',
      'أدخل رمز عملة من ثلاثة أحرف بخلاف EGP.',
    ),
    null => null,
  };

  @override
  Widget build(BuildContext context) {
    final label = copy.field(field);
    final options = _options(field);
    final cubit = context.read<VehicleCubit>();
    final value = state.profile.text(field);
    final error = _error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          state.optional(field)
              ? '$label ${copy.tr('(optional)', '(اختياري)')}'
              : label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTokens.space1),
        Semantics(
          label: label,
          child: options == null
              ? TextFormField(
                  key: ValueKey('vehicle-input-${field.name}'),
                  initialValue: value,
                  keyboardType: VehicleState.isNumeric(field)
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
                  decoration: const InputDecoration(),
                  onChanged: (value) => cubit.change(field, value),
                )
              : _Choice<Enum>(
                  key: ValueKey('vehicle-input-${field.name}'),
                  value: options
                      .where((option) => option.name == value)
                      .firstOrNull,
                  options: options,
                  copy: copy,
                  onChanged: (value) => cubit.change(field, value.name),
                ),
        ),
        if (_hint case final hint?)
          Text(hint, style: Theme.of(context).textTheme.bodyMedium),
        if (error != null)
          Semantics(
            liveRegion: true,
            child: Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}

class _Choice<T extends Enum> extends StatelessWidget {
  const _Choice({
    super.key,
    required this.value,
    required this.options,
    required this.copy,
    required this.onChanged,
  });
  final T? value;
  final List<T> options;
  final VehicleCopy copy;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    style: OutlinedButton.styleFrom(
      backgroundColor: AppTokens.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      minimumSize: const Size.fromHeight(48),
      padding: const EdgeInsets.all(12),
    ),
    onPressed: onChanged == null
        ? null
        : () async {
            final selected = await showDialog<T>(
              context: context,
              builder: (context) => SimpleDialog(
                title: Text(copy.tr('Select an option', 'اختر أحد الخيارات')),
                children: [
                  for (final option in options)
                    SimpleDialogOption(
                      onPressed: () => Navigator.of(context).pop(option),
                      padding: const EdgeInsets.all(16),
                      child: Text(copy.option(option)),
                    ),
                ],
              ),
            );
            if (context.mounted && selected != null) onChanged!(selected);
          },
    child: Row(
      children: [
        Expanded(
          child: Text(
            value == null ? copy.tr('Select', 'اختر') : copy.option(value!),
          ),
        ),
        const SizedBox(width: AppTokens.space2),
        const Icon(Icons.expand_more),
      ],
    ),
  );
}

class _Review extends StatelessWidget {
  const _Review({
    required this.copy,
    required this.state,
    required this.stepLabel,
  });
  final VehicleCopy copy;
  final VehicleState state;
  final String Function(VehicleStep) stepLabel;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VehicleCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          copy.tr('Assessment mode', 'وضع التقييم'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppTokens.space2),
        _Choice(
          key: const ValueKey('vehicle-scenario'),
          value: state.scenario,
          options: VehicleScenario.values,
          copy: copy,
          onChanged: state.loading ? null : cubit.selectScenario,
        ),
        const SizedBox(height: AppTokens.space2),
        Text(
          state.demonstration
              ? copy.synthetic
              : copy.tr(
                  'Prepare a summary for customs review. Verified Egyptian rules are unavailable in this version.',
                  'جهّز ملخصًا لمراجعته مع مختص جمركي. القواعد المصرية الموثّقة غير متاحة في هذا الإصدار.',
                ),
        ),
        for (final step in VehicleStep.values.take(3)) ...[
          const SizedBox(height: AppTokens.space3),
          VehiclePanel(
            title: stepLabel(step),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final field in state.fields(step)) ...[
                  const SizedBox(height: AppTokens.space2),
                  Text(
                    copy.field(field),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(_value(field)),
                ],
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: state.loading ? null : () => cubit.edit(step),
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
          ),
        ],
      ],
    );
  }

  String _value(VehicleField field) {
    final text = state.profile.text(field);
    for (final option in _options(field) ?? const <Enum>[]) {
      if (option.name == text) return copy.option(option);
    }
    return text.isEmpty ? copy.tr('Not supplied', 'غير مذكور') : text;
  }
}
