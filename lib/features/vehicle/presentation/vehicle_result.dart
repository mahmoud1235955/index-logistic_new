import '../../trade/domain/decimal.dart';

import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';
import '../domain/customs_calculation.dart';
import '../domain/import_eligibility.dart';
import '../domain/legal_reference.dart';
import '../domain/vehicle_profile.dart';
import 'vehicle_copy.dart';
import 'vehicle_cubit.dart';
import 'vehicle_panel.dart';

class VehicleResult extends StatelessWidget {
  const VehicleResult({super.key, required this.copy, required this.state});
  final VehicleCopy copy;
  final VehicleState state;

  String get missing => copy.tr('Not available', 'غير متاح');
  String _date(DateTime date) => date.toIso8601String().substring(0, 10);
  String _amount(Decimal? value) {
    if (value == null) return missing;
    final formatted = value.format();
    return copy.tr('$formatted EGP', '$formatted جنيه مصري');
  }

  @override
  Widget build(BuildContext context) {
    final assessment = state.assessment!;
    final estimate = state.estimate!;
    final rule = assessment.rule;
    final assessmentDate = state.profile.date(VehicleField.assessmentDate)!;
    final missingInputs = [
      if (state.profile.option(VehicleField.documents, DocumentReadiness.values)
          case DocumentReadiness.partial || DocumentReadiness.unavailable)
        copy.tr(
          'Supporting documents are pending review.',
          'المستندات الداعمة قيد التجهيز أو المراجعة.',
        ),
      if (!state.demonstration &&
          state.profile.text(VehicleField.tariffCode).isEmpty)
        copy.tr(
          'Confirm the applicable HS classification.',
          'تحقق من التصنيف الجمركي المنطبق.',
        ),
      if (state.profile.foreignCurrency &&
          state.profile.number(VehicleField.exchangeRate) == null)
        copy.tr(
          'An exchange rate into EGP is needed.',
          'يلزم سعر صرف إلى الجنيه المصري.',
        ),
      if (state.profile.foreignCurrency &&
          (state.profile.text(VehicleField.exchangeSource).isEmpty ||
              state.profile.date(VehicleField.exchangeDate) == null))
        copy.tr(
          'Provide the exchange-rate source and effective date when available.',
          'أضف مصدر سعر الصرف وتاريخ سريانه عند توفرهما.',
        ),
      for (final issue in assessment.issues) copy.issue(issue),
      if (state.lookupFailed)
        copy.tr(
          'The rule source could not be loaded. Recalculate to try again.',
          'تعذر تحميل مصدر القواعد. أعد الحساب للمحاولة مرة أخرى.',
        ),
      if (estimate.customsValueExact == null)
        copy.tr(
          'An applicable customs valuation basis and all of its inputs are needed.',
          'يلزم أساس تقييم جمركي منطبق وجميع مدخلاته.',
        ),
      for (final entry in estimate.charges.entries)
        if (entry.value.status == ChargeStatus.unknown) copy.charge(entry.key),
    ];
    final synthetic = state.demonstration;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (synthetic) ...[
          VehiclePanel(text: copy.synthetic),
          const SizedBox(height: AppTokens.space3),
        ],
        VehiclePanel(
          title: copy.eligibility(assessment.status),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                synthetic
                    ? copy.tr(
                        'This result follows the selected fictional scenario.',
                        'تتبع هذه النتيجة السيناريو الافتراضي المحدد.',
                      )
                    : assessment.status == EligibilityStatus.undetermined
                    ? copy.tr(
                        'Applicable verified rules are needed for an assessment.',
                        'يلزم توفر قواعد موثّقة ومنطبقة لإجراء التقييم.',
                      )
                    : copy.tr(
                        'Assessment based on the applicable source below.',
                        'التقييم مستند إلى المصدر المنطبق أدناه.',
                      ),
              ),
              _line(
                copy.tr('Assessment date', 'تاريخ التقييم'),
                _date(assessmentDate),
              ),
              ..._reference(
                copy.tr('Eligibility rule', 'قاعدة الأهلية'),
                rule?.reference,
                assessmentDate,
              ),
              if ((rule != null &&
                          (synthetic || rule.reference.hasOfficialCitation)
                      ? rule.reason
                      : null)
                  case final reason?)
                Text(copy.tr(reason.english, reason.arabic)),
              const SizedBox(height: AppTokens.space3),
              Text(
                synthetic
                    ? copy.tr(
                        'Example supporting documents',
                        'أمثلة على المستندات الداعمة',
                      )
                    : copy.tr(
                        'Required supporting documents',
                        'المستندات الداعمة المطلوبة',
                      ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (rule == null ||
                  rule.documents.isEmpty ||
                  (!synthetic && !rule.reference.hasOfficialCitation))
                Text(
                  copy.tr(
                    'Confirm the applicable list with a customs specialist.',
                    'أكد قائمة المستندات المنطبقة مع مختص جمركي.',
                  ),
                )
              else
                for (final doc in rule.documents)
                  Text('• ${copy.document(doc)}'),
            ],
          ),
        ),
        if (missingInputs.isNotEmpty) ...[
          const SizedBox(height: AppTokens.space3),
          VehiclePanel(
            title: copy.tr(
              'Missing information or verification',
              'بيانات أو تحقق مطلوب',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (final item in missingInputs) Text('• $item')],
            ),
          ),
        ],
        const SizedBox(height: AppTokens.space3),
        VehiclePanel(
          title: copy.tr('Landed-cost breakdown', 'تفاصيل التكلفة الواصلة'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ..._reference(
                copy.tr('Customs rules', 'قواعد الجمارك'),
                estimate.reference,
                assessmentDate,
              ),
              if (state.profile.foreignCurrency) ...[
                _line(
                  copy.tr('User-entered exchange rate', 'سعر الصرف المدخل'),
                  state.profile.text(VehicleField.exchangeRate).isEmpty
                      ? missing
                      : state.profile.text(VehicleField.exchangeRate),
                ),
                _line(
                  copy.field(VehicleField.exchangeSource),
                  state.profile.text(VehicleField.exchangeSource).isEmpty
                      ? missing
                      : state.profile.text(VehicleField.exchangeSource),
                ),
                _line(
                  copy.field(VehicleField.exchangeDate),
                  state.profile.date(VehicleField.exchangeDate) == null
                      ? missing
                      : _date(state.profile.date(VehicleField.exchangeDate)!),
                ),
              ],
              const Divider(),
              for (final item in CostItem.values)
                _line(
                  copy.field(_costField(item)),
                  _amount(estimate.costsExact[item]),
                ),
              const Divider(),
              _line(
                copy.tr('Customs valuation', 'القيمة الجمركية'),
                _amount(estimate.customsValueExact),
              ),
              for (final entry in estimate.charges.entries) ...[
                _line(
                  '${copy.charge(entry.key)} · ${copy.chargeStatus(entry.value.status)}',
                  entry.value.status == ChargeStatus.notApplicable
                      ? '—'
                      : _amount(entry.value.amountExact),
                ),
                if (entry.value.baseExact case final base?)
                  Text(
                    copy.tr(
                      'Base ${_amount(base)} × ${_percent(entry.value.rateExact!)}',
                      'الأساس ${_amount(base)} × ${_percent(entry.value.rateExact!)}',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
              const Divider(),
              _line(
                synthetic
                    ? copy.tr(
                        'Synthetic total landed cost',
                        'إجمالي التكلفة الواصلة الاصطناعي',
                      )
                    : copy.tr(
                        'Estimated total landed cost',
                        'إجمالي التكلفة الواصلة التقديري',
                      ),
                estimate.totalExact == null
                    ? copy.tr('Incomplete estimate', 'تقدير غير مكتمل')
                    : _amount(estimate.totalExact),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _percent(Decimal rate) =>
      '${(rate * Decimal.integer(100)).format(4).replaceFirst(RegExp(r'\.?0+$'), '')}%';

  List<Widget> _reference(
    String label,
    LegalReference? reference,
    DateTime date,
  ) => [
    _line(
      label,
      reference?.verification == Verification.verified &&
              (!reference!.hasOfficialCitation || !reference.covers(date))
          ? copy.verification(null)
          : copy.verification(reference?.verification),
    ),
    if (reference == null)
      Text(
        copy.tr(
          'Legal references unavailable in this preview.',
          'المراجع القانونية غير متاحة في هذه المعاينة.',
        ),
      )
    else ...[
      _line(
        copy.tr('Effective from', 'سارية من'),
        _date(reference.effectiveFrom),
      ),
      if (reference.effectiveUntil case final end?)
        _line(copy.tr('Effective through', 'سارية حتى'), _date(end)),
      if (reference.title case final title?) Text(title),
      if (reference.url case final url?) SelectableText(url.toString()),
      if (!reference.covers(date))
        Text(
          copy.tr('Outside the applicable dates.', 'خارج نطاق تواريخ السريان.'),
        ),
    ],
  ];

  static VehicleField _costField(CostItem item) => switch (item) {
    CostItem.purchase => VehicleField.purchase,
    CostItem.freight => VehicleField.freight,
    CostItem.insurance => VehicleField.insurance,
    CostItem.otherCosts => VehicleField.otherCosts,
    CostItem.handling => VehicleField.handling,
  };

  Widget _line(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppTokens.space1),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: Text(label)),
        const SizedBox(width: AppTokens.space2),
        Expanded(flex: 2, child: Text(value, textAlign: TextAlign.end)),
      ],
    ),
  );
}
