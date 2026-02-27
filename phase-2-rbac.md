# Track I, Phase 2: RBAC — Role-Based Access Control

**Track:** The Auth Fortress — Authentication & Authorization
**Depends on:** Track I Phase 1 (hardened auth layer must exist)
**Blocks:** Track II Phase 2 (processing pipeline needs tenant isolation)
**Estimated scope:** 4-6 files created/modified, ~600-900 LOC

---

## Current State

**Phase 1 delivered:** Hardened session management with fingerprinting and rotation. API key authentication for machine clients. Rate limiting middleware. Structured auth error responses.

**`prisma/schema.prisma` (~60 lines)** has User, Account, and Session tables from NextAuth. No Organization model, no Role model, no membership/invitation system.

**What does NOT exist:** Organizations, roles, permissions, tenant isolation at the data layer, invitation flow, ownership transfer.

---

## Architecture Context

After Phase 1:
```
Request → rate limiter → session/API key validation → route handler (sees everything)
```

After this phase:
```
Request → rate limiter → session/API key validation → RBAC middleware → route handler (sees only permitted data)
                                                         ↓
                                              Checks: role + organization membership + resource ownership
```

---

## Socratic Inquiry

### Foundational: What Is an Organization?

The current system has users but no concept of "organization." Every authenticated user sees all data.

**What IS an organization in the context of a B2B analytics product?** It's tempting to say "a company." But consider: a freelancer uses the product for three different clients. An agency manages analytics for 20 brands. A company has a marketing team and an engineering team that should see different dashboards. How do you model this flexibility without making the common case (one company, one workspace) feel over-engineered?

**Follow-up:** A user belongs to an organization. Can they belong to more than one? If yes, what does the session look like — do they "switch" organizations, or see a merged view? Each choice has deep UI and data implications.

### The Permission Model

You need roles. At minimum: owner, admin, member, viewer.

**What can each role do, and — more importantly — what CAN'T each role do?** Defining permissions as "what's allowed" seems natural, but "what's denied" is often more secure. Which approach do you take, and why?

**Design question:** You could store permissions as a flat list per role, as a hierarchical tree, as a bitmask, or as a policy document (like AWS IAM). Each has different properties for querying, extending, and debugging. Given that you're building on PostgreSQL with Prisma, what representation minimizes query complexity while remaining flexible enough to add new permission types later?

**Tension question:** A startup with 3 people wants simple roles. An enterprise with 500 people wants custom roles with granular permissions. How do you build for the startup today while leaving a path to the enterprise tomorrow — without over-engineering?

### Tenant Isolation

Organization A's data must be invisible to Organization B. This sounds simple but has tentacles everywhere.

**Where in the stack do you enforce isolation?** At the database level (row-level security)? At the ORM level (Prisma middleware that injects `WHERE org_id = ?`)? At the application level (every query manually filtered)? Each has different failure modes. Which failure mode is most dangerous for an analytics product?

**Pressure test:** A developer writes a new API route and forgets to add the organization filter. With each isolation strategy you've considered, what happens? In which strategy does the developer's mistake leak data, and in which does the system catch it automatically?

**Follow-up:** API keys are scoped to an organization. User sessions carry a user who belongs to one or more organizations. How does tenant isolation work differently for these two auth paths?

### Invitations

Users need to join organizations. The current system has no invitation flow.

**What are the security risks of an invitation system?** Consider: invitation links that can be forwarded, expired invitations that still work, invitations to email addresses that don't have accounts yet, invitations that grant admin access. For each risk, what's the mitigation?

**Design question:** Should invitations be link-based (anyone with the link joins) or email-bound (only the invited email can use it)? What are the tradeoffs for a B2B product?

### Synthesis

You now have organizations, roles, permissions, tenant isolation, and invitations.

**How do these compose into a coherent authorization layer?** Trace a request from arrival to database query: where does each check happen? What's the performance impact of checking role + organization + permissions on every request? Is there a caching strategy that's safe (doesn't serve stale permissions after a role change)?

---

## Boundary Constraints

- This phase builds RBAC and tenant isolation. It does NOT build the dashboard, the settings UI, or the billing system.
- Do not modify the core NextAuth flow from Phase 1. RBAC wraps around it.
- Organization management (create, update, delete) is part of this phase. Organization billing is NOT.
- Deliver Prisma migrations, middleware, and utility functions. The UI for role management is out of scope.

---

## Validation Criteria

- [ ] A user with 'viewer' role can view dashboards but cannot create API keys or invite members
- [ ] A user with 'admin' role can invite members and manage API keys but cannot delete the organization
- [ ] Data queries are automatically scoped to the user's active organization (no manual filtering needed in route handlers)
- [ ] A Prisma query without organization context returns zero results (not all results)
- [ ] An invitation link used by a different email address than the invited one is rejected
- [ ] Expired invitation links (>72 hours) are rejected
- [ ] A user removed from an organization immediately loses access (no stale session grants)

---

## Safety Gate

**Data isolation:** For every database table that contains tenant data, verify that there is NO query path that returns cross-tenant results. Enumerate every route handler and confirm organization scoping is applied.

**Privilege escalation:** Can a 'member' role modify their own role to 'admin'? Can they modify the organization's settings? Can they access the invitation endpoint? Trace every permission boundary.

**Invitation security:** Can an invitation be replayed after use? Can it be used by someone other than the intended recipient? Can an expired invitation be renewed by modifying the URL?

---

**On completion:** Hand the RBAC middleware and tenant isolation layer to Track II Phase 2. The processing pipeline can now safely isolate event data by organization.
