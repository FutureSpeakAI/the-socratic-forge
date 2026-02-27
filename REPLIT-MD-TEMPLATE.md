# [Your Project Name] — Replit Agent Rules

## Project Identity

[One paragraph describing what this project is, who it's for, and what makes it distinctive.]

## Socratic Build Workflow

This project uses the **Socratic Forge** methodology. When working on a Forge phase:

1. The phase prompt will contain a condensed methodology preamble, a gap map summary, and Socratic inquiry questions
2. Answer the questions through working code — do NOT ask for clarification on deliberately open-ended questions
3. Use your self-testing loop to verify the Validation Criteria at the end of the prompt
4. Complete the Safety Gate review before considering the phase done

## Architecture Patterns

- **[Pattern]:** [Description]
- **[Pattern]:** [Description]

## Code Standards

- **Language:** [e.g., TypeScript strict mode]
- **Style:** [e.g., Prettier defaults]
- **Testing:** [e.g., Vitest for unit tests]
- **Database:** [e.g., Use built-in Replit PostgreSQL via Prisma]

## Safety Principles

1. [Safety principle]
2. [Safety principle]

## Autonomy Guidelines

<!-- Guide Replit Agent 3's autonomy level for different phase types. -->

- **Foundation phases** (establishing patterns): Use LOW autonomy. Human reviews agent's interpretation of Socratic questions before proceeding.
- **Implementation phases** (building on established patterns): Use MEDIUM autonomy. Let the agent work but review at validation checkpoints.
- **Testing/hardening phases** (verifying existing code): Use HIGH autonomy. Let the self-testing loop run fully.

## Self-Testing Assertions

<!-- Replit Agent 3's browser testing should verify these for every phase. -->

- [Global assertion — e.g., "No console errors on any page"]
- [Global assertion — e.g., "All API endpoints return proper HTTP status codes"]
- [Global assertion — e.g., "Authentication is required for all protected routes"]

## Notes

- When batching multiple phases in a single 200-minute session, include clear `--- PHASE BOUNDARY ---` separators
- Update the gap map comment at the top of each phase section with what the previous phase created
- Use RulesSync to keep these rules consistent across related Replit projects
