# [Track Name], Phase [N]: [Phase Name]

**Track:** [Track Name — e.g., "The Fortress — Authentication & Authorization"]
**Depends on:** [What must be completed first, or "Nothing — can start immediately"]
**Blocks:** [What can't start until this is done]
**Estimated scope:** [Number of files, approximate LOC — e.g., "3-5 files, ~800-1200 LOC"]

---

## Current State

<!-- What exists RIGHT NOW in the codebase that's relevant to this phase?
     Be specific: file names, line counts, what they do, what patterns they use.
     Pull from the Gap Map but focus on this phase's domain. -->

**`[filename]` (~[N] lines)** does [what it does]. [Key detail about its patterns or limitations].

**What does NOT exist:** [Explicit statement of what this phase will create that doesn't exist yet.]

---

## Architecture Context

<!-- How does the new code connect to existing systems?
     Show the data flow, the integration points, the interfaces to implement.
     A simple ASCII diagram is ideal. -->

```
[Current flow]
User request → [existing step] → [existing step] → response

[Flow after this phase]
User request → [existing step] → [NEW: what you're building] → [existing step] → response
```

---

## Socratic Inquiry

### Foundational: [Problem Space Name]

<!-- Start with a Boundary Question that opens the problem space.
     Don't hint at solutions. Force the agent to define the problem first. -->

**[Your boundary question here.]**

**Follow-up:** [A deeper question that builds on the first.]

### [Second Inquiry Area Name]

<!-- Add an Inversion or Constraint Discovery question.
     Force the agent to think about failure modes or tradeoffs. -->

**[Your question here.]**

**Design question:** [Ask for architecture without prescribing the shape.]

### [Third Inquiry Area Name]

<!-- Add a Precedent or Tension question.
     Ground the agent in existing code patterns or force tradeoff navigation. -->

**[Your question here.]**

**Integration question:** [Ask how this connects to what already exists.]

### Synthesis

<!-- Ask the agent to compose everything into a coherent system.
     This is where the pieces come together. -->

**You now have [N] components. How do they compose into a single coherent system? What's the minimal architecture that satisfies every constraint you've identified?**

---

## Boundary Constraints

<!-- What this phase does NOT do. Be explicit. Prevent scope creep. -->

- This phase ONLY builds [specific scope]. It does NOT [out of scope thing].
- Do not modify [existing file/system that should not be touched].
- The output is [specific deliverable] consumed by [next phase]. Do not build [things that come later].

---

## Validation Criteria

<!-- Concrete, testable outcomes. The agent knows it's done when ALL of these are true. -->

- [ ] [Specific testable assertion — e.g., "A user with 'editor' role can create posts but cannot delete other users' posts"]
- [ ] [Performance assertion — e.g., "Authentication flow completes in under 200ms"]
- [ ] [Integration assertion — e.g., "New middleware works with all existing route handlers without modification"]
- [ ] [Negative assertion — e.g., "An expired token is rejected with a 401, not a 500"]

---

## Safety Gate

<!-- Your project's non-negotiable safety check. Adapt to your domain.
     Every phase ends here. No exceptions. -->

**[Your safety domain]:** Review everything you've designed in this phase. [Specific safety questions for your domain.]

<!-- Examples:
**Privacy:** Does any user data flow to external services, error logs, or debug output? Trace every data path.
**Security:** Walk through OWASP Top 10. Which apply? What are the mitigations?
**Performance:** Does this phase introduce operations that scale worse than O(n log n) on user data?
**Cost:** Does this phase add API calls? At 10,000 users, what's the monthly cost impact?
**Accessibility:** Does every new UI element have proper ARIA labels, keyboard navigation, and color contrast?
-->

---

**On completion:** [What the next phase receives from this one. E.g., "Hand the auth middleware and user session types to Phase 2."]
