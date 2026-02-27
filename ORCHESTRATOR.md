# Socratic Forge Orchestrator — Beacon Analytics

## Dependency Diagram

```
Track I (Auth Fortress)          Track II (Data Engine)
  Phase 1: Auth Core ──┐         Phase 1: Schema Design (can start immediately)
                        │              │
  Phase 2: RBAC ────────┼──────────────┤
                        │              ↓
                        └────→  Phase 2: Processing Pipeline (needs RBAC for data isolation)
                                       │
                                       ↓
                                 Phase 3: Real-time Dashboard (needs processing + RBAC)
```

**Parallel from day one:** Track I Phase 1 and Track II Phase 1 can run simultaneously.

---

## Sprint 1: Foundation (Week 1)

### Track I, Phase 1: Auth Core — Session Hardening
**Status:** [ ] Not Started  |  [ ] In Progress  |  [ ] Complete
**Depends on:** Nothing — start here
**Launch prompt:**
```
Read these three files in order, then begin implementation:
1. socratic-roadmaps/00-SOCRATIC-METHODOLOGY.md
2. socratic-roadmaps/01-GAP-MAP.md
3. socratic-roadmaps/track-1/phase-1-auth-core.md

Assess the current NextAuth configuration and session handling,
then work through the Socratic questions to harden authentication.
End by verifying the Safety Gate against OWASP Top 10.
```

---

### Track II, Phase 1: Schema Design — Event Data Model
**Status:** [ ] Not Started  |  [ ] In Progress  |  [ ] Complete
**Depends on:** Nothing (can run parallel with Track I Phase 1)
**Launch prompt:**
```
Read these three files in order, then begin implementation:
1. socratic-roadmaps/00-SOCRATIC-METHODOLOGY.md
2. socratic-roadmaps/01-GAP-MAP.md
3. socratic-roadmaps/track-2/phase-1-schema-design.md

Assess the current Prisma schema and events table, then work through
the Socratic questions to design the event data model and multi-tenant schema.
End by verifying the Safety Gate.
```

---

## Sprint 2: Access Control + Processing (Weeks 2-3)

### Track I, Phase 2: RBAC — Role-Based Access Control
**Status:** [ ] Not Started  |  [ ] In Progress  |  [ ] Complete
**Depends on:** Track I Phase 1
**Launch prompt:**
```
Read these three files in order, then begin implementation:
1. socratic-roadmaps/00-SOCRATIC-METHODOLOGY.md
2. socratic-roadmaps/01-GAP-MAP.md
3. socratic-roadmaps/track-1/phase-2-rbac.md

Build on the hardened auth from Phase 1. Work through the Socratic
questions to implement role-based access control and organization boundaries.
End by verifying the Safety Gate.
```

---

### Track II, Phase 2: Processing Pipeline
**Status:** [ ] Not Started  |  [ ] In Progress  |  [ ] Complete
**Depends on:** Track I Phase 2 (RBAC needed for tenant data isolation) + Track II Phase 1
**Launch prompt:**
```
Read these three files in order, then begin implementation:
1. socratic-roadmaps/00-SOCRATIC-METHODOLOGY.md
2. socratic-roadmaps/01-GAP-MAP.md
3. socratic-roadmaps/track-2/phase-2-processing.md

[Phase file not included in this example — you'd write it following the template]
```

---

## Post-Completion

- [ ] Update Gap Map with all new files and patterns
- [ ] Integration test: authenticated user with 'viewer' role can see dashboard but not admin settings
- [ ] Integration test: events ingested via API key are correctly isolated to the owning organization
- [ ] Performance test: 1000 events ingested in under 10 seconds
- [ ] Final safety review across all tracks
