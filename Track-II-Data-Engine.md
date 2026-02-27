# Track II: The Data Engine — Ingestion, Processing & Visualization

**Assigned Team / Agent:** Data-focused agent
**Phases:** 3 phases (only Phase 1 included in this example)
**Can begin:** Phase 1 immediately; Phases 2-3 after Track I Phase 2
**Dependencies from other tracks:** Track I Phase 2 (RBAC for tenant data isolation)

---

## Vision

Analytics is a pipeline problem. Raw events arrive at one end; actionable insights emerge at the other. The Data Engine builds that pipeline: a validated ingestion layer, an efficient processing system that turns raw events into aggregated metrics, and a real-time dashboard that makes those metrics useful.

The key challenge is doing this within Vercel's serverless constraints (10-60 second timeouts) and Supabase's free tier limits (500MB). This isn't a "throw hardware at it" problem — it's a design problem.

---

## Current State

| File | Lines | What It Does | Relevant To |
|------|-------|-------------|-------------|
| `src/app/api/events/route.ts` | ~45 | Accepts JSON event payloads, writes to `events` table | Phase 1 |
| `prisma/schema.prisma` | ~60 | Basic Event table (raw JSON blob) | Phase 1 |
| `src/app/dashboard/page.tsx` | ~60 | Hardcoded sample data dashboard | Phase 3 |

### What Does NOT Exist

- Event validation or schema enforcement
- Multi-tenant event isolation
- Aggregation or processing pipeline
- Time-series storage or pre-computed metrics
- Real-time or near-real-time dashboard
- Event retention policies or archival

---

## Phase Sequence

| Phase | Name | Scope | Depends On | Delivers |
|-------|------|-------|-----------|----------|
| 1 | Schema Design | ~400-600 LOC | Nothing | Event data model, multi-tenant schema, Prisma migrations |
| 2 | Processing Pipeline | ~800-1200 LOC | Phase 1 + Track I Phase 2 | Aggregation jobs, metric tables, batch processing |
| 3 | Real-time Dashboard | ~600-1000 LOC | Phase 2 | Dashboard components, chart rendering, live updates |

---

## Cross-Track Dependencies

- **Consumes from Track I:** RBAC middleware (Phase 2+) and API key authentication (Phase 1 event ingestion).
- **Provides to future tracks:** Metric data that could feed alerting, reporting, or export features.

---

## Key Design Questions

1. Serverless functions have short lifespans. How do you process thousands of events per hour without a persistent background worker? What patterns exist for "serverless batch processing"?
2. Pre-computed aggregations are fast to query but expensive to maintain. Raw queries are flexible but slow at scale. Where's the right balance for a product that might have 10 customers with 1,000 events/day each?
3. The Supabase free tier gives you 500MB. A single event payload might be 2KB. At what customer scale do you hit the limit, and what's your strategy before you get there?

---

**Track milestone:** When complete, events flow from customer applications through validated ingestion into processed metrics displayed on a real-time dashboard, with full multi-tenant isolation.
