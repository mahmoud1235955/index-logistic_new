# V4 traceability matrix

Baseline [Index Logistics Master Execution Spec V4](<../Index_Logistics_Master_Execution_Spec_V4_AR_Print(1).pdf>), especially §§4–25. The acceptance rows refer to the V4 IDs, independently of the app sprint numbers.

**Status key** — Tested = implemented and tested at the described scope. Partial = partially implemented. Preview = preview only. Missing = no implementation or evidence. External = requires verified external data. Backend = requires backend or integration. Deferred = deferred in V4. Combined statuses indicate different parts of a requirement.

## Catalog and sectors

The catalog metadata, bilingual search and all 35 detail routes are tested independently of the service statuses below. Source and navigation evidence are in the [catalog repository](../lib/features/catalog/data/local_category_repository.dart), [catalog tests](../test/sprint6_catalog_test.dart), and [Sprint 10 catalog routes](../lib/features/journeys/presentation/category_workspace.dart).

| V4 ID | Category | Service status | Repository evidence and remainder |
| --- | --- | --- | --- |
| CAT-01 | Importers | Partial | Commercial directory, importer context, filters and sample contacts. Verified importer-to-origin evidence unavailable. |
| CAT-02 | Exporters | Partial | Exporter discovery, bilingual sample products and category/HS-key search. Real market and supplier evidence unavailable. |
| CAT-03 | Cars and vehicles | Partial | Vehicle eligibility and exact-decimal monetary engine with synthetic scenarios. Legacy read-only numeric adapters remain for callers. Verified rules and tariffs required. |
| CAT-04 | Insurance | Preview | Jurisdiction, cargo and service scope. Policy coverage and quotation records unavailable. |
| CAT-05 | Inspection, monitoring and quality | Preview | Jurisdiction, specialty and service scope. Accredited inspection records unavailable. |
| CAT-06 | Exporter support organizations | Preview | Country, sector/product and source scope. Verified organizations and programs unavailable. |
| CAT-07 | Customs yards and warehouses | Preview | Service area, licence and service scope. Facility records unavailable. |
| CAT-08 | Domestic transport | Preview | Service area, destination and equipment scope. Carrier coverage and capacity unavailable. |
| CAT-09 | Shipping lines and vessels | Preview | Port, route, carrier and date scope plus DG link. Schedules, brokerage and vessel records unavailable. |
| CAT-10 | Airlines and air cargo | Preview | Origin airport, destination and operator scope plus air DG link. Air cargo data and charter workflow unavailable. |
| CAT-11 | International road transport | Preview | Country, destination and equipment scope plus road DG link. Cross-border service and rate data unavailable. |
| CAT-12 | Freight forwarders | Preview | Country, destination and service scope. Dated coverage and licensing evidence unavailable. |
| CAT-13 | Express shipping and post | Preview | Route and product scope. Carrier limits, rating and tracking unavailable. |
| CAT-14 | Commercial representation | Preview | Country, service area and source scope. Verified representatives and offices unavailable. |
| CAT-15 | Exhibitions and events | Preview | Country, specialty, organizer and date scope, including unavailable state test. Event feed, validity and registration unavailable. |
| CAT-16 | Containers, containerization and stowage | Partial | Standalone typed package and container worksheet checks payload, volume and individual orientations through the door. Combined loading, equipment certification and optimization remain open. |
| CAT-17 | Customs clearance | Preview | Country, port and licence scope. Verified broker credentials and quote service unavailable. |
| CAT-18 | Packaging and supporting equipment | Preview | Product, equipment and service scope plus DG preparation link. Verified packaging specifications unavailable. |
| CAT-19 | Customs platforms and procedures | Preview | Country, procedure and source scope. Official procedural records unavailable. |
| CAT-20 | Intelligent trade and logistics advisor | Preview | Scope form only. Public source retrieval, responses and private-data isolation are open. |
| CAT-21 | Personal baggage and relocation | Preview | Destination, product and date scope. Applicable baggage rules and carrier data unavailable. |
| CAT-22 | Special imports and non-standard shipments | Preview | Destination, permit and product scope. Applicable exemptions and guided applications remain open. |
| CAT-23 | Personal imports and e-commerce | Preview | Destination, product and procedure scope. Verified thresholds and e-commerce rules unavailable. |
| CAT-24 | Jobs and expertise | Partial | Fictional specialties, details, employer/seeker, post, consultation and application previews. Real employer identity, vacancies and applications require integration. |
| CAT-25 | Time and meetings | Partial | Live clocks, named-zone comparisons with bundled IANA 2025c data, clock-change gap and overlap handling, and session meeting preparation. Wider zone selection, tzdata maintenance and meeting integrations remain open. |
| CAT-26 | Currencies and financial information | Partial | Pair/date/source scope and trade calculator manual conversion. Sourced FX and financial feeds unavailable. |
| CAT-27 | Shipping costs and quote requests | Partial | Decimal freight estimate, typed RFQ package groups, exact gross mass and CBM, opt-in persistent package templates and synthetic comparison. Actual offers, delivery and quote matching remain open. |
| CAT-28 | Trade terms and payment methods | Partial | All 11 Incoterms in trade wizard and original bilingual guides for five payment methods. Banking/settlement integration remains open. |
| CAT-29 | Shipment and container tracking | Preview | Carrier and sample reference scope. Tracking events, authorizations and carrier integration unavailable. |
| CAT-30 | Carbon footprint and CBAM | Partial | Separate transport estimate, provided-intensity product worksheet and CBAM evidence preparation. Verified factors, regulatory methodology, charges and compliance assessment remain open. |
| CAT-31 | Customs, taxes and landed cost | Partial | Vehicle and trade calculators separate. Sourced tariff, effective rules and clearance integration remain open. |
| CAT-32 | Export opportunities, purchase requests and markets | Partial | Structured fictional opportunities and purchase requests. Dated market and verified buyer evidence unavailable. |
| CAT-33 | Dangerous goods and special shipments | Partial | Existing DG readiness plus oversized, heavy, temperature-sensitive and other preparation worksheets. Licensed rule data, route clearance, handling approval and operational workflows remain open. |
| CAT-34 | Cold chain | Partial | Chilled/frozen preparation, supplied Celsius range validation and readiness checklist. Verified commodity profiles, sensor monitoring and compliance remain open. |
| CAT-35 | Academy, library and consulting | Partial | Local preparation, glossary and source-checking topics plus consulting preview. Licensed library, enrollment and real advisor contact missing. |

| V4 sector (§6) | Sector | Status |
| --- | --- | --- |
| SEC-01 | Food and agricultural crops | Tested taxonomy; partial sample directory coverage. |
| SEC-02 | Textiles, clothing and leather | Tested taxonomy; partial sample directory coverage. |
| SEC-03 | Chemicals and fertilizers | Tested taxonomy; partial sample directory coverage. |
| SEC-04 | Construction materials and metals | Tested taxonomy; partial sample directory coverage. |
| SEC-05 | Engineering, electronics and appliances | Tested taxonomy; partial sample directory coverage. |
| SEC-06 | Medicines and medical supplies | Tested taxonomy; partial sample directory coverage. |
| SEC-07 | Handicrafts and heritage products | Tested taxonomy; partial sample directory coverage. |
| SEC-08 | Furniture and wood industries | Tested taxonomy; partial sample directory coverage. |

The [Home fixtures](../lib/features/home/data/home_mock_data.dart), [catalog tests](../test/sprint6_catalog_test.dart) and [dedicated filter test](../test/sprint10_directory_test.dart) establish the eight existing IDs and filter entry. Sample products intentionally cover a subset of sectors. Complete products, HS, countries, branches and cross-sector evidence remain External.

## User journeys

| Journey | Status | Evidence and remainder |
| --- | --- | --- |
| Home / access / Discover | Tested / Partial | Six entry points, five tabs, guest welcome, discover search and account-gated action previews. See widget, access and Home tests. Real account services open. |
| Importer and exporter | Partial | Commercial discovery, role context, sample profiles/products, saved items, opportunities, buying requests, calculator and contact/RFQ links. Real market evidence, roles and member decisions open. |
| Community | Partial | Six typed content categories, filters, detail, report and hide/restore. Existing tab distinguishes the local preview entry. No real publication, replies, following or recommendation service. |
| Freight quotations | Partial | Typed package groups and units, exact mass/volume, route/services/review, session drafts and opt-in persistent package metrics. Comparable synthetic offers only. |
| Jobs and consulting | Preview | Fictional discover/details, employer/seeker, post, application and consultation screens. Real application and staffing workflow open. |
| Messages and account | Preview | Fictional threads, unsent drafts, saved items, profile/preferences, privacy, reporting/hiding and switching language. Profile publication or delivery requires an account and integration. |
| Leopard and feed opportunities | Partial | Service scope, shortages of verified data exposed, opportunity link and consent-gated copying of only the feed name. Quotes and service availability open. |
| Admin and moderation | Preview | Staff workflow screens and local reports. Role authorization, workflow transitions, evidence, appeals and audit enforcement open. |
| Vehicle, trade and DG | Partial | Existing calculation and readiness regression coverage. Official rules and operation remain subject to External/Backend dependencies. |

## Cross-cutting V4 requirements

| V4 requirements | Status | Scope and gap |
| --- | --- | --- |
| UX-01–03 | Tested / Partial | Six Home paths, five tabs, 35 categories and eight sectors have navigation tests. Dedicated sector filters open from Discover. Populate real records and test user paths on devices. |
| UX-04–07 | Partial | Company cards, HS demo search and RFQ preparation exist. Real HS/UN evidence, company relations and quote lifecycle are open. |
| UX-08–11 | Partial | Shared state panels cover loading, empty, error, offline, expired and permission denial. EN/AR widths and 200% tested in representative workflows. Full keyboard/screen-reader and native QA open. |
| UX-12–14 | Partial | Guest and account-required previews, optional static walkthrough and glossary. Five-person V4 usability study, native accessibility verification and broader translation review remain open. |
| DATA-01–06 | Partial / External | Typed company/sector fixtures, source placeholders and evidence-gated verified badge. Canonical identity, claims, licensing, dated trade evidence and review history need data and services. |
| DATA-07–10 | Backend / External | Import, OCR, dedupe, row conflicts, provenance, consent and authoritative reference datasets open. |
| SOC-01–03 | Partial | Typed commercial content, filter, details, local reporting/hiding and unsent message drafts. Member identity, publication, replies, attachments and server block open. |
| SOC-04–08 | Backend | Case-limited message access, accountable access logging, matching, verified reviews, ranking and recipient controls open. |
| RFQ-01–04 | Partial | Route, cargo groups/units, services, handling, review and session save. Opt-in package templates retain only types, units and measurements. Actual sending, revisions and lifecycle remain open. |
| RFQ-05–07 | Partial / Backend | Comparable synthetic offers use common scope and currency, itemized freight and handling, and explicit exclusions. Actual offers, dated conversions, validity, comparison and idempotent delivery remain open. |
| CALC-01–04 | Partial / External | Trade and vehicle monetary calculations use exact decimals. Verified live freight/tariff/FX records and issuer evidence are still required. |
| CALC-05–06 | Partial | Exact package CBM and freight rules, plus container volume, door/orientation and payload checks. Actual combined fit, securing, load distribution and optimization remain open. |
| CALC-07–08 | Partial / External | DG readiness and cold-chain preparation exist. Verified rule sources, commodity profiles, telemetry and operational validation remain open. |
| LEO-01–04 | Partial | Service previews, three feed products, country scope, narrow supplier/buyer tabs and consent-gated RFQ handoff. Verified availability, participants and operating services remain open. |
| LEO-05–07 | Backend / Deferred | Private CRM, mail workflows, follow-ups and Optima Hub remain future integrations. |
| LEO-08 | Preview | Documents described in workflows, official issuance and authorized operations unavailable. |
| MOD-01–02 | Preview | Admin menu with local reports and moderation list. Real Safety Center roles and state transitions open. |
| MOD-03–06 | Backend | Evidence snapshots and chain of custody, enforcement, revocation and emergency procedures open. Restriction display is informational. |
| MOD-07–10 | Preview / Backend | Appeal and audit screens preview fields. Notices, independent review, retention, threat processing and evidence export open. |
| SEC-01–08 (security §16) | Backend | Guest and account-required previews. Identity, MFA, authorization, secure transport, uploads, secrets, privacy demands and opt-in tracking require implementation and tests. |
| MON-01–03 | Partial / Deferred | Guest browsing exists. Subscription and quota policies, real notifications and monetization deferred. |
| PAY-01–06 | Deferred | Provider, orders, checkout states, webhook validation, renewals and refunds deferred. |
| ADS-01–07 | Deferred | Sponsorship, targeting and budgets, labeling, metrics and server enforcement deferred. |
| ARCH-01–04 | Partial / Backend | Existing Flutter feature/Cubit architecture and interfaces preserved. Deployment architecture and service boundaries open. |
| ARCH-05–11 | Backend | Relational/private file storage, scoped access, API versioning, queues, cache, tuning and production flags open. |
| SMART-01–03 | Deferred / External | Multimodal translation/OCR, licensed weather/financial feeds, meetings and opt-in location open. |
| AI-01–06 | Backend / Deferred | No AI service, data access, retrieval, evaluation, automation or metering implemented. |
| OPS-01–08 | Backend | Build/analyze/tests run locally. Hosted environments, observability, backups and restoration, CI, budgets and performance validation open. |
| §8 Localization and glossary | Partial | EN/AR, Arabic RTL, tested in-form RFQ switching and a local glossary. Full language QA and reviewed fr, it, hi and zh-Hans translations remain open. |
| §14 Product notices and policies | Preview | Local feature notices displayed. Owner/legal review, final policies and enforcement open. |
| §20–21 Data model, APIs and events | Backend | Typed local records and source contracts exist. Production relational schema, authorization, API versioning and event delivery open. |
| §24–31 Release, metrics and handoff | Partial / Backend | Implementation and evidence documented here. Staged release gates, approved source/legal licenses, production telemetry, deployment and owner acceptance remain open. |

## V4 acceptance scenarios

| Scenario | Status | Verification |
| --- | --- | --- |
| AC-01 | Tested | Home width and guest access in existing widget tests. |
| AC-02 | Tested | Category and sector coverage plus dedicated filter test. |
| AC-03 | Partial / External | Fictional strawberry product searchable; dated trade market evidence remains open. |
| AC-04 | Tested (RFQ) / Partial | Widget test changes language and direction mid-RFQ while preserving entered cargo and package quantities. App-wide active-form coverage remains open. |
| AC-05–08 | Backend | Import duplicates, OCR review, server ID authorization and RFQ retry/idempotency unimplemented. |
| AC-09 | Tested | Trade engine fixture tests 0.156 CBM, 45 kg actual and 26 kg volumetric. |
| AC-10 | Partial | Calculator invalid-input and incomplete-total tests. Server-side validation and real coverage open. |
| AC-11 | Tested | Vehicle and trade tests block complete estimates on missing, expired or unverified inputs/rules. |
| AC-12 | Tested | DG missing or unverified evidence yields review or unavailable without approval. |
| AC-13–16 | Backend | Server blocking, protected evidence, appeal review and private file access open. |
| AC-17–20 | Deferred / Backend | Server payment verification, idempotency, budget enforcement and notification quotas deferred. |
| AC-21–22 | Backend | Private AI retrieval isolation and backup restore tests not implemented. |
| AC-23 | Partial | Leopard test confirms consent and only product name copied into a local draft. Live sharing not implemented. |
| AC-24 | Tested (preview) | No live payment, tracking or ad success actions. Account, DG and quotation tests exercise honest states. |

Proof files and test boundaries are listed in the [acceptance report](UI_UX_ACCEPTANCE_REPORT.md). The [backend planning document](BACKEND_REQUIREMENTS.md) records production dependencies.
