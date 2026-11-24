import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_tokens.dart';
import '../domain/decimal.dart';
import '../domain/shipment.dart';
import 'trade_copy.dart';
import 'trade_cubit.dart';
import 'trade_widgets.dart';

class TradeResults extends StatelessWidget {
  const TradeResults({super.key, required this.copy, required this.state});
  final TradeCopy copy;
  final TradeState state;

  String get unavailable => copy.option(Provenance.unavailable);
  String money(Decimal? value, String currency) =>
      value == null ? unavailable : '${value.format()} $currency';

  @override
  Widget build(BuildContext context) {
    final result = state.result!;
    final shipment = result.shipment;
    final freight = result.freight;
    final showFreight =
        shipment.mode == TradeMode.freight ||
        shipment.treatments[Cost.freight] == Treatment.additional;
    final missing = [
      if (shipment.mode == TradeMode.landed && result.cargoValue == null)
        copy.field(Field.invoice, shipment),
      for (final line in result.lines)
        if (line.provenance == Provenance.unavailable) copy.cost(line.cost),
      if (showFreight)
        for (final issue in freight.missing) copy.freightInput(issue, shipment),
      if (shipment.mode == TradeMode.export &&
          shipment.number(Field.goal) == null)
        copy.field(Field.goal, shipment),
      if (shipment.text(Field.quoteCurrency).isNotEmpty &&
          result.conversion == null)
        copy.field(Field.fx, shipment),
      if (shipment.text(Field.fx).isNotEmpty &&
          shipment.text(Field.quoteCurrency).isEmpty)
        copy.field(Field.quoteCurrency, shipment),
    ];
    final totalLabel = switch (shipment.mode) {
      TradeMode.landed => copy.tr(
        'Total landed cost',
        'إجمالي التكلفة الواصلة',
      ),
      TradeMode.export => copy.tr('Total export cost', 'إجمالي تكلفة التصدير'),
      TradeMode.freight => copy.tr(
        'Total freight estimate',
        'إجمالي تقدير الشحن',
      ),
    };
    final selected = state.saved.contains(result);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TradePanel(
          highlight: true,
          title: copy.option(shipment.mode),
          children: [
            TradeValue(
              totalLabel,
              result.total == null
                  ? copy.tr('Incomplete estimate', 'تقدير غير مكتمل')
                  : money(result.total, shipment.currency),
              emphasis: true,
            ),
            if (result.unitCost != null)
              TradeValue(
                '${copy.tr('Cost per unit', 'التكلفة لكل وحدة')} · ${shipment.text(Field.unit)}',
                money(result.unitCost, shipment.currency),
              ),
            if (result.perKg != null)
              TradeValue(
                copy.tr('Cost per gross kg', 'التكلفة لكل كجم إجمالي'),
                money(result.perKg, shipment.currency),
              ),
            if (result.conversion case final fx?) ...[
              TradeValue(
                copy.tr('Converted total', 'الإجمالي بعد التحويل'),
                money(result.convertedTotal, fx.currency),
              ),
              TradeValue(
                copy.tr('Exchange rate', 'سعر الصرف'),
                '${fx.rate.format(6)} ${fx.currency}/${shipment.currency} · ${copy.option(fx.provenance)}',
              ),
              TradeValue(
                copy.field(Field.fxSource, shipment),
                _optional(fx.source),
              ),
              TradeValue(
                copy.field(Field.fxDate, shipment),
                _optional(fx.date),
              ),
            ],
          ],
        ),
        if (missing.isNotEmpty || state.providerFailed) ...[
          const SizedBox(height: AppTokens.space3),
          TradePanel(
            title: copy.tr('Missing information', 'بيانات ناقصة'),
            children: [
              if (state.providerFailed)
                Text(
                  copy.tr(
                    'The tariff source did not respond. Unavailable charges remain unresolved.',
                    'لم يستجب مصدر التعرفة. الرسوم غير المتاحة تظل غير محسومة.',
                  ),
                ),
              for (final item in missing.toSet()) Text('• $item'),
            ],
          ),
        ],
        if (shipment.mode == TradeMode.export) ...[
          const SizedBox(height: AppTokens.space3),
          TradePanel(
            title: copy.tr(
              'Export price and profitability',
              'سعر التصدير والربحية',
            ),
            children: [
              Text(copy.option(shipment.priceGoal)),
              if (shipment.text(Field.goal).isNotEmpty)
                TradeValue(
                  copy.field(Field.goal, shipment),
                  '${shipment.text(Field.goal)}%',
                ),
              TradeValue(
                copy.tr('Break-even selling price', 'سعر البيع عند التعادل'),
                money(result.total, shipment.currency),
              ),
              TradeValue(
                copy.tr('Proposed selling price', 'سعر البيع المقترح'),
                money(result.price, shipment.currency),
                emphasis: true,
              ),
              TradeValue(
                copy.tr('Selling price per unit', 'سعر البيع لكل وحدة'),
                money(result.pricePerUnit, shipment.currency),
              ),
              TradeValue(
                copy.tr('Expected profit', 'الربح المتوقع'),
                money(result.profit, shipment.currency),
              ),
              TradeValue(
                copy.tr('Expected profit margin', 'هامش الربح المتوقع'),
                result.margin == null
                    ? unavailable
                    : '${result.margin!.format()}%',
              ),
            ],
          ),
        ],
        if (showFreight) ...[
          const SizedBox(height: AppTokens.space3),
          TradePanel(
            title: copy.tr('Freight breakdown', 'تفاصيل الشحن'),
            children: [
              if (shipment.number(Field.gross) case final gross?)
                TradeValue(copy.field(Field.gross, shipment), gross.format(3)),
              if (shipment.volume case final volume?)
                TradeValue(
                  copy.field(Field.volume, shipment),
                  volume.format(6),
                ),
              if (shipment.transport == Transport.air)
                TradeValue(
                  copy.tr('Volumetric weight (kg)', 'الوزن الحجمي (كجم)'),
                  freight.volumetricKg?.format(3) ?? unavailable,
                ),
              if (shipment.transport != Transport.road)
                TradeValue(switch (shipment.transport) {
                  Transport.air => copy.tr(
                    'Chargeable weight (kg)',
                    'الوزن المحاسبي (كجم)',
                  ),
                  Transport.sea when shipment.seaLoad == SeaLoad.fcl =>
                    copy.field(Field.containers, shipment),
                  _ => copy.tr(
                    'Billable W/M units',
                    'وحدات الوزن أو القياس المحاسبية',
                  ),
                }, freight.units?.format(3) ?? unavailable),
              TradeValue(
                copy.tr('Base freight', 'أجرة الشحن الأساسية'),
                money(freight.base, shipment.currency),
              ),
              TradeValue(
                copy.field(Field.surcharge, shipment),
                money(freight.surcharges, shipment.currency),
              ),
            ],
          ),
        ],
        if (result.lines.isNotEmpty) ...[
          const SizedBox(height: AppTokens.space3),
          TradePanel(
            title: copy.tr('Itemized costs', 'التكاليف المفصلة'),
            children: [
              if (shipment.mode == TradeMode.landed) ...[
                TradeValue(
                  copy.tr(
                    'Product or invoice value',
                    'قيمة المنتج أو الفاتورة',
                  ),
                  money(result.cargoValue, shipment.currency),
                ),
                TradeValue(
                  copy.field(Field.valuation, shipment),
                  money(result.valuation, shipment.currency),
                ),
              ],
              for (final line in result.lines)
                TradeValue(copy.cost(line.cost), switch (line.treatment) {
                  Treatment.additional when line.amount != null =>
                    '${money(line.amount, shipment.currency)} · ${copy.option(line.provenance)}',
                  Treatment.included ||
                  Treatment.excluded => copy.option(line.treatment!),
                  _ => unavailable,
                }),
            ],
          ),
        ],
        const SizedBox(height: AppTokens.space3),
        TradePanel(
          title: copy.tr(
            'Assumptions and provenance',
            'الافتراضات ومصادر القيم',
          ),
          children: [
            TradeValue(
              copy.tr('Local calculation', 'حساب محلي'),
              'V1 · ${result.calculatedOn.toIso8601String().substring(0, 10)} · ${copy.option(shipment.provenance)}',
            ),
            TradeValue(
              copy.tr('Route', 'المسار'),
              '${shipment.text(Field.origin)} / ${shipment.text(Field.departure)} → ${shipment.text(Field.destination)} / ${shipment.text(Field.arrival)}',
            ),
            TradeValue(
              copy.tr('Incoterms 2020 rule', 'شرط إنكوترمز 2020'),
              '${shipment.term.name.toUpperCase()} · ${shipment.text(Field.namedPlace)}',
            ),
            TradeValue(
              copy.tr('Cost allocation', 'توزيع التكاليف'),
              copy.allocation(shipment.term),
            ),
            TradeValue(
              copy.tr('Risk transfer', 'انتقال المخاطر'),
              copy.risk(shipment.term),
            ),
            TradeValue(
              copy.field(Field.carrierNote, shipment),
              _optional(shipment.text(Field.carrierNote)),
            ),
            if (showFreight)
              for (final field in state.fields(TradeStep.freight))
                if (field != Field.carrierNote &&
                    shipment.text(field).isNotEmpty)
                  TradeValue(copy.field(field, shipment), shipment.text(field)),
            if (result.tariff case final tariff?)
              TradeValue(
                copy.tr('Tariff source', 'مصدر التعرفة'),
                '${tariff.source} · ${tariff.version} · ${tariff.effectiveFrom.toIso8601String().substring(0, 10)}',
              ),
            Text(
              copy.tr(
                'Monetary lines round to two decimals, half up. The proposed selling total rounds upward to retain the target. Customs valuation is a reference base. Included and out-of-scope charges add nothing to the total.',
                'تُقرّب البنود النقدية إلى منزلتين، مع التقريب لأعلى عند المنتصف. يُقرّب إجمالي سعر البيع المقترح لأعلى للحفاظ على الهدف. القيمة الجمركية أساس مرجعي، والبنود المدرجة وخارج النطاق لا تُضاف إلى الإجمالي.',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTokens.space3),
        TradePanel(
          title: copy.tr(
            'Compare local scenarios',
            'مقارنة السيناريوهات محليًا',
          ),
          children: [
            Text(
              copy.tr(
                'Save up to three results in this session. Edit and recalculate to compare different assumptions.',
                'احفظ حتى ثلاث نتائج في هذه الجلسة. غيّر الافتراضات ثم أعد الحساب للمقارنة.',
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const ValueKey('trade-save'),
                onPressed: context.read<TradeCubit>().toggleSaved,
                icon: Icon(
                  selected
                      ? Icons.bookmark_remove_outlined
                      : Icons.bookmark_add_outlined,
                ),
                label: Text(
                  selected
                      ? copy.tr('Remove saved result', 'احذف النتيجة المحفوظة')
                      : copy.tr('Save for comparison', 'احفظ للمقارنة'),
                ),
              ),
            ),
            for (final (index, saved) in state.saved.indexed) ...[
              const Divider(),
              TradeValue(
                copy.tr('Scenario ${index + 1}', 'السيناريو ${index + 1}'),
                '${copy.option(saved.shipment.mode)} · ${copy.option(saved.shipment.provenance)}',
                emphasis: true,
              ),
              TradeValue(
                saved.shipment.text(Field.product),
                saved.total == null
                    ? copy.tr('Incomplete estimate', 'تقدير غير مكتمل')
                    : money(saved.total, saved.shipment.currency),
              ),
              if (saved.unitCost != null)
                TradeValue(
                  copy.tr('Cost per unit', 'التكلفة لكل وحدة'),
                  '${money(saved.unitCost, saved.shipment.currency)} / ${saved.shipment.text(Field.unit)}',
                ),
              if (saved.price != null)
                TradeValue(
                  copy.tr('Proposed selling price', 'سعر البيع المقترح'),
                  money(saved.price, saved.shipment.currency),
                ),
            ],
          ],
        ),
      ],
    );
  }

  String _optional(String? value) =>
      value == null || value.isEmpty ? unavailable : value;
}
