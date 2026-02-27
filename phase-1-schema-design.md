# Track II, Phase 1: Schema Design — Event Data Model

**Track:** The Data Engine — Ingestion, Processing & Visualization
**Depends on:** Nothing (can run parallel with Track I Phase 1)
**Blocks:** Track II Phase 2 (processing pipeline)
**Estimated scope:** 2-3 files modified/created, ~400-600 LOC

---

## Current State

**`prisma/schema.prisma` (~60 lines)** defines a basic Event table:
```prisma
model Event {
  id        String   @id @default(uuid())
  payload   Json
  createdAt DateTime @default(now())
}
```
No foreign keys, no organization association, no event type field, no indexing strategy.

**`src/app/api/events/route.ts` (~45 lines)** accepts any JSON body and writes it to the Event table. No validation, no schema enforcement, no acknowledgment of what fields are expected.

**What does NOT exist:** Event schema definition, validation layer, organization association, event type taxonomy, indexing for query patterns, retention policy.

---

## Architecture Context

Current event flow:
```
Customer server → POST /api/events { anything } → INSERT into events (payload: JSON blob) → 200 OK
```

After this phase:
```
Customer server → POST /api/events { validated payload }
                                         ↓
                              Validate against event schema
                                         ↓
                              Associate with organization (via API key)
                                         ↓
                              INSERT into events (typed, indexed, tenant-scoped)
                                         ↓
                              200 OK with ingestion receipt
```

---

## Socratic Inquiry

### Foundational: What Is an "Event"?

The current system stores events as opaque JSON blobs. This is maximally flexible and maximally useless for analytics.

**What structure does an analytics event need?** Every analytics platform answers this differently. Some enforce a rigid schema (event name + properties map). Others allow anything. What are the consequences of each choice for the processing pipeline that will consume these events?

**Follow-up:** Your customers are developers integrating a tracking SDK into their applications. The schema you choose determines their integration experience. A strict schema catches errors early but slows adoption. A loose schema is easy to integrate but produces garbage data. Where's the principled line?

### The Schema Tradeoff

Consider two events from the same customer:
- `{ type: "page_view", url: "/pricing", referrer: "google.com", duration_ms: 4500 }`
- `{ type: "purchase", product_id: "abc123", amount: 49.99, currency: "USD" }`

**These events have completely different properties. How do you store them in PostgreSQL?**

Options exist on a spectrum: one table with a JSON column (current approach), one table per event type (rigid), a shared columns + JSON overflow approach (hybrid), or something else entirely. For each approach, what are the query patterns it makes easy and the query patterns it makes expensive?

**Constraint question:** You're on Supabase free tier with 500MB. At 2KB per event and 1,000 events/day per customer, how many customers can you serve before you hit the limit? How does your schema choice affect storage efficiency? Does this constraint change your design?

### Multi-Tenancy at the Data Layer

Events belong to organizations. Track I Phase 2 will add the organization model, but you're designing the schema now.

**How do you design the event table to support multi-tenant isolation without coupling to an organization model that doesn't exist yet?** You need a foreign key strategy that works today and connects cleanly when RBAC arrives.

**Follow-up:** Should you use PostgreSQL Row Level Security (RLS) for tenant isolation, or application-level filtering? RLS is enforced at the database layer (can't forget it) but adds complexity to migrations and testing. Application filtering is simpler but relies on every query being written correctly. What does Supabase recommend, and does that recommendation change your decision?

### Indexing Strategy

The processing pipeline (Phase 2) will need to query events by organization, by time range, and by event type. The dashboard (Phase 3) will need aggregations (count, sum, average) grouped by time bucket and event type.

**What indexes do you need, and what's the cost of each?** Every index speeds up reads and slows down writes. At ingestion scale (hundreds of events per second per customer), when do indexes become the bottleneck? What's the strategy for an index set that serves both ingestion performance and query performance?

**Follow-up:** PostgreSQL partial indexes let you index only rows matching a condition. Composite indexes cover multiple columns. Expression indexes can index computed values. Which of these apply to the event access patterns you've identified?

### Validation Layer

Events arrive from the internet. They need validation before storage.

**What layers of validation does an event need?** Consider: structural (is it valid JSON?), schema (does it have required fields?), semantic (is the timestamp in the future? is the amount negative?), and authorization (does this API key belong to an organization?). Where does each validation happen — in the route handler, in a middleware, in a Prisma middleware, or in a database constraint?

### Synthesis

You now have an event schema, multi-tenant association, indexing strategy, and validation layer.

**Write the Prisma schema migration that implements all of this.** What indexes did you include? What constraints? How does the schema handle event types that haven't been invented yet? How would you add a new event property six months from now without migrating existing data?

---

## Boundary Constraints

- This phase designs and implements the data model. It does NOT build the processing pipeline (Phase 2) or the dashboard (Phase 3).
- Modify `prisma/schema.prisma` and create a migration. Update the events route handler to validate against the new schema.
- Do not build the organization model — that's Track I Phase 2. Use a `String` placeholder for `organizationId` that will become a foreign key when the Organization model arrives.
- The validation layer should reject invalid events. It should NOT transform or enrich events — that's the processing pipeline's job.

---

## Validation Criteria

- [ ] An event with all required fields is accepted and stored with correct types
- [ ] An event missing a required field is rejected with a 400 and a specific error message naming the missing field
- [ ] An event with a future timestamp (>5 minutes ahead) is rejected
- [ ] Events are queryable by organization ID, time range, and event type using indexed queries
- [ ] An EXPLAIN ANALYZE on the most common query pattern (events by org + time range) shows index usage, not sequential scan
- [ ] The Prisma migration is reversible

---

## Safety Gate

**Data integrity:** Can any code path write an event without the required fields? Trace from the API route through validation to Prisma. Is there a way to bypass validation?

**Performance:** At 100 concurrent event ingestion requests, does the database maintain sub-100ms write latency? Do the new indexes cause measurable write slowdown compared to the current schema?

**Storage:** Calculate the per-event storage cost with the new schema (row data + indexes). At what customer/event scale does this exceed the 500MB Supabase limit? Document this number for Phase 2's retention policy design.

---

**On completion:** Hand the validated event schema and ingestion endpoint to Track II Phase 2 (processing pipeline).
