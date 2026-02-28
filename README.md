# The Socratic Forge v4.0: Self-Healing Autonomous Software Development

**By Stephen C. Webster** | Senior Director of Integrated Intelligence at Aquent Studios

> *The unexamined code is not worth shipping.*

---

## What Is The Socratic Forge?

The Socratic Forge is a complete operating system for AI-driven software development. Instead of giving AI agents instructions, you give them **questions** — and the inquiry builds context, the context becomes a plan, and the plan becomes software.

**v4.0** adds **self-healing autonomous execution**: a pipeline where AI agents build, verify, review, repair, and integrate code with ~99% autonomy and ~1% human intervention.

```
./run-sprint.sh all    # walk away — come back to working software
```

---

## The Evolution

| Version | What It Added |
|---------|--------------|
| **v1.0 — The Paintbrush** | Inquiry-driven development. Ask questions, get better code. |
| **v2.0 — The Forge** | Six layers: Methodology, Gap Map, Tracks, Phases, Orchestrator, Identity File. |
| **v3.0 — Gated Execution** | Four verification gates between phases. Contract checking, test verification, parallel coordination. |
| **v4.0 — Self-Healing** | Review Agent, Repair Agent, Integration Test Agent, Plan Verification. Full autonomous pipeline. |

---

## Repository Structure

```
the-socratic-forge/
  README.md                          # You are here
  FORGE-v4.0-SELF-HEALING.md         # Complete v4.0 methodology document
  run-sprint.sh                       # Autonomous sprint runner
  gates/                              # Agent prompt templates
    review-agent-prompt.md            # Code quality review agent
    plan-verify-prompt.md             # Pre-build plan verification
    repair-agent-prompt.md            # Surgical code repair agent
    integration-test-prompt.md        # Cross-chain integration testing
  00-SOCRATIC-METHODOLOGY.md          # Core methodology (6 question types)
  01-GAP-MAP.md                       # Example gap map
  01-GAP-MAP-TEMPLATE.md              # Gap map template
  ORCHESTRATOR.md                     # Example orchestrator
  ORCHESTRATOR-TEMPLATE.md            # Orchestrator template
  PHASE-TEMPLATE.md                   # Phase file template
  TRACK-OVERVIEW-TEMPLATE.md          # Track overview template
  CLAUDE-MD-TEMPLATE.md               # Claude Code identity file template
  AGENTS-MD-TEMPLATE.md               # Google Antigravity identity template
  REPLIT-MD-TEMPLATE.md               # Replit identity template
  FORGE-v3.0-BUILD-METHOD.md          # v3.0 methodology (reference)
  ORIGINAL-ESSAY.md                   # The original Socratic Forge essay
  LICENSE                             # MIT License
```

---

## Quick Start

### 1. Adopt the Methodology

Read `FORGE-v4.0-SELF-HEALING.md` for the complete system. The key insight: every phase passes through a **self-healing pipeline**:

```
BUILD → VERIFY (tests) → REVIEW (code quality) → REPAIR (if needed) → CONTINUE
```

### 2. Set Up Your Project

```bash
# In your repo root:
mkdir -p socratic-roadmaps/gates

# Copy templates:
cp 00-SOCRATIC-METHODOLOGY.md    your-repo/socratic-roadmaps/
cp 01-GAP-MAP-TEMPLATE.md        your-repo/socratic-roadmaps/01-GAP-MAP.md
cp ORCHESTRATOR-TEMPLATE.md       your-repo/ORCHESTRATOR.md
cp PHASE-TEMPLATE.md              your-repo/socratic-roadmaps/
cp TRACK-OVERVIEW-TEMPLATE.md     your-repo/socratic-roadmaps/
cp CLAUDE-MD-TEMPLATE.md          your-repo/CLAUDE.md   # or AGENTS.md for Antigravity

# Copy v4.0 gates:
cp gates/*.md                     your-repo/socratic-roadmaps/gates/
cp run-sprint.sh                  your-repo/
```

### 3. Write Your Gap Map

Inventory your codebase. For every significant file: what it does, how many lines, what patterns it uses, what it exports. This is your agent's memory.

### 4. Write Tracks and Phases

Group development goals into parallel tracks. Break each track into phases completable in one session. Use the six question types:

| Type | Purpose | Template |
|------|---------|----------|
| **Boundary** | Define edges before solving | "What must be true about X before Y can safely happen?" |
| **Inversion** | Think like an attacker | "If you wanted to break this, what would you exploit?" |
| **Constraint Discovery** | Find rules, don't receive them | "What is the minimal set of permissions that satisfies both constraints?" |
| **Precedent** | Prevent wheel reinvention | "Module X already solves this. What pattern did it use?" |
| **Tension** | Navigate real tradeoffs | "Two legitimate needs conflict. How do you serve both?" |
| **cLaw Gate** | Non-negotiable safety review | "Walk through each law. Where could this cause harm?" |

### 5. Run Autonomous Sprints

```bash
# Configure the runner:
export ALLOWED_TOOLS="Read,Write,Edit,Bash,Grep"
export MAX_TURNS=200

# Run a single sprint:
./run-sprint.sh 9

# Run everything:
./run-sprint.sh all
```

---

## The v4.0 Self-Healing Pipeline

### What Changed From v3.0

v3.0 had four gates that verify work between phases. They catch contract drift, test failures, pattern violations, and gap map staleness. But three failure modes still required human judgment:

1. **Bad architecture that passes tests** — God functions, reimplemented utilities, unmaintainable code
2. **Scope creep** — agent builds extras that confuse the next phase
3. **Integration failures contracts don't predict** — runtime incompatibilities hidden by matching type signatures

v4.0 replaces the human with three new agents:

### The Review Agent

After every build phase, a dedicated session reads the **actual code diff** and evaluates:

- **Pattern adherence** — Does it follow the gap map's documented patterns?
- **Complexity** — Functions >80 lines, files >400 lines, >4 parameters?
- **Reimplementation** — Does it duplicate existing utilities?
- **Extensibility** — Will the next phase build on this naturally?
- **Scope match** — Does it match the phase's validation criteria exactly?
- **Test quality** — Are tests testing behavior or implementation?

Verdict: **PASS** (zero REFACTOR issues) | **REFACTOR** (needs repair) | **WARN** (log and continue)

### The Repair Agent

When the Review Agent returns REFACTOR, a surgical repair session:
- Reads the specific issues with file paths and line ranges
- Applies each fix as described — no re-architecting
- Runs tests after each fix
- Maximum 2 repair cycles per phase

### The Integration Test Agent

At sprint boundaries (where parallel chains merge):
- Writes integration tests across all chain boundaries
- Tests function calls, type compatibility, initialization order, error propagation
- Classifies failures: **PASS** | **FIXABLE** (write adapter) | **BLOCKING** (needs plan change)

### Plan Verification Agent

Before build starts, validates the phase file:
- Are validation criteria measurable (not "works correctly")?
- Are boundary constraints complete?
- Are referenced modules real (not stale)?
- Are dependencies completed?
- Is scope realistic for one session?

---

## Cost Model

| Component | Cost per phase | Notes |
|-----------|---------------|-------|
| Plan Verify | ~$1 | 30 turns, reads 3 files |
| Build Phase | ~$15 | 200 turns, full implementation |
| Gate 1-4 | ~$2 | Quick verification checks |
| Review Agent | ~$3 | 30 turns, reads diff + phase + journal |
| Repair Agent | ~$5 (if needed) | 50 turns, surgical fixes |
| Integration Tests | ~$10 per boundary | 100 turns, writes + runs tests |

**Total for 16 phases**: ~$300-700 depending on repair frequency

---

## Platform Support

The Socratic Forge works with any AI coding platform:

- **Claude Code** — Native support via `claude -p` CLI. The runner uses this.
- **Google Antigravity** — Use AGENTS.md, Skills system, Manager View for parallel tracks
- **Replit** — Use replit.md, front-load context into Agent prompts, leverage self-testing

See the templates directory for platform-specific identity file templates.

---

## The Cardinal Rule

**Never put the answer in the question.**

Bad: "A dependency called 'co1ors' exists alongside the legitimate 'colors' package. How do we prevent this?"

Good: "What properties of a package name, combined with its registry metadata, would give you confidence this is the package the developer intended?"

The bad question gets you one solution. The good question gets you a system.

---

## Further Reading

- [FORGE-v4.0-SELF-HEALING.md](./FORGE-v4.0-SELF-HEALING.md) — Complete v4.0 methodology with sprint definitions
- [ORIGINAL-ESSAY.md](./ORIGINAL-ESSAY.md) — The founding essay on the Socratic Forge
- [00-SOCRATIC-METHODOLOGY.md](./00-SOCRATIC-METHODOLOGY.md) — Core methodology for your agents
- [The Socratic Paintbrush](https://www.linkedin.com/pulse/introducing-socratic-paintbrush-most-powerful-way-build-webster-be13c/) — Where it all started

---

## License

MIT License. See [LICENSE](./LICENSE).

---

*Built by [FutureSpeak.AI](https://futurespeak.ai) — Creators of Agent Friday, the AGI OS.*
