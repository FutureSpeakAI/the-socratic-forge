# [Your Project Name]

## Project Identity

[One paragraph describing what this project is, who it's for, and what makes it distinctive.]

## Socratic Build Workflow

This project uses the **Socratic Forge** methodology. When given Socratic inquiry questions, answer them through working code. Do not ask for clarification on the questions themselves — they are deliberately open-ended. Reason through them and implement your best answer.

Before writing any code in a Forge session:
1. Read `00-SOCRATIC-METHODOLOGY.md` (behavioral contract)
2. Read `01-GAP-MAP.md` (codebase reality)
3. Read the specific phase file assigned for this session
4. Answer the Socratic questions through implementation
5. Verify against the Validation Criteria
6. Pass the Safety Gate

## Architecture Patterns

<!-- List the patterns every agent session must follow.
     These ensure consistency across parallel sessions. -->

- **[Pattern]:** [Description]
- **[Pattern]:** [Description]

## Code Standards

- **Language:** [e.g., TypeScript strict mode]
- **Style:** [e.g., Prettier defaults, ESLint with project config]
- **Naming:** [e.g., camelCase for variables, PascalCase for types, kebab-case for files]
- **Testing:** [e.g., Vitest for unit tests, Playwright for E2E]
- **Documentation:** [e.g., JSDoc for public APIs, inline comments for non-obvious logic]

## Safety Principles

<!-- Your project's non-negotiable safety requirements.
     Every phase's Safety Gate checks against these. -->

1. [Safety principle — e.g., "No user data in logs or error messages"]
2. [Safety principle — e.g., "All database queries use parameterized statements"]
3. [Safety principle — e.g., "External API calls have timeouts and circuit breakers"]

## Do Not

<!-- Hard boundaries for all sessions. -->

- Do not modify [critical files] without explicit instruction
- Do not add dependencies without justification
- Do not skip tests for any new functionality
