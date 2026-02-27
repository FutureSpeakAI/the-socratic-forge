# [Your Project Name] — Agent Instructions

## Project Identity

[One paragraph describing what this project is, who it's for, and what makes it distinctive.]

## Socratic Build Workflow

This project uses the **Socratic Forge** methodology. Agents dispatched on this project must:

1. Reference `00-SOCRATIC-METHODOLOGY.md` for the behavioral contract (or inherit it from the Socratic Forge skill)
2. Read `01-GAP-MAP.md` for current codebase reality before making any changes
3. Read the assigned phase file and answer its Socratic questions through implementation
4. Produce Artifacts at each Validation Criteria checkpoint for human review
5. Pass the Safety Gate before marking the phase complete

When given Socratic inquiry questions, answer them through working code. The questions are deliberately open-ended. Reason through them and implement your best answer.

## Agent Skills

<!-- Register these as Antigravity Skills for automatic inheritance:
     - Socratic Methodology (the six question types and behavioral contract)
     - Safety Gate Review (your project's safety checklist)
     - Code Standards (formatting, naming, testing conventions)
-->

## Architecture Patterns

- **[Pattern]:** [Description]
- **[Pattern]:** [Description]

## Code Standards

- **Language:** [e.g., TypeScript strict mode]
- **Style:** [e.g., Prettier defaults]
- **Testing:** [e.g., Vitest for unit, Playwright for E2E]

## Safety Principles

1. [Safety principle]
2. [Safety principle]

## Artifact Expectations

<!-- Map your validation criteria to Antigravity's artifact system. -->

For each completed phase, the agent should produce:
- A task plan artifact showing how it interpreted the Socratic questions
- Code artifacts for all new/modified files
- A test results artifact showing validation criteria pass/fail
- A Safety Gate review artifact documenting the safety assessment

## Browser Sub-Agent Testing

<!-- If your project has a UI, specify what browser agents should verify. -->

- [Test assertion for browser agent]
- [Test assertion for browser agent]
