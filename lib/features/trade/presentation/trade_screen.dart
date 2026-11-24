import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/widgets/form_language_button.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/theme/app_tokens.dart';
import '../../dangerous_goods/domain/dg_models.dart';
import '../../dangerous_goods/presentation/dg_copy.dart';
import '../../dangerous_goods/presentation/dg_hub.dart';
import '../data/local_trade_data.dart';
import '../domain/decimal.dart';
import '../domain/incoterms.dart';
import '../domain/shipment.dart';
import '../domain/tariff_provider.dart';
import 'trade_copy.dart';
import 'trade_cubit.dart';
import 'trade_results.dart';
import 'trade_widgets.dart';

Future<void> openTrade(BuildContext context, AppCopy copy, TradeMode mode) =>
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TradeScreen(copy: copy, mode: mode),
      ),
    );

class TradeScreen extends StatelessWidget {
  const TradeScreen({
    super.key,
    required this.copy,
    required this.mode,
    this.provider = const LocalTariffs(),
  });

  final AppCopy copy;
  final TradeMode mode;
  final TariffProvider provider;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => TradeCubit(mode, provider: provider),
    child: _TradeFlow(copy: TradeCopy(liveFormCopy(context, copy))),
  );
}

class _TradeFlow extends StatefulWidget {
  const _TradeFlow({required this.copy});
  final TradeCopy copy;

  @override
  State<_TradeFlow> createState() => _TradeFlowState();
}

class _TradeFlowState extends State<_TradeFlow> {
  final _scroll = ScrollController();
  int _revision = 0;
  TradeCopy get copy => widget.copy;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _replaceDraft(VoidCallback action) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _revision++);
    action();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TradeCubit>();
    return BlocConsumer<TradeCubit, TradeState>(
      listenWhen: (previous, next) =>
          previous.step != next.step || (!previous.submitted && next.submitted),
      listener: (context, state) {
        FocusScope.of(context).unfocus();
        if (_scroll.hasClients) _scroll.jumpTo(0);
      },
      builder: (context, state) {
        final shipment = state.shipment;
        final progress = state.step.index + 1;
        return PopScope<void>(
          canPop: state.step == TradeStep.shipment,
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
                key: const ValueKey('trade-scroll'),
                controller: _scroll,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(AppTokens.space4),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: Column(
                        key: ValueKey((state.step, _revision)),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            copy.tr(
                              'Step $progress of 5',
                              'الخطوة $progress من 5',
                            ),
                          ),
                          const SizedBox(height: AppTokens.space2),
                          LinearProgressIndicator(value: progress / 5),
                          const SizedBox(height: AppTokens.space4),
                          Semantics(
                            header: true,
                            child: Text(
                              copy.step(state.step),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          const SizedBox(height: AppTokens.space3),
                          TradePanel(
                            highlight: true,
                            children: [
                              Text(
                                shipment.synthetic ? copy.demo : copy.notice,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTokens.space4),
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
                            TradeStep.shipment => _shipment(state, cubit),
                            TradeStep.freight => _freight(state, cubit),
                            TradeStep.costs => _costs(state, cubit),
                            TradeStep.review => [
                              _Review(copy: copy, state: state),
                            ],
                            TradeStep.result => [
                              TradeResults(copy: copy, state: state),
                            ],
                          },
                          const SizedBox(height: AppTokens.space4),
                          Wrap(
                            spacing: AppTokens.space3,
                            runSpacing: AppTokens.space2,
                            children: [
                              if (state.step != TradeStep.shipment)
                                OutlinedButton(
                                  key: const ValueKey('trade-back'),
                                  onPressed: state.loading ? null : cubit.back,
                                  child: Text(
                                    state.step == TradeStep.result
                                        ? copy.tr(
                                            'Edit and recalculate',
                                            'تعديل وإعادة الحساب',
                                          )
                                        : copy.tr('Back', 'السابق'),
                                  ),
                                ),
                              if (state.step != TradeStep.result)
                                FilledButton(
                                  key: const ValueKey('trade-next'),
                                  onPressed: state.loading
                                      ? null
                                      : () {
                                          FocusScope.of(context).unfocus();
                                          cubit.next();
                                        },
                                  child: Text(
                                    state.loading
                                        ? copy.tr(
                                            'Calculating…',
                                            'جارٍ الحساب…',
                                          )
                                        : state.step == TradeStep.review
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _shipment(TradeState state, TradeCubit cubit) {
    final shipment = state.shipment;
    return [
      TradeChoice(
        key: const ValueKey('trade-mode'),
        label: copy.tr('Calculation mode', 'وضع الحساب'),
        value: shipment.mode,
        options: TradeMode.values,
        copy: copy,
        onChanged: (mode) => _replaceDraft(() => cubit.editDraft(mode: mode)),
      ),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          key: const ValueKey('trade-demo'),
          icon: Icon(
            shipment.synthetic ? Icons.restart_alt : Icons.science_outlined,
          ),
          onPressed: () =>
              _replaceDraft(shipment.synthetic ? cubit.reset : cubit.loadDemo),
          label: Text(
            shipment.synthetic
                ? copy.tr('Start a blank estimate', 'ابدأ تقديرًا فارغًا')
                : copy.tr('Load synthetic example', 'حمّل مثالًا اصطناعيًا'),
          ),
        ),
      ),
      const SizedBox(height: AppTokens.space2),
      TradeGrid(
        children: [
          TradeChoice(
            label: copy.tr('Transport mode', 'وسيلة النقل'),
            value: shipment.transport,
            options: Transport.values,
            copy: copy,
            onChanged: (transport) => cubit.editDraft(transport: transport),
          ),
          TradeChoice(
            label: copy.tr('Incoterms 2020 rule', 'شرط إنكوترمز 2020'),
            value: shipment.term,
            options: Incoterm.values
                .where((term) => term.supports(shipment.transport))
                .toList(),
            copy: copy,
            onChanged: (term) => cubit.editDraft(term: term),
          ),
        ],
      ),
      const SizedBox(height: AppTokens.space3),
      _TermPanel(copy: copy, term: shipment.term),
      const SizedBox(height: AppTokens.space4),
      Text(
        copy.tr(
          'Use one shipment currency. An entered invoice total takes priority over quantity × unit price. Enter total CBM or use the dimensions of identical packages.',
          'استخدم عملة شحنة واحدة. تُقدّم قيمة الفاتورة المدخلة على حاصل ضرب الكمية في سعر الوحدة. أدخل الحجم الإجمالي أو استخدم أبعاد الطرود المتطابقة.',
        ),
      ),
      const SizedBox(height: AppTokens.space3),
      _fields(state, cubit),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          key: const ValueKey('trade-dg-hub'),
          icon: const Icon(Icons.warning_amber_outlined),
          label: Text(DgCopy(copy.app).title),
          onPressed: () => openDgHub(
            context,
            copy.app,
            mode: switch (shipment.transport) {
              Transport.air => DgMode.air,
              Transport.sea => DgMode.sea,
              Transport.road => DgMode.road,
            },
          ),
        ),
      ),
    ];
  }

  List<Widget> _freight(TradeState state, TradeCubit cubit) {
    final shipment = state.shipment;
    return [
      if (shipment.transport == Transport.sea) ...[
        TradeChoice(
          label: copy.tr('Sea loading type', 'نوع الشحن البحري'),
          value: shipment.seaLoad,
          options: SeaLoad.values,
          copy: copy,
          onChanged: (load) =>
              _replaceDraft(() => cubit.editDraft(seaLoad: load)),
        ),
        const SizedBox(height: AppTokens.space3),
      ],
      Text(switch (shipment.transport) {
        Transport.air => copy.tr(
          'Air calculation uses the larger of gross and volumetric weight. Enter the carrier’s divisor, optional upward billing increment and minimum base charge.',
          'يستخدم حساب الشحن الجوي الأكبر من الوزن الإجمالي والحجمي. أدخل معامل الناقل ووحدة التقريب لأعلى اختياريًا والحد الأدنى للأجرة.',
        ),
        Transport.sea when shipment.seaLoad == SeaLoad.lcl => copy.tr(
          'LCL uses the larger of cubic metres and gross kg divided by the carrier’s kg per W/M unit.',
          'يستخدم الشحن المجمّع الأكبر من الحجم بالمتر المكعب والوزن الإجمالي مقسومًا على كجم لكل وحدة وزن أو قياس لدى الناقل.',
        ),
        Transport.sea => copy.tr(
          'FCL uses the entered charge per container multiplied by the number of containers.',
          'يُحسب الشحن بالحاوية الكاملة بضرب السعر المدخل للحاوية في عدد الحاويات.',
        ),
        Transport.road => copy.tr(
          'Enter the full road charge from your assumptions. Distance, weight and volume describe the scope.',
          'أدخل أجرة النقل البري الكاملة وفق افتراضاتك. توضح المسافة والوزن والحجم نطاق الأجرة.',
        ),
      }),
      Text(
        copy.tr(
          'Enter 0 where a minimum or surcharge is explicitly zero.',
          'أدخل صفرًا عندما يكون الحد الأدنى أو الرسم الإضافي صفرًا بالفعل.',
        ),
      ),
      const SizedBox(height: AppTokens.space3),
      _fields(state, cubit),
    ];
  }

  List<Widget> _costs(TradeState state, TradeCubit cubit) {
    final shipment = state.shipment;
    return [
      if (state.costFields.isNotEmpty)
        Text(
          copy.tr(
            'Confirm the treatment of each line. Mark costs already covered by the invoice or another counted line as included.',
            'أكد كيفية احتساب كل بند. ضع علامة «مدرج» على التكاليف التي تغطيها الفاتورة أو بند آخر محسوب.',
          ),
        ),
      if (shipment.mode == TradeMode.landed &&
          (shipment.term.sellerPaysMainCarriage ||
              shipment.term.sellerHandlesImport))
        Text(
          copy.tr(
            'The selected term assigns some costs to the seller. Check the invoice before adding freight, insurance or import charges.',
            'يحمّل الشرط المحدد البائع بعض التكاليف. افحص الفاتورة قبل إضافة الشحن أو التأمين أو رسوم الاستيراد.',
          ),
        ),
      if (shipment.mode == TradeMode.export) ...[
        const SizedBox(height: AppTokens.space3),
        TradeChoice(
          label: copy.tr('Profit basis', 'أساس الربح'),
          value: shipment.priceGoal,
          options: PriceGoal.values,
          copy: copy,
          onChanged: (goal) => cubit.editDraft(priceGoal: goal),
        ),
      ],
      const SizedBox(height: AppTokens.space3),
      _fields(state, cubit),
      const SizedBox(height: AppTokens.space4),
      if (state.costFields.isNotEmpty)
        TradeGrid(
          children: [
            for (final cost in state.costFields)
              TradePanel(
                key: ValueKey(cost),
                children: [
                  TradeChoice(
                    label: copy.cost(cost),
                    value: shipment.treatments[cost],
                    options: cost == Cost.production
                        ? const [Treatment.additional]
                        : Treatment.values,
                    copy: copy,
                    onChanged: (treatment) =>
                        cubit.editDraft(cost: cost, treatment: treatment),
                  ),
                  if (shipment.treatments[cost] == Treatment.additional)
                    if (cost == Cost.freight)
                      Padding(
                        padding: const EdgeInsets.only(top: AppTokens.space2),
                        child: Text(
                          copy.tr(
                            'Uses the freight step result, including surcharges.',
                            'يستخدم نتيجة خطوة الشحن بما فيها الرسوم الإضافية.',
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: AppTokens.space2),
                        child: _Input(
                          label: copy.tr(
                            'Amount · ${copy.cost(cost)}',
                            'المبلغ · ${copy.cost(cost)}',
                          ),
                          value: shipment.costs[cost] ?? '',
                          numeric: true,
                          onChanged: (value) =>
                              cubit.editDraft(cost: cost, value: value),
                          error:
                              state.submitted &&
                                  (shipment.costs[cost]?.trim().isNotEmpty ??
                                      false) &&
                                  Decimal.parse(shipment.costs[cost]!) == null
                              ? copy.issue(InputIssue.numeric)
                              : null,
                        ),
                      ),
                ],
              ),
          ],
        ),
    ];
  }

  Widget _fields(TradeState state, TradeCubit cubit) => TradeGrid(
    children: [
      for (final field in state.fields(state.step))
        _Input(
          key: ValueKey('trade-${field.name}'),
          label: state.required(field)
              ? copy.field(field, state.shipment)
              : '${copy.field(field, state.shipment)} ${copy.tr('(optional)', '(اختياري)')}',
          value: state.shipment.text(field),
          numeric: TradeState.numeric(field),
          error: state.submitted && state.issue(field) != null
              ? copy.issue(state.issue(field)!)
              : null,
          onChanged: (value) => cubit.editDraft(field: field, value: value),
        ),
    ],
  );
}

class _Input extends StatelessWidget {
  const _Input({
    super.key,
    required this.label,
    required this.value,
    required this.numeric,
    required this.onChanged,
    this.error,
  });

  final String label, value;
  final bool numeric;
  final String? error;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: AppTokens.space1),
      Semantics(
        label: label,
        child: TextFormField(
          initialValue: value,
          decoration: const InputDecoration(),
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          onChanged: onChanged,
        ),
      ),
      if (error case final message?)
        Semantics(
          liveRegion: true,
          child: Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
    ],
  );
}

class _TermPanel extends StatelessWidget {
  const _TermPanel({required this.copy, required this.term});
  final TradeCopy copy;
  final Incoterm term;

  @override
  Widget build(BuildContext context) => TradePanel(
    title: '${term.name.toUpperCase()} · ${copy.transportScope(term)}',
    children: [
      TradeValue(
        copy.tr('Cost allocation', 'توزيع التكاليف'),
        copy.allocation(term),
      ),
      TradeValue(copy.tr('Risk transfer', 'انتقال المخاطر'), copy.risk(term)),
    ],
  );
}

class _Review extends StatelessWidget {
  const _Review({required this.copy, required this.state});
  final TradeCopy copy;
  final TradeState state;

  @override
  Widget build(BuildContext context) {
    final shipment = state.shipment;
    final cubit = context.read<TradeCubit>();
    final unavailable = copy.option(Provenance.unavailable);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${copy.option(shipment.mode)} · ${copy.option(shipment.transport)} · ${shipment.currency}',
        ),
        const SizedBox(height: AppTokens.space3),
        _TermPanel(copy: copy, term: shipment.term),
        for (final step in TradeStep.values.take(3)) ...[
          const SizedBox(height: AppTokens.space3),
          TradePanel(
            title: copy.step(step),
            children: [
              if (step == TradeStep.freight &&
                  shipment.transport == Transport.sea)
                Text(copy.option(shipment.seaLoad)),
              if (step == TradeStep.costs && shipment.mode == TradeMode.export)
                Text(copy.option(shipment.priceGoal)),
              for (final field in state.fields(step))
                if (shipment.text(field).isNotEmpty)
                  TradeValue(copy.field(field, shipment), shipment.text(field)),
              if (step == TradeStep.shipment) ...[
                TradeValue(
                  copy.tr('Resolved cargo value', 'قيمة البضاعة المعتمدة'),
                  shipment.cargoValue?.format() ?? unavailable,
                ),
                TradeValue(
                  copy.tr('Resolved volume (CBM)', 'الحجم المعتمد (م³)'),
                  shipment.volume?.format(6) ?? unavailable,
                ),
              ],
              if (step == TradeStep.costs)
                for (final cost in state.costFields)
                  TradeValue(copy.cost(cost), _costValue(cost)),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: state.loading ? null : () => cubit.go(step),
                  child: Text(
                    copy.tr(
                      'Edit ${copy.step(step).toLowerCase()}',
                      'تعديل ${copy.step(step)}',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _costValue(Cost cost) {
    final treatment = state.shipment.treatments[cost];
    if (treatment == null) return copy.option(Provenance.unavailable);
    final label = copy.option(treatment);
    final amount = state.shipment.costs[cost];
    return treatment == Treatment.additional && cost != Cost.freight
        ? '$label · ${amount?.isNotEmpty == true ? amount : copy.option(Provenance.unavailable)}'
        : label;
  }
}
