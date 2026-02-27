# Gap Map — Beacon Analytics

**Last updated:** 2026-02-20
**Updated after:** Initial inventory (pre-Forge)

---

## File Inventory

| File | Lines | What It Does | Status |
|------|-------|-------------|--------|
| `src/app/layout.tsx` | ~40 | Root layout with NextAuth SessionProvider | Solid |
| `src/app/page.tsx` | ~25 | Landing page, redirects to /dashboard if authenticated | Stub |
| `src/app/dashboard/page.tsx` | ~60 | Placeholder dashboard with hardcoded sample data | Prototype |
| `src/app/api/auth/[...nextauth]/route.ts` | ~80 | NextAuth config: GitHub + Google providers, Prisma adapter | Needs work — no session hardening |
| `src/app/api/events/route.ts` | ~45 | POST endpoint accepts JSON event payloads, writes to `events` table | Prototype — no validation, no auth, no rate limiting |
| `src/lib/prisma.ts` | ~15 | Singleton Prisma client | Solid |
| `src/lib/auth.ts` | ~30 | `getServerSession` wrapper, basic `requireAuth` helper | Needs work — no roles |
| `prisma/schema.prisma` | ~60 | User, Account, Session tables (NextAuth default) + basic Event table | Needs major extension |
| `middleware.ts` | ~20 | Redirects unauthenticated users to /login | Solid but minimal |

**Total:** ~375 LOC across 9 files

---

## Architecture Patterns

- **App Router:** Next.js 15 app directory. Server components by default, `"use client"` only when needed.
- **Auth:** NextAuth v5 with Prisma adapter. Session strategy is JWT (not database sessions).
- **Database:** Prisma ORM → Supabase PostgreSQL. Migrations via `prisma migrate dev`.
- **API routes:** Next.js route handlers in `src/app/api/`. All return JSON. No middleware chain — each route handles its own auth check via `requireAuth()`.
- **Styling:** Tailwind CSS + shadcn/ui components.

---

## Integration Points

- **NextAuth session** is the identity layer. Any new auth logic must extend, not replace, the existing NextAuth flow.
- **Prisma schema** is the single source of truth for data models. All database changes go through Prisma migrations.
- **The `events` table** currently stores raw JSON payloads. Any processing pipeline must consume from this table.

---

## Explicit Gaps

- [ ] No role-based access control (every authenticated user sees everything)
- [ ] No multi-tenancy (no concept of "organizations" or "workspaces")
- [ ] No event processing pipeline (raw events stored but never aggregated)
- [ ] No real-time dashboard (current page shows hardcoded data)
- [ ] No rate limiting on any endpoint
- [ ] No input validation on event ingestion
- [ ] No test files of any kind
- [ ] No error monitoring or structured logging
- [ ] No API key system for event ingestion (currently unauthenticated)

---

## Key Constraints

- **Language/Runtime:** TypeScript 5.4 strict mode, Node 22, Next.js 15
- **Database:** Supabase PostgreSQL (connection pooling via Supabase, not PgBouncer)
- **Deployment:** Vercel (serverless functions, 10s timeout on hobby plan, 60s on pro)
- **External APIs:** None yet beyond auth providers (GitHub, Google OAuth)
- **Budget:** Supabase free tier (500MB database), Vercel hobby plan

---

## Notes for AI Agents

- Vercel serverless functions have a 10-second timeout on the hobby plan. Any long-running processing must be async (background jobs, not request-time).
- Supabase free tier limits: 500MB database, 2GB bandwidth/month, 50MB file storage. Design for efficiency.
- The Prisma schema uses `uuid` for all primary keys. Continue this pattern.
- All dates are stored as `DateTime` (UTC) in Prisma. Never use local time.
