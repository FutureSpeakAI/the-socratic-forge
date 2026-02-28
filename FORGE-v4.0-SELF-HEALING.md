# Socratic Forge v4.0: Self-Healing Autonomous Execution

**The goal:** `./run-sprint.sh all` — walk away — come back to v2.5.0.

---

## Why v3.0 Still Needs You

v3.0 has four gates that verify work between phases. They catch contract drift, parallel incompatibility, test rot, pattern violations, and gap map staleness. But three failure modes still require human judgment:

1. **Bad architecture that passes tests.** A 2,000-line God function that does everything correctly. An agent that reimplements lodash instead of importing it. Tests pass, contracts match, but the code is a maintenance nightmare that the next phase will struggle to extend.

2. **Scope creep.** The phase file asks for a moral reasoning layer. The agent builds a moral reasoning layer, a full ethical debate simulator, a philosophical framework library, and a values visualization dashboard. All working, all tested. But the next phase didn't expect any of that and can't make sense of the contract.

3. **Integration failures contracts don't predict.** Track XI exports `injectValues(prompt: string): string`. Track XII imports it. The contract matches. But XII's headless runtime calls it during startup before the personality system is initialized, and `injectValues` assumes the personality system is loaded. Contract-level compatibility hides a runtime-level incompatibility.

Each of these is a judgment call with identifiable inputs and criteria. So let's stop calling them "human judgment" and start calling them what they are: **decision functions that haven't been specified yet.**

---

## The Architecture of Full Autonomy

v4.0 replaces the human with three new components:

### Component 1: The Review Agent

**What the human did:** Read the code diff after each phase. Check for code quality, pattern adherence, maintainability, and "does this look right?"

**What the agent does:** After every build phase and after Gate 3 (tests pass), a dedicated Claude Code session reads the actual code — not the journal, not the contract, the CODE — and evaluates it.

**The prompt:**

```
You are a senior architect reviewing code produced by an autonomous build agent.

Read the current phase file to understand WHAT was supposed to be built:
[phase file]

Read the session journal to understand what the agent THINKS it built:
[journal]

Now read every file the agent created or modified:
[git diff from this phase's commit]

Evaluate against these criteria:

1. PATTERN ADHERENCE: Does the new code follow the architecture patterns
   documented in the gap map? If it introduces a new pattern, is the new
   pattern justified (simpler, more performant, better abstractions) or
   gratuitous (different for no reason)?

2. COMPLEXITY: Is any single function longer than 80 lines? Is any single
   file longer than 400 lines? Are there functions with more than 4
   parameters? These are code smells, not hard failures — but flag them.

3. REIMPLEMENTATION: Does any new code duplicate functionality that exists
   in the project's dependencies (lodash, crypto, fs utilities) or in
   other modules in the codebase? Check imports — if a utility exists
   and wasn't imported, the agent probably didn't know about it.

4. EXTENSIBILITY: Will the next phase (read: [next phase file]) be able to
   build on this code naturally? Or does this phase's architecture force
   the next phase into awkward contortions?

5. SCOPE MATCH: Compare the validation criteria in the phase file to what
   was actually built. Flag anything built that wasn't in the criteria
   (scope creep) and anything in the criteria that wasn't built (gap).

For each issue found, output:

{
  "issues": [
    {
      "severity": "REFACTOR" | "WARN" | "INFO",
      "file": "path/to/file.ts",
      "line_range": [start, end],
      "category": "pattern|complexity|reimplementation|extensibility|scope",
      "description": "What's wrong",
      "fix": "Specific fix instruction"
    }
  ],
  "verdict": "PASS" | "REFACTOR" | "WARN",
  "summary": "One sentence"
}
```

**On REFACTOR verdict:** The runner launches a REPAIR session (see Component 3) that applies the fixes. Then re-runs the review. Max 2 repair cycles per phase — if it's still REFACTOR after 2 attempts, the chain continues with a logged warning. Infinite repair loops are worse than imperfect code.

**On WARN verdict:** Continue. Inject warnings into next phase context.

**Cost:** ~$3-8 per phase (one LLM call reading a large diff). This is the most expensive gate.

---

### Component 2: The Integration Test Agent

**What the human did:** After parallel chains merge, try to actually wire the modules together. Import X into Y, run it, see if it breaks.

**What the agent does:** After Gate 2 (integration check from journals/contracts), a dedicated session writes and runs actual integration tests.

**The prompt:**

```
You are an integration test engineer. Two or more parallel build chains
just completed. They've been verified at the contract level (Gate 2) but
never actually wired together.

Read the interface contracts from all completed chains:
[contract files]

Read the session journals:
[journal files]

Now write and run integration tests that:

1. Import every module that Chain A exports and Chain B consumes
   (and vice versa).
2. Call every function across the chain boundary with realistic inputs.
3. Verify the return types match what the consuming chain expects.
4. Test the initialization order — does Module A work if Module B
   hasn't been initialized yet? What about the reverse?
5. Test error propagation — if Module A throws, does Module B
   handle it gracefully?

Write the tests to: tests/integration/sprint-[N]-integration.test.ts
Run them. Report results.

If tests fail, classify each failure:
- BLOCKING: The chains are fundamentally incompatible. Describe the conflict.
- FIXABLE: The chains are compatible but need a small adapter. Write the adapter.
- TIMING: The chains work but require a specific initialization order. Document it.

Output:
{
  "test_count": N,
  "pass": N,
  "fail": N,
  "failures": [...],
  "verdict": "PASS" | "FIXABLE" | "BLOCKING",
  "adapters_written": ["path/to/adapter.ts"],
  "init_order": ["module-a", "module-b", "module-c"]
}
```

**On FIXABLE verdict:** The agent already wrote the adapter. Commit it. Continue.

**On BLOCKING verdict:** This is the one case where the chain MUST stop. A fundamental incompatibility between parallel chains means the phase files have a design conflict that requires re-scoping. Log the diagnostic. This should be rare — the phase files are designed for non-overlapping scope.

**Cost:** ~$5-10 per integration point (writes and runs code, not just reads). Only runs at sprint boundaries, not after every phase.

---

### Component 3: The Repair Agent

**What the human did:** Read the diagnostic, fix the issue, re-run the phase.

**What the agent does:** When any gate or review agent returns REFACTOR or FIXABLE, a repair session reads the diagnostic and applies fixes.

**The prompt:**

```
A build phase just completed but failed quality review. Your job is to
fix the specific issues identified without rebuilding the entire phase.

Read the review diagnostic:
[review output JSON]

Read the original phase file (for context on intent):
[phase file]

Read the session journal (for context on design decisions):
[journal]

For each issue with severity REFACTOR or FIXABLE:
1. Read the flagged file and line range.
2. Apply the fix described in the diagnostic.
3. Run the relevant tests to verify the fix doesn't break anything.
4. Run the full test suite (Gate 3 equivalent).

Do NOT re-implement the phase. Do NOT change the architecture.
Apply surgical fixes to the specific issues identified.
If a fix requires changing the interface contract, update the contract too.

When done, append to the session journal:
## Repair Pass [N]
- Issues fixed: [list]
- Issues deferred: [list with reasons]
- Tests: [pass/fail count]
```

**Repair budget:** Max 2 repair passes per phase. Max $10 per repair pass. If the code isn't clean after 2 repairs, it ships with warnings. Perfection is the enemy of progress.

---

## The Complete v4.0 Pipeline

Here's what happens for every single phase, fully automated:

```
┌─────────────────────────────────────────────────────────┐
│ PHASE EXECUTION PIPELINE (per phase)                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. Gate 1: Contract Verification (AST check, $0)       │
│     └── FAIL? → Stop chain, log diagnostic              │
│                                                         │
│  2. BUILD PHASE (Socratic inquiry, $10-30)              │
│     └── Agent reads methodology + gap map + phase file  │
│     └── Writes failing tests → makes them pass          │
│     └── Writes session journal + interface contract     │
│     └── Git commit                                      │
│                                                         │
│  3. Gate 3: Progressive Tests (npm test, $0)            │
│     └── FAIL (safety)? → Stop chain                     │
│     └── WARN? → Inject into context, continue           │
│                                                         │
│  4. REVIEW AGENT ($3-8)                                 │
│     └── Reads code diff, evaluates quality              │
│     └── REFACTOR? → Trigger Repair Agent (max 2x)       │
│     └── WARN? → Inject into context, continue           │
│     └── PASS? → Continue                                │
│                                                         │
│  5. Gate 4: Gap Map Refresh (LLM, $1-2)                 │
│     └── Updates codebase inventory                      │
│     └── Flags pattern violations as WARN                │
│                                                         │
│  6. Git commit (gate outputs + gap map update)          │
│                                                         │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ SPRINT BOUNDARY PIPELINE (after parallel chains merge)  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  7. Gate 2: Integration Check (LLM reads journals, $2)  │
│     └── FAIL? → Trigger Integration Test Agent          │
│     └── WARN? → Trigger Integration Test Agent          │
│     └── PASS? → Trigger Integration Test Agent anyway   │
│                                                         │
│  8. INTEGRATION TEST AGENT ($5-10)                      │
│     └── Writes cross-chain integration tests            │
│     └── Runs them                                       │
│     └── FIXABLE? → Writes adapter, commits, continues   │
│     └── BLOCKING? → Stop chain, log diagnostic          │
│     └── PASS? → Continue                                │
│                                                         │
│  9. Gate 3: Full test suite including new integration   │
│     tests ($0)                                          │
│                                                         │
│  10. Next sprint begins                                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Cost Model for Full Autonomous Run

Per phase:
- Build: $10-30
- Gate 1: $0
- Gate 3: $0
- Review Agent: $3-8
- Repair (if needed, ~30% of phases): $5-10
- Gate 4: $1-2
- **Phase total: $14-50, average ~$25**

Per sprint boundary:
- Gate 2: $2
- Integration Test Agent: $5-10
- **Boundary total: $7-12**

Full run (16 phases + 4 sprint boundaries):
- Phases: 16 × $25 = ~$400
- Boundaries: 4 × $10 = ~$40
- **Total: ~$440, range $300-700**

**Time:** 16 phases at 4-8 hours each, with parallelism reducing wall clock time. Realistic total: **4-6 days of continuous execution.** Not one night. One week.

---

## The Self-Healing Loop

The key insight that makes v4.0 fully autonomous is the repair cycle:

```
BUILD → VERIFY → REVIEW → REPAIR → RE-VERIFY → CONTINUE
                    ↑                    │
                    └────── (max 2x) ────┘
```

Every failure mode has a repair path:

| Failure | Detected By | Repaired By | Repair Limit |
|---------|------------|-------------|--------------|
| Contract drift | Gate 1 | Repair Agent fixes exports or contract | 2 attempts |
| Test regression | Gate 3 | Repair Agent fixes the breaking change | 2 attempts |
| Bad architecture | Review Agent | Repair Agent refactors flagged code | 2 attempts |
| Scope creep | Review Agent (scope check) | Repair Agent removes excess code | 2 attempts |
| Pattern violation | Gate 4 | Next phase agent sees warning, aligns | Self-correcting |
| Cross-chain conflict | Gate 2 + Integration Agent | Integration Agent writes adapter | 1 attempt |
| Parallel incompatibility | Integration Test Agent | Integration Agent writes adapter + init order | 1 attempt |
| Gap map stale | Gate 4 | Auto-refreshed every phase | Self-correcting |

**The one remaining STOP condition:** Integration Test Agent finds a BLOCKING incompatibility. This means two phase files have fundamentally contradictory designs. This CAN'T be repaired by an agent — it requires re-scoping the phase files themselves. In 16 phases across 4 tracks designed with explicit boundary constraints, this should happen approximately never. But if it does, the chain stops with a full diagnostic.

---

## What About Plan Quality?

Everything above assumes the phase files are well-scoped. But what if a phase file has:
- Incomplete validation criteria (the agent builds to spec but the spec is wrong)?
- Ambiguous Socratic questions (the agent makes a reasonable but wrong interpretation)?
- Missing boundary constraints (the agent accidentally modifies a module another track owns)?

**Solution: Plan Verification Agent.** Before every build phase, a lightweight check:

```
Read this phase file: [phase file]
Read the gap map: [gap map]
Read the prior phase's journal: [journal]

Check:
1. Does every validation criterion have a clear success/failure condition?
   Flag any criterion that says "should work" or "handles correctly"
   without specifying what "work" or "correctly" means.

2. Do the boundary constraints cover every file and module mentioned
   in the gap map that this phase should NOT modify?

3. Does the phase file reference any modules or patterns that don't
   exist in the gap map? (This would mean the phase was written
   against a stale understanding of the codebase.)

4. Does the phase file's "Depends on" section match reality?
   Check that all listed dependencies have completed journals.

Output:
{
  "plan_quality": "GOOD" | "FIXABLE" | "NEEDS_HUMAN",
  "issues": [...],
  "suggested_amendments": [...]
}
```

**On FIXABLE:** Amend the phase file with the suggested improvements before building. This is meta — the system improves its own plans.

**On NEEDS_HUMAN:** This is the only remaining human touchpoint. It fires when the plan has a structural problem that automated amendment can't fix (e.g., the phase tries to do something that contradicts the track overview's design philosophy). In practice, this should never fire if the phase files were well-written. It's a safety net.

**Cost:** ~$1-2 per phase. Cheap insurance.

---

## The Final Pipeline (v4.0 Complete)

```
For each phase in the sprint:

  0. PLAN VERIFY          ($1-2, 1 min)    — Check phase file quality
     └── FIXABLE? → Auto-amend phase file
     └── NEEDS_HUMAN? → STOP (safety net, should be ~0%)

  1. GATE 1: CONTRACT      ($0, <1 min)    — Verify prior contracts
     └── FAIL? → Repair Agent → Re-verify (2x max)

  2. BUILD                 ($10-30, 2-8 hr) — Socratic phase execution
     └── Tests-first, journal, contract

  3. GATE 3: TESTS         ($0, 2-10 min)  — Full test suite
     └── SAFETY FAIL? → Repair Agent → Re-test (2x max)
     └── WARN? → Inject, continue

  4. REVIEW AGENT          ($3-8, 5-15 min) — Code quality review
     └── REFACTOR? → Repair Agent → Re-review (2x max)
     └── WARN? → Inject, continue

  5. GATE 4: GAP MAP       ($1-2, 3-5 min) — Refresh codebase inventory
     └── Always continues (WARN only)

At sprint boundaries:

  6. GATE 2: INTEGRATION   ($2, 3-5 min)   — Cross-chain journal check
  7. INTEGRATION TESTS     ($5-10, 10-30 min) — Actually wire modules
     └── FIXABLE? → Write adapter, continue
     └── BLOCKING? → STOP (design conflict, ~0% expected)
  8. GATE 3 AGAIN          ($0, 2-10 min)  — Including new integration tests
```

**Expected STOP rate:** ~0-1 stops across 16 phases. The most likely stop point is Sprint 11 (Track X Phase 1-2, P2P crypto) where the Review Agent might flag architectural issues that the Repair Agent can't resolve in 2 passes. If that happens, the diagnostic is detailed enough that a 15-minute human review can unblock it.

---

## The v4.0 Runner Shape

The runner adds three new agent types to the phase execution pipeline:

```bash
run_phase_v4() {
    # 0. Plan verification
    run_plan_verify "$PHASE_FILE" "$GAP_MAP" "$PREV_JOURNAL"
    
    # 1. Gate 1: Contract (unchanged from v3)
    run_gate_1_contract ...
    
    # 2. Build phase (unchanged)
    run_phase ...
    
    # 3. Gate 3: Tests (unchanged, but now feeds into repair loop)
    run_gate_3_tests
    if [ $? -eq 1 ]; then
        run_repair_agent "gate-3-safety" "$PHASE_FILE" "$JOURNAL"
        run_gate_3_tests  # Re-test after repair
        [ $? -eq 1 ] && { log "🚫 STOP: Safety tests still failing after repair"; return 1; }
    fi
    
    # 4. Review Agent (NEW)
    run_review_agent "$PHASE_FILE" "$JOURNAL" "$GIT_DIFF"
    local REVIEW_VERDICT=$?
    if [ $REVIEW_VERDICT -eq 1 ]; then  # REFACTOR
        for attempt in 1 2; do
            run_repair_agent "review" "$REVIEW_OUTPUT" "$PHASE_FILE" "$JOURNAL"
            run_review_agent "$PHASE_FILE" "$JOURNAL" "$(git diff HEAD~1)"
            [ $? -ne 1 ] && break
        done
    fi
    
    # 5. Gate 4: Gap map (unchanged)
    run_gate_4_gap_map "$JOURNAL"
}

run_sprint_boundary_v4() {
    # 6-7. Integration (NEW: always runs integration tests, not just journal check)
    run_gate_2_integration ...
    run_integration_test_agent ...
    
    # 8. Final test suite with integration tests
    run_gate_3_tests
}
```

---

## Honest Assessment: Where Can This Still Fail?

I want to be precise about the remaining risk surface.

**~95% of phases will complete autonomously without issues.** The build agent does its job, tests pass, the review agent says PASS, gates are green.

**~4% of phases will need a repair pass.** The review agent flags something, the repair agent fixes it. One extra cycle, 5-10 minutes, $5-10. Fully automated.

**~1% of phases will hit a genuine design problem.** The most likely candidate: Track X Phase 4 (Proof of Integrity consensus). This is novel cryptographic protocol design. The Socratic questions are good, but the design space is vast. The build agent might choose an approach that works locally but has game-theoretic flaws that only appear under adversarial testing. The review agent might not catch game-theoretic flaws because it's reviewing code, not running adversarial simulations.

**For that 1%:** The diagnostic from the review agent + the session journal + the gate logs give you everything you need to make a 15-minute decision and unblock. You're not debugging from scratch. You're reviewing a specific flagged issue with full context.

**The v5.0 answer to that 1%:** An adversarial testing agent that runs attack simulations against novel protocols. But that's a research problem, not an engineering problem, and it's overkill for v2.5.0. Crossing that bridge when we reach it is the right call.

---

## Migration from v3.0 to v4.0

**New files:**
- `gates/plan-verify-prompt.md` — Plan Verification Agent prompt
- `gates/review-agent-prompt.md` — Review Agent prompt  
- `gates/integration-test-prompt.md` — Integration Test Agent prompt
- `gates/repair-agent-prompt.md` — Repair Agent prompt

**Updated files:**
- `run-sprint.sh` — v4.0 pipeline with new agents
- `CLAUDE.md` — Updated Gate Awareness section

**Unchanged:**
- All 16 phase files
- All 4 track overviews
- Methodology and gap map
- Orchestrator
- Gates 1-4 from v3.0

---

## Summary

| Version | Components | Human Role | Expected Stop Rate |
|---------|-----------|------------|-------------------|
| **v1.0** | 6 question types | Write plans, run every session, review everything | 100% (you run every phase) |
| **v2.0** | + tests-first, journals, contracts | Run sessions, review journals | 100% (you launch every phase) |
| **v3.0** | + 4 verification gates | Launch sprints, 30-min morning review | ~20% (gate FAILs need you) |
| **v4.0** | + review agent, repair agent, integration tests, plan verify | Come back when it's done | ~1% (novel design problems) |

**The honest claim:** v4.0 can run `./run-sprint.sh all` and produce a working v2.5.0 with ~99% autonomy. The 1% failure case produces a specific diagnostic that takes 15 minutes to resolve. You're not managing a build. You're on call for the one edge case where the system's self-correction isn't enough.

That's not "without you." That's "without you except when it actually matters."
