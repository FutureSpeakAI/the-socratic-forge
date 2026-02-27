# Example: Beacon Analytics — A Worked Socratic Forge

This directory contains a complete (but fictional) example of the Socratic Forge applied to a real-world project type: a multi-tenant SaaS analytics dashboard.

**This is not a real project.** It's a teaching tool that shows you what a populated Forge looks like at a realistic scale. Study the patterns, then adapt them to your own project.

---

## The Project

**Beacon Analytics** is a B2B SaaS dashboard that ingests event data from customer applications, processes it into metrics and visualizations, and serves it through a real-time dashboard with role-based access.

**Tech stack:** TypeScript, Next.js 15, PostgreSQL, Redis, Prisma ORM, deployed on Vercel + Supabase.

**Current state:** Early prototype. Authentication works (NextAuth). Basic event ingestion endpoint exists. No processing pipeline, no dashboard, no multi-tenancy, no RBAC.

---

## Forge Structure

```
examples/
├── 01-GAP-MAP.md              ← Codebase inventory
├── ORCHESTRATOR.md             ← Command center with launch prompts
├── Track-I-Auth-Fortress.md    ← Track overview: auth & authorization
├── Track-II-Data-Engine.md     ← Track overview: ingestion & processing
├── track-1/
│   ├── phase-1-auth-core.md    ← Complete phase: session hardening
│   └── phase-2-rbac.md         ← Complete phase: role-based access
└── track-2/
    └── phase-1-schema-design.md ← Complete phase: event data model
```

**Two tracks, five phases.** This is a "side project" scale Forge — enough to show the full pattern without overwhelming detail.

---

## What to Study

1. **The Gap Map** — Notice how it inventories specific files with line counts and honest quality assessments. This grounds every agent session.

2. **The Phase Files** — Notice how the questions never contain their own answers. "What must be true about a session token before the system trusts it?" not "Implement JWT validation with RS256."

3. **The Orchestrator** — Notice the launch prompts load exactly three files. Notice the dependency diagram shows Track 1 must finish before Track 2 Phase 2 can start (RBAC affects data access), but Track 2 Phase 1 can run in parallel with Track 1.

4. **The Safety Gates** — Each phase ends with a domain-appropriate safety check. Auth phases check OWASP. Data phases check for data leakage and injection.
