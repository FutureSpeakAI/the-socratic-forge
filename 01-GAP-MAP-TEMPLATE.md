# Gap Map — [Your Project Name]

**Last updated:** [Date]
**Updated after:** [Which phase was just completed]

---

## File Inventory

<!-- List every significant file in your project. For each:
     - File path
     - Line count (approximate is fine)
     - One-sentence description of what it does
     - Quality assessment: solid / needs work / prototype / stub
-->

| File | Lines | What It Does | Status |
|------|-------|-------------|--------|
| `src/index.ts` | ~50 | Application entry point, starts server | Solid |
| `src/routes/auth.ts` | ~200 | Authentication endpoints (login, register, refresh) | Needs work |
| <!-- Add your files here --> | | | |

---

## Architecture Patterns

<!-- Describe the patterns your codebase already uses.
     AI agents MUST follow established patterns or explicitly justify diverging.
     Examples: -->

- **[Pattern name]:** [Brief description of how it works and where it's used]
- **[Pattern name]:** [Brief description]

<!-- Example entries:
- **Route handlers:** All routes follow express middleware pattern with `req, res, next`. Error handling uses a centralized error middleware.
- **Database access:** All queries go through the repository pattern in `src/repos/`. No direct database calls from route handlers.
- **Configuration:** Environment variables loaded via `src/config.ts`, validated at startup.
-->

---

## Integration Points

<!-- Where must new code connect to existing systems?
     List the interfaces, hooks, and entry points that new code needs to use. -->

- **[Integration point]:** [What it connects to and how]

---

## Explicit Gaps

<!-- What does NOT exist yet but should? Be specific.
     This section drives your track and phase planning. -->

- [ ] [Gap description — e.g., "No test infrastructure of any kind"]
- [ ] [Gap description — e.g., "Authentication exists but no role-based access control"]
- [ ] [Gap description — e.g., "No error monitoring or alerting"]

---

## Key Constraints

<!-- Technical constraints that affect all development. -->

- **Language/Runtime:** [e.g., TypeScript, Node 22, React 19]
- **Database:** [e.g., PostgreSQL 16, Prisma ORM]
- **Deployment:** [e.g., Docker on AWS ECS, Vercel, self-hosted]
- **External APIs:** [List any third-party services the app depends on]

---

## Notes for AI Agents

<!-- Anything an agent starting a new session needs to know.
     Common patterns that aren't obvious from the code alone. -->

- [e.g., "All dates are stored as UTC timestamps, never local time"]
- [e.g., "The `utils/` directory is legacy — prefer adding helpers to domain-specific modules"]
