# Socratic Questioning Methodology for AI Coding Agents

**Purpose:** This document defines how questions should be structured in Socratic Forge build plans so that AI coding agents reason through problems rather than executing instructions.

**Load this file at the start of EVERY coding session.**

---

## The Core Principle

A leading question contains its own answer. A Socratic question forces the reasoner to discover the answer. The difference is the difference between a developer who implements a spec and a developer who understands the system.

### Anti-Pattern: The Leading Question

> "A dependency called 'co1ors' exists alongside the legitimate 'colors' package. The only difference is an L replaced with a 1. The agent installs it. What happens next? How do we prevent this before it happens?"

This TELLS the agent about typosquatting and asks it to implement a known solution. The agent learns nothing about the problem space — it just codes the answer it was given.

### Pattern: The Socratic Question

> "A repository lists 47 dependencies. You can verify that each dependency name resolves to a real package. But what does 'real' mean? What properties of a package name, combined with its registry metadata, would give you confidence that this is the package the developer intended — and not something else?"

This forces the agent to:
1. Discover that package names can be deceptive
2. Reason about what "legitimacy" means in a package ecosystem
3. Invent detection strategies (name similarity, download counts, publish dates, author verification)
4. Arrive at typosquatting detection as ONE of several strategies, not the only one

---

## The Six Question Types

### 1. Boundary Questions
Opens the problem space. Defines the edges. Forces the agent to enumerate preconditions rather than assuming them.

**Template:** "What must be true about [X] before [Y] can safely happen?"

**Example:** "What must be true about user-submitted data before it can be written to the database?"

### 2. Inversion Questions (Pressure Tests)
Introduces failure scenarios WITHOUT naming the vulnerability class. Forces the agent to think like an attacker or adversary.

**Template:** "Consider this scenario: [concrete situation]. What went wrong? What was the earliest point at which this could have been detected?"

**Example:** "A user account was created six months ago and has been operating normally. Today, it begins accessing records belonging to other users at a rate of 50 per second. Trace backward: what changed, and at what layer could this have been caught?"

### 3. Constraint Discovery Questions
Asks the agent to find limits the spec didn't mention. Forces trade-off reasoning rather than accepting the first solution.

**Template:** "What is the minimal set of [permissions/resources/access] that satisfies both constraints simultaneously? How do you know you haven't been too restrictive or too permissive?"

**Example:** "The API must be fast enough for real-time use but thorough enough for compliance. What are the costs and benefits of synchronous validation vs. async validation with eventual consistency?"

### 4. Precedent Questions
Forces the agent to learn from existing patterns in the codebase before inventing new ones. Prevents architectural drift and wheel reinvention.

**Template:** "[Existing module] already does [X]. How does your new system interact with it? Where do their responsibilities overlap, and how do you resolve that?"

**Example:** "The notification service already handles email delivery with retry logic and rate limiting. Your new alerting system also needs to send emails. Should it use the notification service, duplicate its logic, or something else? What are the trade-offs?"

### 5. Tension Questions
Asks the agent to navigate genuine trade-offs where two legitimate needs conflict. Forces creative resolution rather than picking a side.

**Template:** "[Need A] conflicts with [Need B]. How do you serve both?"

**Example:** "Full-text search over encrypted data is a contradiction: you need to read the data to index it, but encryption means you can't read it at rest. How do you provide useful search functionality without compromising the encryption guarantee?"

### 6. The cLaw Gate
Non-negotiable safety review at the end of every phase. This is not a checklist — it's the philosophical backbone of the Forge.

The Socratic Forge was developed alongside [Agent Friday](https://github.com/FutureSpeak-AI/agent-friday), an AI operating system built on a safety framework called **Asimov's cLaws** — an adaptation of Isaac Asimov's Three Laws of Robotics for AI systems with real-world agency, created by [Stephen C. Webster / FutureSpeak.AI](https://futurespeak.ai). The cLaws are cryptographically signed, verified at startup, and enforced through a trust engine that gates every interaction.

The development methodology was built around these same laws. Every phase ends with a cLaw Gate where the agent must reason through first-principles safety, not just follow a security checklist.

**Template (Asimov variant):** "Review everything you've designed in this phase. Walk through each of the Three Laws. Identify every point where this system could cause harm (First Law), disobey the user (Second Law), or fail to protect itself (Third Law). For each point, what is the mitigation?"

**Why this works better than a checklist:** When building systems with real agency — screen control, file access, communication management — "does this follow OWASP best practices" is necessary but insufficient. "Do not harm the user" is a more powerful constraint because it forces the agent to reason about harm categories no checklist anticipated.

**Adapting the cLaw Gate to your project:** Your gate should reflect your deepest values.

- **Healthcare:** "Does this phase expose patient data under any circumstances? Trace every data path."
- **Finance:** "Can any code path execute a transaction without explicit user confirmation?"
- **Privacy:** "Does this phase send any user data to external services, logs, or error messages?"
- **Performance:** "Does this phase introduce any O(n²) or worse operations on user-scale data?"
- **Accessibility:** "Does this phase maintain WCAG 2.1 AA compliance for all new UI?"
- **Cost:** "Does this phase add API calls that could exceed budget thresholds at scale?"

The principle is always the same: define a non-negotiable review rooted in your project's values, and never skip it. Safety issues compound across phases — a shortcut in Phase 2 becomes a structural vulnerability in Phase 8.

---

## Question Quality Checklist

Before including a question in a phase file, verify:

- [ ] Does the question have MORE THAN ONE valid answer? (If not, it's a leading question disguised as Socratic)
- [ ] Could a thoughtful developer disagree with my assumed answer? (If not, it's too narrow)
- [ ] Does the question require knowledge of the existing codebase to answer well? (If not, it's not grounded)
- [ ] Would skipping this question lead to a worse implementation? (If not, it's filler)
- [ ] Does the question avoid naming the solution technique? (If it mentions "rate limiter" or "circuit breaker" by name, it's leading)
- [ ] Does the question force a DESIGN DECISION, not just an implementation task? (If the agent could answer it by writing a single function, it's too narrow)

---

## Grounding Rules

Every phase file MUST include:

1. **CURRENT STATE** — What files exist today, what they do, and what patterns they use. The agent must know where it's starting from.
2. **ARCHITECTURE CONTEXT** — How the new code connects to existing systems. Data flows, interfaces, integration points.
3. **EXISTING PATTERNS** — How similar problems are already solved in the codebase. The agent should follow established patterns or explicitly justify diverging.
4. **BOUNDARY CONSTRAINTS** — What this phase should NOT touch. Prevents scope creep.

---

## The Question Arc

Each phase should follow this progression:

```
1. GROUND:    "What already exists in the codebase that relates to this problem?"
2. DEFINE:    "What specific problem are we solving, and what are its boundaries?"
3. INVERT:    "How could this solution fail, be attacked, or cause harm?"
4. CONSTRAIN: "What are the non-negotiable constraints, and what tensions exist between them?"
5. DESIGN:    "Given all of the above, what is the minimal architecture that satisfies every constraint?"
6. VALIDATE:  "How do we prove this works, and how do we prove it doesn't break what exists?"
7. GATE:      "Does this pass our safety review?"
```

---

*"The question you ask determines the quality of the answer you get. Ask an agent to implement a feature and you get an implementation. Ask an agent to solve a problem and you get a solution."*
