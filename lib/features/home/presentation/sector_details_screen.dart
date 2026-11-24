import 'package:flutter/material.dart';

import '../../../core/localization/app_copy.dart';
import '../../../core/state/app_view_state.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_state_panel.dart';
import '../../../features/directory/domain/company.dart';
import '../../../features/directory/presentation/company_card.dart';
import '../../../features/directory/presentation/company_details_screen.dart';
import '../domain/sector.dart';

class SectorDetailsScreen extends StatelessWidget {
  const SectorDetailsScreen({
    super.key,
    required this.sector,
    required this.companies,
    required this.copy,
    required this.onHome,
  });

  final Sector sector;
  final List<Company> companies;
  final AppCopy copy;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final relatedCompanies = companies
        .where((company) => company.sectorId == sector.id)
        .toList();
    final title = copy.isArabic ? sector.titleAr : sector.titleEn;
    final description = copy.isArabic
        ? sector.descriptionAr
        : sector.descriptionEn;

    return Scaffold(
      appBar: AppBar(
        title: Text(copy.sectorsTitle),
        actions: [
          IconButton(
            tooltip: copy.homeLabel,
            onPressed: onHome,
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.maxContentWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTokens.white,
                    border: Border.all(color: AppTokens.line),
                    borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: sector.tint,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(sector.icon, color: AppTokens.navy),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        copy.sectorDemoNote,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  copy.sectorCompaniesTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (relatedCompanies.isEmpty) ...[
                  AppStatePanel(
                    state: AppViewState.empty,
                    copy: copy,
                    message: copy.noSectorCompanies,
                    actionLabel: copy.goBackToSectors,
                    onAction: () => Navigator.of(context).maybePop(),
                  ),
                ] else ...[
                  for (final company in relatedCompanies) ...[
                    CompanyCard(
                      company: company,
                      copy: copy,
                      onPrimaryAction: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CompanyDetailsScreen(
                            company: company,
                            copy: copy,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
