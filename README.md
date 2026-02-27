The Socratic Forge: How I Taught My AI Agents to Develop Software Like a Journalist Develops a Story

Stephen C. Webster Senior Director of Integrated Intelligence at Aquent Studios | Trained Gemini and Bard at Google | Accenture alum | Former journalist

Last month, I published an essay called “The Socratic Paintbrush” about a method I’d discovered for building software with AI, and the core idea was deceptively simple: instead of giving AI instructions, ask it questions, then let the inquiry build context, let the context become a plan, and let the plan become software. The response was overwhelming, with hundreds of developers trying the method and many of them messaging me directly about their results.

But something happened as I applied the Paintbrush to increasingly complex builds: the method evolved, growing layers, structure, safety mechanisms, and an orchestration system that can run dozens of parallel AI agents across months of development, until what started as a technique became a complete operating system for AI-driven software development.

The Paintbrush was the tool, and what I’m sharing today is the Forge.

I’m calling it The Socratic Forge because that’s what it does: it takes raw questions and, under heat and pressure, tempers them into hardened software. If the Paintbrush was about discovering that philosophy eats AI, the Forge is about industrializing that discovery into a repeatable system that works across every major agentic coding platform available right now.

I’m going to walk you through the entire system, then show you exactly how to implement it in Claude Code, Google Antigravity, and Replit, and I believe this is the most practical thing I’ve ever written because if you use any of these tools, this essay will change how you use them.
What Changed: From Technique to System

The Socratic Paintbrush had one key insight: inquiry builds better context than instruction, and while that’s still true, applying it to a real, large-scale build exposed a problem that the original method couldn’t solve on its own: unstructured inquiry doesn’t scale. When you’re building a 22,000-line codebase with 132 files across 9 capability tracks, you can’t just “ask good questions” and hope it all holds together.

The Forge adds six layers of structure on top of the Paintbrush’s philosophical foundation. Think of it as the difference between a painter working alone in a studio and an architect running a construction site with multiple crews, blueprints, safety inspections, and a project schedule. The creative eye is the same, but the execution framework is radically different.

Here are the six layers, each with a specific purpose and a specific audience:

Layer 1: The Methodology. This is a document that teaches your AI agents HOW to engage with questions. It defines six question types (Boundary, Inversion, Constraint Discovery, Precedent, Tension, and cLaw Gate) and establishes a behavioral contract: “You are not being given instructions. You are being given questions. Your job is to answer them through working code.”

Layer 2: The Gap Map. This is a structured inventory of your codebase’s current state, covering what files exist, what they do, what patterns they use, and what’s missing. It serves as the agent’s “memory,” and without it, every session starts from zero knowledge.

Layer 3: Track Overviews. These are your development goals grouped into parallel tracks, where each track is a major capability area with a narrative identity. In my build, Track I is “The Immune System” (security scanning), Track II is “The Absorber” (code ingestion), and Track V is “The Apprentice” (workflow learning), because evocative names create a sense of identity that keeps the agent focused on the track’s narrative purpose.

Layer 4: Phase Files. Each track breaks into phases, and each phase is a self-contained unit of work consisting of one session and one coherent deliverable. The phase file contains the current state, architecture context, Socratic inquiries, validation criteria, and a mandatory safety gate. This is where the questions live.

Layer 5: The Orchestrator. This is your command center, containing status checkboxes, dependency gates, ready-to-paste launch prompts, sprint sequences, and a parallel work diagram showing which tracks can run simultaneously. It is what turns a collection of plans into a coordinated build.

Layer 6: The Project Identity File. This is a file (such as CLAUDE.md, AGENTS.md, .replit rules, or their equivalent) that establishes your project’s personality, architecture patterns, code standards, and the Socratic workflow contract. It shapes every agent session even when you’re not supervising.

The Six Question Types That Make It Work

This is the engine of the Forge. Every question in every phase file follows one of six types. Understanding them is the difference between “asking good questions” and systematically forcing your agents to reason at the level of a senior architect.

1. Boundary Questions force the agent to define the edges of a problem before solving it.
   
Template: “What must be true about X before Y can safely happen?”

Example: “What must be true about an external codebase before any of its logic is allowed to execute inside your application’s process?”

This forces the agent to enumerate preconditions like sandboxing, permission scoping, dependency verification, and input validation, whereas an instruction would name one of those preconditions while the question discovers all of them.

3. Inversion Questions force the agent to think like an attacker.
   
Template: “If you wanted to break this system, what would you exploit?”

Example: “You are a malicious developer who wants to get your code absorbed by this system. You know the security pipeline performs static analysis, behavioral sandboxing, and AI-powered code review. Design three attacks, one that defeats each layer individually. Then answer this: what attack defeats all three simultaneously?”

This produces defensive code that anticipates threats the developer never considered. I’ve watched agents discover attack vectors from this question type that weren’t in any spec I wrote.

5. Constraint Discovery Questions force the agent to find the constraints themselves rather than receiving them.
   
Template: “What is the minimal set of permissions that satisfies both constraints simultaneously?”

Example: “The sandbox must allow adapted code to demonstrate its functionality while preventing every form of harm to the host system. How do you know you haven’t been too restrictive or too permissive?”

Instead of handing the agent a list of rules, this makes the agent discover the rules and understand why they exist. Code written from discovered constraints handles edge cases that spec-driven code misses.

8. Precedent Questions prevent your agents from reinventing wheels.
   
Template: “Module X already solves a similar problem. What pattern did it use, and where does your new system need to diverge?”

Example: “The SOC bridge already solves the problem of executing Python code from Node.js with isolation guarantees. What specific patterns does soc-bridge.ts use for process lifecycle, communication protocol, error handling, and timeout enforcement? Which of those patterns apply to the new cross-language execution bridge, and where must you diverge?”

Precedent questions provide grounding, because without them agents build architecturally incompatible abstractions in every session, while with them the codebase stays cohesive across dozens of parallel work streams.

11. Tension Questions force agents to navigate genuine tradeoffs instead of picking a side.
    
Template: “Two legitimate needs conflict. How do you serve both?”

Example: “The user receives 40 messages per hour and needs to respond to 15 of them. Requiring individual approval for each outbound message creates a bottleneck that makes the system slower than manually typing in each app. How do you design a consent model that maintains user control while being fast enough that the user actually uses it?”

This produces elegant solutions that balance competing requirements, and without tension questions to force that balancing act, agents tend to make blunt binary choices that satisfy one need at the expense of the other.

14. The cLaw Gate. Every phase ends here, and this requirement is non-negotiable.
    
This one needs context, because it’s not just a question type but rather the philosophical backbone of the entire Forge.

The project where I developed this method, Agent Friday, is built on a safety framework I created called Asimov’s cLaws, which is an adaptation of Isaac Asimov’s Three Laws of Robotics for AI systems with real-world agency. These aren’t metaphorical guardrails; they’re cryptographically signed, verified at every startup, and enforced through a 5-tier trust engine that gates every interaction from local desktop access down to unknown senders who get nothing.

Here’s the key insight: I didn’t just build the agent around these laws, I built the entire development methodology around them too. Every single phase in the Forge ends with a cLaw Gate, which is a mandatory safety review where the agent must walk through each law and identify every point where its implementation could cause harm, disobey the user, or fail to protect itself, and no phase ships until it passes.

Template: “Review everything you’ve designed in this phase. Walk through each of the Three Laws. Identify every point where this system could cause harm (First Law), disobey the user (Second Law), or fail to protect itself (Third Law). For each point, what is the mitigation?”

Why Asimov? Because when you’re building an AI system that can see your screen, control your mouse, manage your communications, and learn your behavioral patterns, “does this follow OWASP best practices” is necessary but insufficient. You need a first-principles safety framework that works at the level of agency itself. “Do not harm the user” is a more powerful constraint than any security checklist, because it forces the agent to reason about harm categories the checklist didn’t anticipate.

Here’s what makes this generalizable: your project’s cLaw Gate will reflect your values. If you’re building a healthcare app, your First Law might be “do not expose patient data under any circumstances.” If you’re building a financial tool, it might be “never execute a transaction without explicit user confirmation.” If you’re building an accessibility-focused product, it might be “no phase ships that reduces WCAG compliance.” The principle is always the same: define a non-negotiable safety review at the end of every phase, rooted in your project’s deepest values, and never skip it.

The gate exists because agent reasoning is good but not infallible, and because safety issues compound across phases, meaning a shortcut in Phase 2 becomes a structural vulnerability in Phase 8 that the cLaw Gate would have caught early.

The Cardinal Rule

Never put the answer in the question.

Bad: “A dependency called ‘co1ors’ exists alongside the legitimate ‘colors’ package. The only difference is an L replaced with a 1. How do we prevent this?”
Good: “What properties of a package name, combined with its registry metadata, would give you confidence this is the package the developer intended and not something else?”

The bad question tells the agent about typosquatting and asks it to implement detection. The good question forces the agent to discover typosquatting, namespace confusion, version squatting, and dependency confusion attacks as part of a broader reasoning process. The bad question gets you one solution. The good question gets you a system.

The Context Budget: Why Three Files Per Session

Here’s a constraint that surprises people: each agent session loads exactly three files.

The Methodology, which is roughly 90 lines and contains the behavioral contract.

The Gap Map, which is roughly 250 lines and contains the codebase reality.

One Phase File, which is roughly 80 to 150 lines and contains the work plan.

The total is roughly 400 to 500 lines. This leaves the vast majority of the agent’s context window free for actual code, reasoning, and tool use. I learned the hard way that loading all 4,000+ lines of the complete system into a single session crowds out the agent’s working memory and degrades performance. The three-file pattern is a hard constraint that exists for a practical reason.

This design choice is also what makes parallel execution possible. Multiple agents can run simultaneously because each loads the same methodology and gap map but a different phase file. They can’t conflict because the phase files define non-overlapping scope.

How to Implement This in Claude Code

Claude Code is where I developed the Forge, and it’s where the system works most naturally. Here’s the exact implementation.
Step 1: Create your project structure.

In your repo root, create a directory called socratic-roadmaps/ (or whatever you prefer). Inside it:

socratic-roadmaps/
  00-SOCRATIC-METHODOLOGY.md
  01-GAP-MAP.md
  track-1/
    phase-1-name.md
    phase-2-name.md
  track-2/
    phase-1-name.md
ORCHESTRATOR.md    (repo root)
CLAUDE.md          (repo root)

Step 2: Write CLAUDE.md.

This file lives at your repo root. Claude Code automatically reads it at the start of every session. Mine establishes the project identity, key architecture patterns, code standards, and the Socratic workflow. The critical line is: “When given Socratic inquiry questions, answer them through working code. Do not ask for clarification on the questions themselves, because they are deliberately open-ended. Reason through them and implement your best answer.”
Step 3: Write the Methodology.

Copy or adapt the six question types I described above. The methodology file is a behavioral contract between you and the agent. It’s short at roughly 90 lines, and it fundamentally changes how the agent interprets everything that follows.

Step 4: Write the Gap Map.

Inventory your codebase. For every significant file, document what it does (one sentence), how many lines it has, what patterns it uses, and what it exports. Include architecture patterns the codebase already uses, integration points where new code must connect, and explicit gaps where functionality doesn’t exist yet but should. Update this after every completed phase.

Step 5: Write your Tracks and Phases.

Group your development goals into tracks. Break each track into phases that are completable in a single session. For each phase, write Socratic questions following the six types. Start with boundaries, move to design, include inversions, reference existing patterns, end with synthesis, and close with the safety gate.

Step 6: Write the Orchestrator.

This is your daily interface. For each phase, write a launch prompt:

Read these three files in order, then begin implementation:
1. socratic-roadmaps/00-SOCRATIC-METHODOLOGY.md
2. socratic-roadmaps/01-GAP-MAP.md
3. socratic-roadmaps/track-1/phase-1-name.md

Start by assessing [starting condition], then [work description].

End by verifying the safety gate.

Daily workflow: Open the Orchestrator. Find the next phase whose dependencies are checked off. Copy the launch prompt. Paste it into Claude Code. The agent reads three files, reasons through the questions, and implements. You review against the validation criteria. Check the box. Move to the next phase.

Parallel execution: The Orchestrator’s dependency diagram shows which tracks can run simultaneously. In my build, I run 3 to 4 Claude Code sessions in parallel from day one, covering security, communications, memory/quality, and platform infrastructure. Each session loads the same methodology and gap map but a different phase file.

When things go wrong: Don’t throw away a failed attempt. Start a new session with the same launch prompt plus a note: “Previous attempt produced X. The issue was Y. Reason through the same questions with this additional context.”

How to Implement This in Google Antigravity

Antigravity is Google’s agent-first IDE, and its architecture maps beautifully onto the Forge because it was literally designed for the same philosophy: you act as the architect while multiple agents execute in parallel.

Here’s what changes when you bring the Forge to Antigravity:

Use AGENTS.md instead of CLAUDE.md. Antigravity reads AGENTS.md in a similar way to how Jules reads specialized markdown files for project context. Place your behavioral contract and project identity here, and Antigravity’s agents will pick this up as persistent context.

Leverage the Manager View for parallel tracks. Where Claude Code requires you to manually open parallel terminal sessions, Antigravity’s Manager View (what they call “Mission Control”) is purpose-built for this. You can dispatch agents to different tracks and monitor them from a single dashboard. Each agent gets its own workspace. Assign one per track, and your Forge Orchestrator becomes the Mission Control equivalent in your documentation.

Map Agent Skills to the Methodology. Antigravity has a “Skills” system where you can codify reusable agent behaviors. Create a skill for the Socratic methodology itself, which means every agent you dispatch automatically inherits the behavioral contract without you loading the methodology file manually. You should also create skills for your common question types and your safety gate review process.

Use Artifacts for validation. Antigravity generates trust-building artifacts such as task plans, implementation records, and browser recordings. Map your phase validation criteria to artifacts. When an agent completes a phase, its artifacts become your review surface. This replaces the manual review step in the Claude Code workflow with something more visual and auditable.

Browser sub-agents for testing. Antigravity’s browser sub-agents can autonomously test UIs. In the Forge, you’d normally specify testing criteria in the safety gate. With Antigravity, you can have the agent execute those tests itself, capturing screenshots and interaction logs as proof.

The adaptation for Antigravity’s dispatch model: Your launch prompts change slightly. Instead of “read these three files,” you’re dispatching an agent with a workspace that already contains the methodology (via Skills), the gap map, and the phase file. The prompt becomes: “Execute the Socratic inquiry in phase-1-name.md. Your methodology is loaded as a skill. Reference 01-GAP-MAP.md for codebase context. Begin implementation and produce artifacts at each validation checkpoint.”

How to Implement This in Replit

Replit’s Agent 3 occupies a different niche in the ecosystem. It’s not a CLI tool like Claude Code or a multi-agent IDE like Antigravity. It’s a browser-native autonomous builder that operates for up to 200 minutes continuously with self-testing loops. The Forge adapts to this by leaning into Replit’s strengths: speed, autonomy, and built-in infrastructure.

Here’s how the Forge adapts to Replit’s model:

Use replit.md as your project identity file. Replit’s RulesSync feature (released in the 2026 update) synchronizes AI agent configurations across projects. Your replit.md becomes the equivalent of CLAUDE.md, establishing the behavioral contract, project identity, and coding standards.

Front-load context into the Agent prompt. Replit’s Agent operates from a single prompt rather than loading files. This means you need to adapt the three-file pattern. Instead of pointing to files, you paste the essential context directly into your Agent prompt. I recommend including the six question types as a preamble (abbreviated to roughly 30 lines), a condensed gap map (what exists and what doesn’t), and then the full phase inquiry. Keep total prompt length under 400 lines.
Let the self-testing loop handle your safety gate. Replit Agent 3’s autonomous testing system clicks through your app like a real user, captures logs, and fixes what it finds. This maps directly onto the Forge’s safety gate concept. In your phase prompt, specify your validation criteria as testable assertions: “The system should reject package names with character substitutions. The sandbox should prevent filesystem access outside the temp directory. The consent flow should complete in under 3 seconds.” Agent 3 will verify these during its self-testing passes.

Use “Autonomy Level” strategically. Replit’s autonomy controls let you dial agent independence up or down. For initial Forge phases where you are laying foundations and establishing patterns, use low autonomy so you can review how the agent interprets your Socratic questions. As the codebase matures and patterns are established, increase autonomy for later phases. This mirrors the trust-building arc of the Forge itself.

Combine Design Mode with the Paintbrush. Replit’s Design Mode creates interactive designs in under two minutes. Use the original Socratic Paintbrush technique here by asking open-ended questions about user flows, information hierarchy, and interaction patterns before letting Design Mode generate. Then use Agent 3 with the full Forge methodology for the implementation phases.

The adaptation for Replit’s session model: Claude Code sessions are short and focused, covering one phase per session, while Replit Agent 3 can run for 200 minutes. You can batch 2 to 3 adjacent phases from the same track into a single Agent session, provided they’re sequential and the total scope stays manageable. Include all relevant phase inquiries in a single prompt, separated by clear headers.

The Anti-Patterns: What Will Break Your Forge

I learned these the hard way over the course of building Agent Friday, and I’m sharing them so you don’t have to repeat my mistakes.

The Instruction Disguised as a Question. “Given that we need a Redis cache here, what key schema should we use?” is not a Socratic question because you’ve already decided on Redis. A better version is: “This data is read 100x more than it’s written. What caching strategies exist, and what properties of this data should drive the choice?”

The Kitchen Sink Phase. If your phase file is over 200 lines, it’s trying to do too much. Split it into multiple phases. Each phase should be a single coherent unit that an agent can complete in one session.

The Stale Gap Map. If the gap map says “no tests exist” but three phases of tests have been completed, every subsequent agent is working from false assumptions. Update your Gap Map after every completed phase, because this is not optional.

Overloading Context. Never load more than 3 to 4 files into a session. If the agent needs background on another track, write a brief summary into the phase file rather than loading the entire track overview. Context is a budget, not a buffet.

Skipping the Safety Gate. It’s tempting when you’re in a hurry, but don’t do it, because safety issues compound across phases and a shortcut in Phase 2 becomes a structural flaw in Phase 8.

Scaling: From Weekend Project to Enterprise Platform

The Forge scales in both directions, from a weekend hack to a months-long enterprise platform build.

A weekend side project might use 1 to 2 tracks with 3 to 5 phases each, where the methodology file can be shorter, the gap map can be a simple file list, and you don’t need an orchestrator at all because you can just work through phases in order. Even at this scale, the six question types produce dramatically better results than jumping straight to code.

An enterprise platform (which is what I built) uses 9 tracks, 28 phases, 8 sprints, and 9 agent teams working in parallel, at which point the Orchestrator becomes a living project management document, the gap map needs regular updates, and cross-cutting roles emerge such as a safety auditor reviewing every phase, a test architect designing integration tests, and an orchestrator managing dependencies at interface boundaries.

The method adapts because the depth of your inquiry adapts. A weekend project gets one Boundary question and one cLaw Gate per phase. An enterprise build gets the full six-type treatment with inversions, precedents, tensions, and multi-layered validation criteria.

Why This Works Better Than Anything Else I’ve Tried

Most agentic coding sessions in 2026 still start with something like: “Build me a project management app with user authentication, task tracking, and a dashboard.” That’s an instruction, not a plan. The AI will produce something that looks right but is riddled with assumptions you didn’t authorize, missing features you didn’t specify, and architectural decisions that will cost you hours of refactoring.

The Socratic Forge front-loads all of that cognitive work into the planning phase, where it’s cheap, because changing a plan costs nothing while changing code costs time, frustration, and context. By the time you start building, every decision has been made, every dependency mapped, and every edge case considered.
But the Forge adds something the Paintbrush didn’t have: the system layer. Where the Paintbrush could plan a great building, the Forge can run the construction site, providing parallel execution, dependency management, safety verification at every phase, codebase grounding that persists across sessions, and an orchestration layer that turns months of work into a daily checklist.

The Socratic method is 2,400 years old, and I’m using it to coordinate fleets of AI agents building software that didn’t exist last week.

Get Started Today

The Forge is open source. You can find the complete implementation, including the methodology, gap map, templates, worked examples, and platform-specific guides, in the Socratic Forge repository on GitHub. You can also find the real-world implementation that inspired it, covering 9 tracks, 28 phases, and the orchestrator, in the Agent Friday repository. Fork them, adapt them, and use them as templates for your own builds.

Or do what I suggested with the Paintbrush: paste this essay directly into Claude, Antigravity, or Replit, give it access to your repo, ask it how to build a Socratic Forge tailored to your specific project, and then start forging.

If you try this, drop your results in the comments, because I’ll be active there and I want to see what you build. And if you improve on the method, which I expect many of you will, I especially want to hear about it.

The unexamined code is not worth shipping.
------

About the author: Stephen C. Webster is Senior Director of Integrated Intelligence at Aquent Studios, the largest creative marketing agency in North America, where he leads AI transformation for Fortune 500 clients. He previously trained frontier AI models for Google, Meta, and Amazon, and spent over 20 years as a journalist. He believes the toughest challenges in AI transformation initiatives are not technological but organizational.
Disclaimer: The opinions and positions expressed in Stephen C. Webster’s LinkedIn essays (all of them) are personal and do not represent the opinions or positions of Aquent or Aquent Studios.
