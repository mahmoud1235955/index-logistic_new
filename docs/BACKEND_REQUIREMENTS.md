# Backend requirements for future planning

This document records dependencies from the [official V4 specification](<../Index_Logistics_Master_Execution_Spec_V4_AR_Print(1).pdf>) and the [traceability matrix](V4_TRACEABILITY_MATRIX.md). It describes proposed work for owner review. Sprint 10 uses in-memory Cubit state and local fixtures.

## Launch dependencies

| Area | Service boundary and acceptance condition |
| --- | --- |
| Identity and authorization | Preserve anonymous reads of public catalog and search. Require an authenticated, authorized member for publishing, contact and messages. Use scoped company membership, least-privilege staff roles and revocation that takes effect on existing sessions. Verify cross-tenant denial for every private resource, export and attachment. |
| Company and product directory | Canonical company, branch, role, country, sector and product identities. Store normalized aliases and revisioned HS references where licensed. Distinguish company activity from dated evidence of trade with a particular origin. Support claim, review, dispute and evidence linkage. |
| Datasets and import | Typed imports with original file provenance, preview/conversion/validation, row errors, reversible batches, conflict resolution and idempotency. OCR results require review. Document permission, licence, retention and re-publication scope before ingest. |
| Commercial community | Persist typed requests, offers and professional contributions with audience, expiry and revision history. Enforce spam/reporting rules. Sever future communication on block while retaining authorized case evidence. Establish recipient consent and explicit channel preferences. |
| Freight requests and offers | Versioned RFQ and quote models with structured packages/units, route, equipment and special handling. Confirm the intended recipients and fields shared. Preserve draft state and retries. Deduplicate submissions and events. Compare equivalent scopes, quote versions, currencies, taxes and expiry. Delivery and status must reconcile with provider receipts. |
| Employment and services | Employer and applicant roles, listing validity, applications and access isolation. Coordinate consent, retention and contact restrictions for employment records. Consultation availability and provider identity require verified data. |
| Account, messages and notifications | Authorized conversation membership, contact requests, server-enforced blocks, safe attachments and independent send/delivery states. Store profiles, preferences, saved item IDs and drafts with appropriate retention. Delivery and quota accounting require deduplication and separate safety notifications. |
| Moderation | Protected report queues, evidence snapshots, chain of custody, role-separated appeals and audit entries. Restrictions require an authorized decision, evidence reference, scope, duration and applicable sessions to revoke. Keep private evidence out of public responses and signed URLs short-lived. |
| Leopard and feeds | Verify owner-controlled identity, contact, authorization, cargo services and available geography. Obtain user consent before transferring the minimum RFQ context; private CRM data belongs in a separate authorized scope. Feed trade verification and any consolidation, charter or shipment operations need independent evidence and workflows. |
| Hosting and operations | Define environment isolation, CI, schema migrations, secret management, backups, restore exercises, data erasure, incidents and observable delivery/error states. Owner sign-off required for jurisdiction, retention and support model. |

## Official or licensed data

- Vehicles and landed cost need current jurisdiction rules, tariff valuation, tax bases, HS, exemptions, route and vehicle eligibility, currency provenance, editions and effective dates. Any missing mandatory input must keep estimates incomplete.
- Freight needs licensed or owner-authorized schedules, operator/route eligibility, rate scope and surcharges, quote validity, tracking events and storage restrictions.
- Dangerous goods need appropriately licensed ICAO, IATA, IMDG and ADR records plus national, route and operator scope. Data adapters must preserve citations, editions, amendments and applicable dates. Product names must not produce definitive classifications in isolation. Human review and carrier acceptance remain separate.
- Market, support organizations, facilities, approvals, events, currency, climate/CBAM and cold-chain records require rights to display, provenance, review and effective dates. Data-source ownership and correction responsibility must be agreed.
- Owner-approved terms, notices and legal/regulatory review precede operational launch. Regulatory tables, official declarations and certification require the appropriate licences and authority.

## Deferred work

Payment, subscriptions, ads, production AI and automation remain separate owner-approved work packages. Plan server-side verification, idempotency, callbacks, budgets and auditable state before offering those capabilities. Private message/CRM retrieval, recommendation ranking and opt-in location must undergo dedicated privacy review.

## Proposed implementation order

1. Agree public/private record boundaries, identity and authorization, source permissions and retention.
2. Implement canonical directory and verified source ingestion with reproducible review.
3. Add authenticated commercial workflows and RFQ/offer delivery with idempotent status.
4. Add role-separated moderation, user preferences and observability.
5. Exercise V4 acceptance cases in staging, including native accessibility, security, retry and backup restoration, before owner acceptance.

## Sprint 11 production dependencies

The local package template saves only package types, quantities, units and measurements. Production shipment drafts still require ownership, retention and deletion rules, authenticated access and delivery controls. The meeting tool uses a bundled timezone database. Release maintenance needs a named owner and a process for updating that database and checking revised daylight-saving rules.

Transport and product emissions preparation accepts user-supplied factors with source and effective-date metadata. Official factor datasets, jurisdiction and methodology review, CBAM declarations and charge determination remain production dependencies. Container and special-cargo journeys provide preliminary preparation. Actual stowage, route and equipment acceptance, securing, cold-chain operating requirements and regulatory determinations require qualified review and verified, shipment-specific evidence.
