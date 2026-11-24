# Sprint 10 UI/UX acceptance report

## Owner review status

**Ready for review of the tested local UI. V4 acceptance remains open.** The [V4 traceability matrix](V4_TRACEABILITY_MATRIX.md) records coverage and gaps by category, sector, journey and requirement. The [backend requirements](BACKEND_REQUIREMENTS.md) are planning only.

## Implemented work packages

| Package | Implemented in this sprint | Specific evidence |
| --- | --- | --- |
| A — Directory and commercial discovery | Importer/exporter routes, product and company views, country/sector/category filters, synthetic HS search keys, sample profiles, saved items, and contact/RFQ/market links. | [Directory filter and save test](../test/sprint10_directory_test.dart), [directory UI](../lib/features/journeys/presentation/directory_workspace.dart), [Discover link](../lib/features/home/presentation/home_screen.dart). |
| B — Community, jobs and RFQ | Six structured content types, browsing/filter/details, local report and hide actions, job seeker/employer/application/post and consulting previews. RFQ route, optional time/equipment data, cargo, service and handling screens, review, in-session save/resume, comparison unavailable state and links to existing trade/DG tools. | [Commercial and draft tests](../test/sprint10_commercial_test.dart), [community](../lib/features/journeys/presentation/commercial_board.dart), [jobs](../lib/features/journeys/presentation/jobs_workspace.dart), [RFQ](../lib/features/journeys/presentation/quote_workspace.dart). |
| C — Account, messages, Leopard and admin | Unsent local conversation drafts, profile/preferences, report and hidden source management, saved items, language selection; Leopard sea/air/road/customs/logistics preparation, opportunities and consent-gated feed draft handoff. Eight staff preview areas including reports, evidence, appeals and audit. | [Account and Leopard tests](../test/sprint10_account_test.dart), [account](../lib/features/journeys/presentation/account_workspace.dart), [Leopard](../lib/features/journeys/presentation/leopard_workspace.dart), [admin](../lib/features/journeys/presentation/admin_workspace.dart). |
| D — Category gaps and acceptance | Commercial routes for importers, exporters, jobs, freight quotations, export opportunities and academy/consulting. Tailored filter scopes and an explicit unavailable result for other category sources. | [Category actions](../lib/features/journeys/presentation/category_workspace.dart), [lookup provider](../lib/features/journeys/domain/reference_lookup.dart), [scope and layout tests](../test/sprint10_acceptance_test.dart). |

## Verification

- `flutter analyze --no-pub` returned no issues.
- `flutter test --no-pub --reporter expanded` passed **148 tests**, including all **131 Sprint 1–9 regressions**.
- `git diff --check` passed. Additional scans cover whitespace in new untracked files.
- Existing regression evidence covers the six Home entries, five mobile destinations, 35 category routes and the eight industry sectors, plus guest access, state panels and vehicle, trade, and DG calculators.
- Representative Home, catalog, community and calculator widgets were exercised in Arabic RTL and English LTR at 360, 390, 768, 1280 and 1440 px, including 200% text scaling on the relevant cases. [State panel tests](../test/home_state_panel_test.dart) cover loading, empty, error, offline, expired and permission-denied UI. These are UI tests of the states, independent of backend fault injection.

## Remaining acceptance gaps

- **Local scope.** One RFQ draft, saved items, unsent messages, profile drafts, preferences, reports and hidden sources use session memory. Restart persistence, multiple draft management, logged-in member workflows, message delivery, and real quote comparison remain open. The RFQ cargo quantity and dimensions fields are free-form.
- **Category coverage.** Verified lookup data, live procedures, schedules, market records, carrier services, equipment fit, timezone tools, carbon calculations, tracking and other operational workflows remain open where indicated in the matrix. Fictional labels and HS search keys carry no real company, market or regulatory claims.
- **Regulatory and legal.** Official dated tariffs, classification and licensing, verified company and trade evidence, cold chain profiles, complete carrier rules and product notices need sources, permission and owner review. See [backend requirements](BACKEND_REQUIREMENTS.md).
- **Accessibility.** Full screen-reader, keyboard-only and contrast auditing across all new screens remains open. Settle focus and error announcement behavior in native assistive technology. The tests exercise representative layouts and widgets, not a full WCAG or native-device acceptance run.
- **Backend and security.** Identity, authorization, data and file lifecycle, server validation, publishing and delivery, private audits, operational enforcement and deployment require implementation and independent acceptance. Production payment, ads and AI remain deferred.

## Running-app evidence

The local release web build was exercised with Chrome at the following viewports. The screenshots demonstrate navigation and local states.

| Width | Screen |
| --- | --- |
| 390 px, Arabic RTL | [Leopard services and opportunities](../qa_screenshots/sprint10_leopard_ar_390.png) |
| 768 px, English LTR | [Dedicated sector filters](../qa_screenshots/sprint10_directory_en_768.png) |
| 768 px, English LTR | [Freight quotation route form](../qa_screenshots/sprint10_rfq_en_768.png) |
| 1280 px, English LTR | [Structured commercial board](../qa_screenshots/sprint10_community_en_1280.png) |

## Owner acceptance

Review the local flows and the explicit unavailable or account-required states. Approve data permissions and the release/verification plan before operational acceptance.

## Sprint 11 closure evidence

The local preview now includes typed RFQ package groups with gross weight and CBM, exact vehicle customs arithmetic, a container planner, DST-aware time comparison, payment guides, emissions and CBAM preparation, and cold-chain and special-cargo preparation. Leopard retains consent before copying a product into a local RFQ draft. Its mobile supplier and buyer tabs show honest empty states. Quotation comparison uses explicitly fictional offers on the same basis.

The opt-in RFQ package template can be saved, restored and deleted locally. The saved template contains package type, quantity, measurements and units. The rest of the RFQ and private account data remain session-only. Widget coverage verifies preservation of entered RFQ information when switching languages. Public locale support is Arabic and English. French, Italian, Hindi and Simplified Chinese remain planned.

Flutter analysis completed without issues, all 163 tests passed, and the release web build succeeded. The new route tests exercise the six category destinations at 390 px and 200% text scaling. Native assistive technology, cross-restart storage on physical devices and the full viewport and language matrix for every new tool remain open.

| Width | Running Chrome evidence |
| --- | --- |
| 1280 px, English LTR | [Container planner](../qa_screenshots/sprint11_container_en_1280.png) |
| 768 px, English LTR | [Time and meetings](../qa_screenshots/sprint11_meeting_en_768.png) |
| 390 px, Arabic RTL | [Cold chain](../qa_screenshots/sprint11_cold_chain_ar_390.png) |

See the [V4 traceability matrix](V4_TRACEABILITY_MATRIX.md) for outstanding requirements.
