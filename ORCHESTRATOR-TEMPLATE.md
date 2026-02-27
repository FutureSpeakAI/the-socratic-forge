# Socratic Forge Orchestrator — [Your Project Name]

## How This Works

This file is your command center. Each phase below has:
- A **status checkbox** you update as work completes
- A **launch prompt** you copy-paste into your AI coding agent to start that phase
- **Dependency gates** that tell you what must be done first

### Daily Workflow

1. Check the dependency gates below to find what's ready to start
2. Copy the launch prompt for that phase
3. Paste it into Claude Code / Antigravity / Replit as your opening message
4. The agent reads the files, reasons through the Socratic questions, and implements
5. Verify the Validation Criteria listed in the phase file
6. Check the box below and move to the next phase

### Parallel Work

Multiple sessions can run in parallel on non-blocking tracks. The dependency diagram below shows what can run simultaneously.

---

## Dependency Diagram

<!-- Map out which tracks/phases can run in parallel.
     Arrows show "must complete before." -->

```
Track 1 Phase 1 → T1.P2 → T1.P3
                              ↘
Track 2 Phase 1 → T2.P2 ------→ [Integration]
                              ↗
Track 3 Phase 1 → T3.P2 → T3.P3
```

---

## Sprint 1: [Name — e.g., "Foundation"] (Weeks [N-N])

### Track [1], Phase 1: [Phase Name]
**Status:** [ ] Not Started  |  [ ] In Progress  |  [x] Complete
**Depends on:** Nothing — start here
**Launch prompt:**
```
Read these three files in order, then begin implementation:
1. socratic-roadmaps/00-SOCRATIC-METHODOLOGY.md
2. socratic-roadmaps/01-GAP-MAP.md
3. socratic-roadmaps/track-1/phase-1-[name].md

[One sentence: starting condition and ending condition.]
Start by [what to assess first]. End by verifying the Safety Gate.
```

---

### Track [1], Phase 2: [Phase Name]
**Status:** [ ] Not Started  |  [ ] In Progress  |  [ ] Complete
**Depends on:** Track 1, Phase 1
**Launch prompt:**
```
Read these three files in order, then begin implementation:
1. socratic-roadmaps/00-SOCRATIC-METHODOLOGY.md
2. socratic-roadmaps/01-GAP-MAP.md
3. socratic-roadmaps/track-1/phase-2-[name].md

[One sentence: starting condition and ending condition.]
```

---

<!-- Continue for all phases across all tracks.
     Group by sprint for time-based planning. -->

## Sprint 2: [Name] (Weeks [N-N])

### Track [2], Phase 1: [Phase Name]
**Status:** [ ] Not Started  |  [ ] In Progress  |  [ ] Complete
**Depends on:** [Dependency]
**Launch prompt:**
```
Read these three files in order, then begin implementation:
1. socratic-roadmaps/00-SOCRATIC-METHODOLOGY.md
2. socratic-roadmaps/01-GAP-MAP.md
3. socratic-roadmaps/track-2/phase-1-[name].md

[One sentence: starting condition and ending condition.]
```

---

## Post-Completion

- [ ] Update Gap Map with all new files and patterns
- [ ] Run integration tests across track boundaries
- [ ] Final safety review across all tracks
- [ ] Update this orchestrator with any new phases identified during the build
