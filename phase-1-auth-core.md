# Track I, Phase 1: Auth Core — Session Hardening

**Track:** The Auth Fortress — Authentication & Authorization
**Depends on:** Nothing — first link in critical path
**Blocks:** Track I Phase 2 (RBAC)
**Estimated scope:** 3-4 files modified/created, ~400-600 LOC

---

## Current State

**`src/app/api/auth/[...nextauth]/route.ts` (~80 lines)** configures NextAuth with GitHub and Google OAuth providers, Prisma adapter, JWT session strategy. Default token contents (sub, email, name). No custom session callbacks, no token rotation, no expiry configuration beyond defaults.

**`src/lib/auth.ts` (~30 lines)** exports `requireAuth()` which calls `getServerSession()` and throws if null. No role checking, no rate limiting, no session fingerprinting.

**`middleware.ts` (~20 lines)** uses NextAuth's default middleware to redirect unauthenticated users to `/login`. No path-based rules, no API route protection.

**What does NOT exist:** Token rotation, session fingerprinting, rate limiting, API key authentication, structured auth error handling.

---

## Architecture Context

Current auth flow:
```
User → OAuth Provider → NextAuth callback → JWT issued → stored in httpOnly cookie
                                                          ↓
Subsequent requests → middleware checks cookie → requireAuth() verifies session → proceed
```

After this phase:
```
User → OAuth Provider → NextAuth callback → JWT issued (hardened) → stored in httpOnly cookie
                                                                     ↓
Subsequent requests → middleware (path-aware) → requireAuth() (fingerprinted, rate-limited) → proceed
                                                                     ↓
Machine clients → API key in header → validateApiKey() → proceed (scoped to organization)
```

---

## Socratic Inquiry

### Foundational: What Makes a Session Trustworthy?

A user authenticates via Google OAuth. NextAuth issues a JWT. For the next 30 days (the default), every request carrying that token is treated as the authenticated user.

**What must be true about a session token before the system should trust it?** "It was issued by us" is the obvious answer — but what else? Consider: the token could have been issued legitimately and then stolen. The token could have been issued to a device the user no longer controls. The token could be valid but the user's permissions may have changed since issuance.

**Follow-up:** If you add checks beyond "was this token signed by us," each check has a cost (latency, database lookups, complexity). How do you decide which checks are worth their cost? What's the threat model for a B2B analytics dashboard — who is the likely attacker, and what are they after?

### API Keys vs. Sessions

The event ingestion endpoint (`/api/events`) currently has no authentication at all. It needs auth, but it serves machine clients (customer backend servers), not humans in browsers.

**What are the fundamental differences between authenticating a human user and authenticating a machine client?** Consider: session duration, credential storage, rotation expectations, the meaning of "consent," what happens on compromise.

**Design question:** Should API keys share infrastructure with user sessions (same table, same middleware, same validation path), or should they be a completely separate system? What are the maintenance costs of each approach? What are the security implications?

**Follow-up:** An API key is essentially a password that never expires. What makes that acceptable for machines but not for humans? Or is it not acceptable — should API keys expire too? If so, what's the rotation story?

### Rate Limiting

The current system has no rate limiting on any endpoint.

**What happens if you add rate limiting?** That's the easy question. The harder question: **what happens to legitimate users who hit the limit?** A customer's backend server sends 10,000 events in a burst because it was offline for an hour and is catching up. Your rate limiter blocks it. The customer's data is now incomplete. What's worse — the DDoS you prevented or the data you dropped?

**Where should rate limits live architecturally?** In the middleware? In each route handler? In a shared service? Each placement has different properties. What are they?

### Error Handling

Authentication failures currently throw generic errors that Next.js renders as 500s or default error pages.

**What information should an auth error reveal, and what should it hide?** "Invalid credentials" is standard. But what about: "This account has been disabled"? "This IP has been blocked"? "This API key has been revoked"? Each reveals something about the system's state. When is that helpful, and when is it a vulnerability?

### Synthesis

You now have four concerns: session hardening, API key auth, rate limiting, and auth error handling.

**How do these compose into a single coherent auth middleware?** What's the request lifecycle — what gets checked first, second, third? Where do you short-circuit? How do you ensure adding one concern doesn't break another?

---

## Boundary Constraints

- This phase ONLY hardens authentication and adds API key auth. No roles, no permissions, no organization model — those are Phase 2.
- Do not replace NextAuth. Extend its configuration and add middleware around it.
- Do not modify the events endpoint's business logic. Only add authentication to it.
- The output is a hardened auth layer that Phase 2 can extend with RBAC.

---

## Validation Criteria

- [ ] A stolen JWT from a different device/IP is rejected (session fingerprinting)
- [ ] Tokens rotate on a configurable interval (not just at the 30-day default expiry)
- [ ] The `/api/events` endpoint accepts requests with a valid API key and rejects requests without one
- [ ] A burst of 100 requests in 1 second from the same IP triggers rate limiting with a clear error message
- [ ] Auth error responses never reveal whether an email/account exists in the system
- [ ] All auth changes are backward-compatible with the existing prototype's login flow

---

## Safety Gate

**Security:** Walk through OWASP Top 10 for this phase's scope:
- **A01 Broken Access Control:** Does rate limiting apply equally to all routes? Can it be bypassed by changing headers?
- **A02 Cryptographic Failures:** Are JWTs signed with a strong algorithm? Is the signing key stored securely? Are API keys hashed before storage?
- **A07 Identity and Authentication Failures:** Can session fixation occur? Is there protection against credential stuffing on the OAuth callback?
- **A09 Security Logging:** Are failed auth attempts logged with enough detail to detect attacks but not enough to leak credentials?

Trace every new code path: does any path allow an unauthenticated request to reach a protected resource?

---

**On completion:** Hand the hardened auth middleware and API key system to Phase 2 (RBAC).
