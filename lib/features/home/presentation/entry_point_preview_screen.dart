import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/state/app_view_state.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_state_panel.dart';
import '../../../core/widgets/index_button.dart';
import '../../directory/domain/company.dart';
import '../../journeys/domain/commercial_models.dart';
import '../../journeys/domain/local_workspace.dart';
import '../../journeys/presentation/commercial_board.dart';
import '../../journeys/presentation/directory_workspace.dart';
import '../../journeys/presentation/jobs_workspace.dart';
import '../../journeys/presentation/leopard_workspace.dart';
import '../../journeys/presentation/quote_workspace.dart';
import '../../journeys/presentation/workspace_widgets.dart';
import '../../trade/domain/shipment.dart';
import '../../trade/presentation/trade_copy.dart';
import '../../trade/presentation/trade_screen.dart';
import '../domain/home_entry_point.dart';
import '../domain/sector.dart';

class EntryPointPreviewScreen extends StatelessWidget {
  const EntryPointPreviewScreen({
    super.key,
    required this.entryPoint,
    required this.copy,
    required this.onExploreSectors,
    this.workspace,
    this.sectors = const [],
    this.companies = const [],
  });

  final HomeEntryPoint entryPoint;
  final AppCopy copy;
  final VoidCallback onExploreSectors;
  final LocalWorkspace? workspace;
  final List<Sector> sectors;
  final List<Company> companies;

  @override
  Widget build(BuildContext context) {
    final title = copy.entryPointTitle(entryPoint);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppTokens.white,
                    border: Border.all(color: AppTokens.line),
                    borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        copy.previewOnly,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTokens.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        copy.entryPointDescription(entryPoint),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 22),
                      if (entryPoint == HomeEntryPoint.importer ||
                          entryPoint == HomeEntryPoint.exporter) ...[
                        IndexButton(
                          key: const ValueKey('home-journey-trade'),
                          label: TradeCopy(copy).title,
                          icon: Icons.calculate_outlined,
                          onPressed: () => openTrade(
                            context,
                            copy,
                            entryPoint == HomeEntryPoint.importer
                                ? TradeMode.landed
                                : TradeMode.export,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      AppStatePanel(
                        state: AppViewState.empty,
                        copy: copy,
                        message: copy.entryPointSubtitle,
                        actionLabel: copy.exploreSectors,
                        onAction: onExploreSectors,
                      ),
                      if (entryPoint == HomeEntryPoint.jobs) ...[
                        const SizedBox(height: 16),
                        WorkspaceLink(
                          label: copy.local(
                            'Browse jobs and professional services',
                            'تصفح الوظائف والخدمات المهنية',
                          ),
                          onTap: () =>
                              openWorkspace(context, JobsWorkspace(copy: copy)),
                        ),
                      ],
                      if (entryPoint == HomeEntryPoint.leopard &&
                          workspace != null) ...[
                        const SizedBox(height: 16),
                        WorkspaceLink(
                          key: const ValueKey('leopard-workspace-entry'),
                          label: copy.local(
                            'Open Leopard service preview',
                            'افتح معاينة خدمات ليوبارد',
                          ),
                          onTap: () => openWorkspace(
                            context,
                            LeopardWorkspace(copy: copy, workspace: workspace!),
                          ),
                        ),
                      ],
                      if (workspace != null &&
                          (entryPoint == HomeEntryPoint.importer ||
                              entryPoint == HomeEntryPoint.exporter)) ...[
                        const SizedBox(height: 16),
                        WorkspaceLink(
                          key: const ValueKey('commercial-discovery-entry'),
                          label: copy.local(
                            'Discover products and companies',
                            'اكتشف المنتجات والشركات',
                          ),
                          onTap: () => openWorkspace(
                            context,
                            DirectoryWorkspace(
                              copy: copy,
                              workspace: workspace!,
                              sectors: sectors,
                              companies: companies,
                              exporter: entryPoint == HomeEntryPoint.exporter,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final type in [
                          CommercialType.buying,
                          CommercialType.opportunity,
                        ])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: WorkspaceLink(
                              label: commercialTypeLabel(copy, type),
                              onTap: () => openWorkspace(
                                context,
                                CommercialBoard(
                                  copy: copy,
                                  workspace: workspace!,
                                  initialType: type,
                                ),
                              ),
                            ),
                          ),
                        WorkspaceLink(
                          label: copy.local(
                            'Freight quotation draft',
                            'مسودة طلب سعر الشحن',
                          ),
                          onTap: () => openWorkspace(
                            context,
                            QuoteWorkspace(copy: copy, workspace: workspace!),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
