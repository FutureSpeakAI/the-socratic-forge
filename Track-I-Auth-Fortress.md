# Track I: The Auth Fortress — Authentication & Authorization

**Assigned Team / Agent:** Security-focused agent
**Phases:** 2 phases
**Can begin:** Immediately
**Dependencies from other tracks:** None

---

## Vision

Every SaaS application lives or dies by its auth layer. A data analytics platform is especially sensitive — customers are trusting us with their behavioral data, and a single authorization bypass could expose one customer's data to another.

The Auth Fortress takes the existing NextAuth skeleton and transforms it into a hardened, multi-tenant authentication and authorization system. When this track is complete, every request is authenticated, every resource is authorized, every organization's data is isolated, and the system can prove it.

---

## Current State

| File | Lines | What It Does | Relevant To |
|------|-------|-------------|-------------|
| `src/app/api/auth/[...nextauth]/route.ts` | ~80 | NextAuth config with GitHub + Google OAuth | Phase 1 |
| `src/lib/auth.ts` | ~30 | Basic `requireAuth` helper | Phase 1, 2 |
| `middleware.ts` | ~20 | Redirects unauthenticated users | Phase 1 |
| `prisma/schema.prisma` | ~60 | User/Account/Session tables | Phase 2 |

### What Does NOT Exist

- Session hardening (token rotation, fingerprinting, expiry policies)
- Role-based access control
- Organization/workspace model
- Tenant isolation at the data layer
- API key authentication for machine-to-machine (event ingestion)

---

## Phase Sequence

| Phase | Name | Scope | Depends On | Delivers |
|-------|------|-------|-----------|----------|
| 1 | Auth Core | ~400-600 LOC | Nothing | Hardened sessions, API key auth, rate limiting |
| 2 | RBAC | ~600-900 LOC | Phase 1 | Roles, permissions, org boundaries, tenant isolation |

---

## Cross-Track Dependencies

- **Provides to Track II:** RBAC middleware and tenant isolation. Track II Phase 2 (processing pipeline) needs to know which organization owns each event to enforce data boundaries.

---

## Key Design Questions

1. How do you handle the transition from "every user sees everything" to "users only see their organization's data" without breaking the existing prototype?
2. API keys for event ingestion are fundamentally different from user sessions — they're long-lived, machine-to-machine, and scoped to an organization. Should they share auth infrastructure with user sessions, or is that a false economy?
3. What's the right granularity for permissions? Too coarse (admin/viewer) and you can't grow. Too fine (per-resource ACLs) and the system becomes unmanageable.

---

**Track milestone:** When complete, every request is authenticated, every resource is authorized by role, every organization's data is isolated, and the system has an API key mechanism for machine-to-machine event ingestion.
