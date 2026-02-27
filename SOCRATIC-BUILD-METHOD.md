# The Socratic Forge — Build Method

**A system for using AI coding agents to build complex software through guided inquiry instead of instruction.**

**Author:** Stephen C. Webster / [FutureSpeak.AI](https://futurespeak.ai)
**Date:** February 2026

---

## What This Is

The Socratic Forge is a project planning system designed for AI coding agents (Claude Code, Google Antigravity, Replit, Cursor, Copilot Workspace, etc.). Instead of giving the agent step-by-step instructions, you give it carefully structured *questions* that force it to reason through the problem space, discover edge cases, and arrive at better implementations than any instruction set could specify.

The core insight: an agent that follows instructions produces code that matches a spec. An agent that answers questions produces code that *understands the problem*. The difference shows up in edge case handling, architecture decisions, and the quality of solutions the agent invents for problems you didn't anticipate.

---

## Why This Works

Traditional project plans tell an agent *what* to build and *how* to build it. This creates three problems:

**The Spec Problem.** Your spec can never be complete. Every real implementation hits situations the spec didn't anticipate. An instruction-following agent stops or guesses. A reasoning agent handles it because it understood the *why* behind the work.

**The Tunnel Vision Problem.** Instructions narrow the agent's attention to exactly what you described. Socratic questions widen it. When you ask "What properties of a package name would give you confidence this is the intended package?", the agent discovers typosquatting, namespace confusion, version squatting, and dependency confusion attacks — not just the one you were thinking of.

**The Ownership Problem.** An agent that was told what to do treats the code as someone else's design. An agent that reasoned its way to the solution treats it as its own. This shows up in code quality, documentation, and how well the pieces fit together.

---

## System Architecture

A complete Socratic Forge has six layers:

```
ORCHESTRATOR.md                    ← Your command center (launch prompts, status tracking)
    │
CLAUDE.md / AGENTS.md / replit.md  ← Project-level instructions for the agent
    │
┌───┴──────────────────────────────────────────┐
│  00-SOCRATIC-METHODOLOGY.md                  │  ← Loaded EVERY session
│  01-GAP-MAP.md                               │  ← Loaded EVERY session
│  Track-level overview files (per track)      │
│  Phase-level task files (per phase)          │  ← ONE loaded per session
└──────────────────────────────────────────────┘
```

Each layer has a specific purpose and audience. See the `templates/` directory for ready-to-use versions of each.

### Layer 1: The Methodology (loaded every session)

Teaches the agent HOW to engage with questions. Defines six question types and — critically — the difference between a leading question and a Socratic one. Establishes a behavioral contract: "You are not being given instructions. You are being given questions. Your job is to answer them through working code."

See `00-SOCRATIC-METHODOLOGY.md` for the complete methodology.

### Layer 2: The Gap Map (loaded every session)

Grounds every session in what actually exists in the codebase. A structured inventory: what files exist, what they do, what patterns they use, what's missing. Prevents the agent from building something that already exists or breaking something it didn't know about.

### Layer 3: Track Overviews (reference material)

Full narrative description of an entire development track. Each track covers a major capability area. These are reference documents — not loaded into every session, but available when an agent needs the bigger picture.

### Layer 4: Phase Files (one loaded per session)

The actual work plan for a single implementation phase. This is where the Socratic questions live. Each phase file is self-contained: current state, architecture context, Socratic inquiries, boundary constraints, validation criteria, and safety gate.

### Layer 5: Project Identity File (persistent)

`CLAUDE.md` (Claude Code), `AGENTS.md` (Antigravity), or `replit.md` (Replit). Establishes project identity, architecture patterns, code standards, and the Socratic workflow. The agent reads this automatically at every session start.

### Layer 6: Orchestrator (human command center)

Status checkboxes, dependency gates, ready-to-paste launch prompts, sprint sequences, and a parallel work diagram.

---

## How to Build One for Your Project

### Step 1: Inventory Your Codebase

Before writing any questions, know exactly what you have. For every significant file: what does it do (one sentence), how many lines, what patterns does it use, what does it export. This becomes your gap map.

If you're starting from scratch, describe your intended architecture and what exists so far (even if that's nothing).

### Step 2: Define Your Tracks

Group your development goals into parallel tracks. A track is a major capability area with internal sequential dependencies that can progress independently of other tracks. Good tracks are:

- **Cohesive** — everything in the track serves one goal
- **Sequentially ordered** — phases within a track build on each other
- **Independently progressable** — the track can advance without waiting for other tracks (at least for the first few phases)

**Name your tracks evocatively.** "The Auth Fortress" is better than "Track 1: Authentication." Names create identity and help the agent understand the system's metaphor.

### Step 3: Break Tracks into Phases

Each phase should be completable in a single agent session (~1-3 hours of agent work, producing 500-2000 lines of code). A phase is:

- **Atomic** — ships a complete, testable unit of functionality
- **Bounded** — explicit constraints on what it does NOT do
- **Verifiable** — concrete validation criteria, not vibes

If a phase feels too big, split it. If it feels too small, merge it with an adjacent phase.

### Step 4: Write the Socratic Questions

This is the craft. For each phase, follow this arc:

**Start with boundaries.** "What must be true about X before the system can safely do Y?" Forces the agent to discover preconditions.

**Move to design.** "How do you design Z so that it handles A, B, and C without becoming a maintenance burden?" Forces architecture thinking.

**Include inversions.** "If a malicious actor wanted to exploit this system, what would they target?" Forces defensive design.

**Reference existing patterns.** "Module M already solves a similar problem. Study its approach before designing yours." Prevents reinvention.

**End with synthesis.** "You now have five components. How do they compose into a single coherent system?" Forces integration thinking.

**Close with the safety gate.** Always.

**The Cardinal Rule: Never put the answer in the question.**

Bad: "A dependency called 'co1ors' exists alongside 'colors'. The only difference is an L replaced with a 1. How do we prevent this?"

Good: "What properties of a package name, combined with its registry metadata, would give you confidence this is the package the developer intended — and not something else?"

### Step 5: Write the Orchestrator

Map phases to sprints. Identify the critical path (longest chain of sequential dependencies) and parallel opportunities (tracks that can run simultaneously from day one).

For each phase, write a launch prompt that loads exactly three files:

```
Read these three files in order, then begin implementation:
1. socratic-roadmaps/00-SOCRATIC-METHODOLOGY.md
2. socratic-roadmaps/01-GAP-MAP.md
3. socratic-roadmaps/track-N/phase-N-name.md

[One sentence describing the starting point and ending condition]
```

Three files keeps context focused (~400-500 lines total). The methodology and gap map are always the same. Only the phase file changes.

### Step 6: Write the Project Identity File

Establish your project identity, architecture patterns, code standards, and the Socratic workflow contract. This shapes every agent session even when you're not actively supervising.

---

## Operating the System

### Daily Workflow

1. Open `ORCHESTRATOR.md`
2. Find the next phase whose dependencies are all checked off
3. Copy the launch prompt
4. Paste it into your AI coding agent as the opening message
5. The agent reads three files, reasons through the questions, and implements
6. Review the output against the Validation Criteria in the phase file
7. Check the box in the orchestrator, move to the next phase

### Running Parallel Sessions

The orchestrator's dependency diagram shows which tracks can run simultaneously. Multiple agent sessions load the same methodology and gap map but different phase files. They can't conflict because phase files define non-overlapping scope.

### When Things Go Wrong

1. Don't throw away a failed attempt. Read what it produced — the reasoning may be sound but the implementation off.
2. Start a new session with the same launch prompt plus a note: "Previous attempt produced X. The issue was Y. Reason through the same questions with this additional context."
3. If a phase consistently fails, the questions may be too ambiguous or the scope too large. Split the phase.

### Updating the Gap Map

After each completed phase, update `01-GAP-MAP.md` with the new files, patterns, and capabilities that now exist. This keeps subsequent sessions grounded in reality rather than an increasingly stale snapshot. **This is not optional.**

---

## Context Budget

The three-file-per-session pattern exists because AI agents have limited context windows:

- `00-SOCRATIC-METHODOLOGY.md` ≈ 90 lines (behavioral contract)
- `01-GAP-MAP.md` ≈ 100-300 lines (codebase reality)
- Phase file ≈ 80-150 lines (work plan)

**Total: ~300-500 lines.** This leaves the vast majority of the context window free for code, reasoning, and tool use. Loading all files simultaneously crowds out the agent's working memory and degrades performance.

---

## Platform-Specific Notes

### Claude Code
Place `CLAUDE.md` in your project root — it's read automatically. Use the three-file launch prompts. Run parallel sessions on non-blocking tracks.

### Google Antigravity
Use `AGENTS.md`. Load the methodology as an Agent Skill. Use Manager View for parallel track execution. Map validation criteria to the artifact system.

### Replit
Use `replit.md` with RulesSync. Front-load context into the Agent prompt. Let Agent 3's self-testing loop handle safety gate assertions. Batch 2-3 sequential phases per session.

### Cursor / Windsurf / Others
Use `.cursorrules` or equivalent. The three-file pattern works in any agent that can read markdown files.

---

## Scaling

| Scale | Tracks | Phases/Track | Orchestrator? |
|-------|--------|-------------|---------------|
| Weekend project | 1 | 2-3 | No |
| Side project | 1-2 | 3-5 | Optional |
| Production app | 3-5 | 3-6 | Yes |
| Enterprise | 5-15 | 3-8 | Essential |

---

## Anti-Patterns to Avoid

**The Instruction Disguised as a Question.** "Given that we need Redis here, what key schema should we use?" — you already decided on Redis. Instead: "This data is read 100x more than it's written. What caching strategies exist, and what properties of this data should drive the choice?"

**The Kitchen Sink Phase.** If a phase file is over 200 lines, it's trying to do too much. Split it.

**The Stale Gap Map.** Update after every completed phase. Non-negotiable.

**Overloading Context.** Never load more than 3-4 files into a session. Summarize cross-track context in the phase file.

**Skipping the Safety Gate.** The gate exists because agent reasoning is good but not infallible, and safety issues compound across phases.

---

## Quick-Start Checklist

- [ ] Inventory your codebase → write `01-GAP-MAP.md`
- [ ] Define 1-5 tracks → write track overviews
- [ ] Break each track into 2-5 phases → write phase files with Socratic questions
- [ ] Add Validation Criteria and Safety Gate to every phase
- [ ] Copy `00-SOCRATIC-METHODOLOGY.md` from this repo (or write your own)
- [ ] Write your project identity file (`CLAUDE.md` / `AGENTS.md` / `replit.md`)
- [ ] Write `ORCHESTRATOR.md` with dependency gates and launch prompts
- [ ] Launch your first session
- [ ] Update the gap map after each completed phase

---

*"The unexamined code is not worth shipping."*
