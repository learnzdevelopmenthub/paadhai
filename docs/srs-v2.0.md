# Software Requirements Specification
# Paadhai v2.0 — UX Enhancement Release

---

| Field       | Value              |
|-------------|--------------------|
| Document    | Software Requirements Specification (SRS) |
| Project     | Paadhai            |
| Version     | 2.0                |
| Status      | Draft              |
| Created     | 2026-04-08         |

---

## 1. Introduction

### 1.1 Purpose

This document specifies the requirements for Paadhai v2.0, a UX enhancement release that adds real-time progress visibility, friction reduction, and quality guards to the Paadhai skill framework for Claude Code.

### 1.2 Product Scope

Paadhai is a structured development workflow framework implemented as Claude Code skills. It provides 23 skills spanning the full development lifecycle — from project initialization to release management. v2.0 focuses on improving the **developer experience** during skill execution, specifically addressing the gap between Paadhai's strong workflow structure and its lack of real-time feedback during long-running operations.

### 1.3 Problem Statement

Paadhai v1.x provides comprehensive workflow automation but offers poor visibility during execution. Users experience:

1. **Blind spots** — During `dev-implement` runs (10–30 minutes), users see nothing between step summaries and cannot tell if the agent is reading, writing, or testing.
2. **Excessive interruptions** — The per-step commit gate (G-06) requires 12 approval prompts for a 12-step implementation.
3. **False completions** — Skills can declare success based on self-assessment without independent verification of acceptance criteria.

These problems erode trust and create unnecessary friction, particularly for experienced developers who want to monitor progress without micromanaging each step.

### 1.4 Definitions

| Term | Definition |
|------|-----------|
| Skill | A markdown-based instruction file in `.claude/skills/` that Claude Code executes as a structured workflow |
| Gate | A named approval checkpoint (G-01 through G-21) where execution pauses for user confirmation |
| TodoWrite | A Claude Code native tool that maintains a visible task checklist, updated in real time |
| Subagent | An isolated Claude Code agent spawned via the Agent tool to handle a delegated task |
| Rationalization | An agent's internally-generated justification for skipping a required step |

### 1.5 Intended Audience

Developers using Paadhai as their Claude Code skill framework for structured software development workflows.

---

## 2. Overall Description

### 2.1 Product Perspective

Paadhai v2.0 is an incremental enhancement to the existing v1.x skill framework. All changes are additive — no existing gates, skills, or workflows are removed. The release layers visibility and quality mechanisms onto the existing pipeline structure.


### 2.2 User Roles

| Role | Description |
|------|-------------|
| Developer | Primary user who invokes Paadhai skills via `/paadhai:<skill>` commands in Claude Code to plan, implement, test, and ship software |

### 2.3 Key Assumptions

- Developers are using Claude Code (CLI, VSCode extension, or web) as their development environment.
- The TodoWrite tool is available and functional across all Claude Code environments (CLI, VSCode, web).
- Subagent communication remains free-form text; structured status codes will be enforced via prompt conventions, not API-level contracts.
- Developers prefer visibility over silence during long-running operations.
- `.paadhai.json` remains the single source of project configuration.

---

## 3. Functional Requirements

### FR-01: Live Progress Tracking via TodoWrite

**Description:** Integrate the TodoWrite tool as the real-time progress mechanism across all multi-step skills. On skill start, extract all steps, create a TodoWrite checklist, and update item status as execution progresses.

**Priority:** High

**Affected skills:** `dev-implement`, `dev-parallel`, `dev-plan`, `project-plan`, `release-plan`, `dev-release`

**TodoWrite item format:**
```
Step 3/12: Implement auth middleware [in_progress]
Files: src/middleware/auth.ts, src/types/session.ts
Status: Writing code...
```

**Acceptance Criteria:**
- [ ] AC-1: Every multi-step skill (listed above) creates a TodoWrite list at the start of execution, with one item per step
- [ ] AC-2: The currently executing step is always marked `in_progress`; all prior steps are marked `completed`
- [ ] AC-3: Completed step items include files changed and build/lint result summary
- [ ] AC-4: User can see current progress state at any point during execution without scrolling through output
- [ ] AC-5: A new capability marker `[PROGRESS]` is added to `references/claude-tools.md` mapping to the TodoWrite tool

---

### FR-02: Skill Invocation Announcements

**Description:** Every skill displays a context banner on invocation, providing immediate orientation about what is running, which issue it relates to, and how many steps are involved.

**Priority:** Medium

**Banner format:**
```
────────────────────────────────────────
dev-implement | Issue #42 — Add login endpoint
Step 1 of 12 | Branch: feature/42-add-login
────────────────────────────────────────
```

**Acceptance Criteria:**
- [ ] AC-1: Every skill displays a context banner as its first output upon invocation
- [ ] AC-2: Banner includes the skill name and issue number (if applicable, read from context or `.paadhai-session.json`)
- [ ] AC-3: Banner includes current branch name (if on a feature/fix branch)
- [ ] AC-4: For multi-step skills, the banner includes the total step count
- [ ] AC-5: Banner uses a consistent visual format (box-drawing characters) across all skills

---

### FR-03: In-Session Progress Dashboard

**Description:** Display a compact aggregate progress dashboard after each step completion in multi-step skills, showing files touched, commits made, test results, and build status.

**Priority:** High

**Dashboard format:**
```
Progress: ████████░░░░ 8/12 steps (67%)
══════════════════════════════════════════
Files changed : 14 (6 created, 8 modified)
Commits       : 7
Tests         : 23 passing, 0 failing
Build         : passing
══════════════════════════════════════════
```

**Acceptance Criteria:**
- [ ] AC-1: Dashboard is displayed after each completed step in `dev-implement`
- [ ] AC-2: Dashboard shows: step progress (N/total with percentage), file statistics (created/modified count), commit count, test summary (passing/failing), and build status
- [ ] AC-3: Dashboard uses a text-based progress bar for visual indication
- [ ] AC-4: Dashboard is compact — maximum 6 lines excluding border characters
- [ ] AC-5: Dashboard data is derived from actual `git diff --stat`, test output, and build output — not from agent estimation

---

### FR-04: Batch Auto-Commit Gate

**Description:** Offer developers a choice of commit mode at the start of `dev-implement`, reducing the number of approval interruptions during long implementations.

**Priority:** High

**Commit mode prompt:**
```
Implementation has 12 steps. How would you like to handle commits?

1. Per-step   — approve each commit individually (current behavior)
2. Auto-commit — commit automatically after each passing step
3. Batch      — commit at natural checkpoints (after related groups)

Choice: _
```

**Acceptance Criteria:**
- [ ] AC-1: `dev-implement` presents the commit mode selection prompt after loading the implementation plan (before step execution begins)
- [ ] AC-2: **Per-step mode** preserves current G-06 behavior — user approves each commit individually
- [ ] AC-3: **Auto-commit mode** skips G-06 for steps where build and lint pass and code review raises no blocking issues; commits automatically with the standard message format
- [ ] AC-4: Auto-commit mode reverts to per-step mode if any step fails build, lint, or review — and notifies the user of the mode switch
- [ ] AC-5: **Batch mode** groups logically related steps (e.g., all steps touching the same module) and commits at group boundaries

---

### FR-05: Rationalization Prevention Guards

**Description:** Add explicit rationalization prevention tables to critical skills, listing common agent rationalizations for skipping steps with counters explaining why each is wrong.

**Priority:** Medium

**Example table:**
```markdown
| Thought | Why it's wrong | What to do |
|---------|---------------|------------|
| "This step is trivial, skip review" | Trivial changes cause subtle bugs | Run full review |
| "Tests aren't needed for this" | Every code change needs verification | Write or run tests |
| "I'll commit these together" | Atomic commits aid debugging | One commit per step |
| "The build will obviously pass" | Build failures catch real issues | Run the build |
| "I already know this works" | Verify, don't assume | Run the tests |
```

**Acceptance Criteria:**
- [ ] AC-1: Rationalization prevention tables are added to `dev-implement`, `dev-plan`, and `dev-parallel` skill files
- [ ] AC-2: Each table contains at least 5 common rationalizations with corresponding counters and required actions
- [ ] AC-3: Tables are placed before the main execution loop in each skill file (high visibility position)
- [ ] AC-4: Each rationalization entry includes three columns: the thought pattern, why it's wrong, and the correct action

---

### FR-06: Verification Gate Before Completion

**Description:** Add a mandatory 5-step verification gate that must be executed before any skill can declare a task complete. The gate requires the agent to identify claims, run verification commands, read actual output, verify against claims, and only then state completion with quoted evidence.

**Priority:** High

**Gate steps:**
```
Before declaring any task DONE:

1. IDENTIFY — What specific claims am I making? List each one.
2. RUN     — Execute the verification command (test, build, lint).
3. READ    — Read the ACTUAL output. Do not summarize from memory.
4. VERIFY  — Does the output confirm each claim? Check line by line.
5. CLAIM   — Only now state completion. Quote the evidence.
```

**Red flags triggering re-verification:**
- Hedging language: "should", "probably", "seems to", "I believe"
- No command output quoted in completion message
- Claims not supported by specific file/line references

**Acceptance Criteria:**
- [ ] AC-1: The 5-step verification gate is added to `dev-implement` (executed per-step before marking a step complete)
- [ ] AC-2: The verification gate is added to `dev-parallel` (executed per-subagent before accepting a subagent's result)
- [ ] AC-3: Completion messages must include quoted output from verification commands (test/build/lint results)
- [ ] AC-4: Hedging language ("should", "probably", "seems to", "I believe") in a completion message triggers automatic re-verification
- [ ] AC-5: The gate is documented as a reusable pattern in `references/claude-tools.md` so future skills can adopt it

---

## 4. Technical Stack

| Component | Choice | Rationale |
|-----------|--------|-----------|
| Language | Markdown + Bash | Paadhai skills are markdown instruction files with embedded shell commands. No runtime code to compile. |
| Framework | Claude Code Skills | Native Claude Code skill system (`.claude/skills/`). No external framework needed. |
| State management | `.paadhai.json` + TodoWrite | Project config in JSON; live progress via Claude Code's native TodoWrite tool. |
| Version control | Git + GitHub | Existing integration. GitHub Projects for board sync. |
| CI/CD | GitHub Actions (existing) | No changes to CI pipeline required for v2.0. |

---

## 5. Architecture Overview

Paadhai v2.0 remains a **markdown-based skill framework** with no compiled code. The architecture changes are purely in skill file content and conventions.

```
┌─────────────────────────────────────────────────┐
│                  Claude Code                     │
│                                                  │
│  ┌──────────────┐    ┌───────────────────────┐  │
│  │  Skill File   │───▶│  Execution Engine     │  │
│  │  (.md)        │    │  (Claude Code native) │  │
│  └──────────────┘    └───────┬───────────────┘  │
│                              │                   │
│         ┌────────────────────┼──────────────┐   │
│         ▼                    ▼              ▼   │
│  ┌─────────────┐  ┌──────────────┐  ┌────────┐ │
│  │  TodoWrite   │  │  Agent Tool   │  │  Bash  │ │
│  │  (Progress)  │  │  (Subagents)  │  │ (Shell)│ │
│  └─────────────┘  └──────────────┘  └────────┘ │
│                                                  │
│  ┌──────────────────────────────────────────┐   │
│  │  .paadhai.json — Project Configuration    │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

**v2.0 additions (highlighted):**
- **TodoWrite integration** — New `[PROGRESS]` marker mapped to TodoWrite tool for live step tracking
- **Announcement convention** — Skills output a context banner as their first action
- **Dashboard convention** — Skills output a compact stats block after each step
- **Verification gate** — Reusable 5-step verification pattern added to critical skills
- **Rationalization tables** — Markdown tables embedded in skill files before execution loops
- **Commit mode selection** — New gate in `dev-implement` for choosing commit behavior

---

## 6. Non-Functional Requirements

### 6.1 Performance

- Skill startup overhead from reading `.paadhai.json` and initializing TodoWrite must add less than 2 seconds to invocation time.
- Progress dashboard rendering (after each step) must complete within 1 second.
- Announcement banners must display before any other skill output.

### 6.2 Security

- No secrets, tokens, or credentials stored in `.paadhai.json` or any session state.
- Commit operations respect existing git hooks — auto-commit mode must not bypass pre-commit hooks (`--no-verify` is never used).
- Rationalization prevention guards must not be overridable by the agent; they are structural, not advisory.

### 6.3 Reliability

- TodoWrite failures must not block skill execution — if TodoWrite is unavailable, the skill continues without live progress (graceful degradation).
- Auto-commit mode must revert to per-step mode on any failure, ensuring no silent broken commits.
- Verification gate failures must block completion — no bypass mechanism.

---

## 7. Constraints

| Constraint | Detail |
|------------|--------|
| No compiled code | All features must be implementable as markdown skill file changes and shell commands. No new runtimes or build steps. |
| Backward compatibility | All changes are additive. No existing gates (G-01 through G-21) are removed or renumbered. |
| Claude Code native tools only | Features must use only tools available in Claude Code (TodoWrite, Agent, Bash, Read, Write, Edit, Grep, Glob). No external dependencies. |
| Cross-environment consistency | Features must work in Claude Code CLI, VSCode extension, and web environments. |
| Free-form subagent communication | Structured conventions (e.g., status codes in FR-06) are enforced via prompt instructions, not API contracts. |

---

## 8. Open Questions

| ID | Question | Status |
|----|----------|--------|
| Q-01 | Should the progress dashboard (FR-03) also be displayed in `dev-parallel` for each subagent group, or only in `dev-implement`? | Open |
| Q-02 | Should auto-commit mode (FR-04) be remembered across sessions via `.paadhai-session.json` (deferred F-09), or selected fresh each time? | Open |
| Q-03 | What is the maximum number of TodoWrite items before readability degrades? Should skills with >20 steps group sub-steps? | Open |
| Q-04 | Should the verification gate (FR-06) apply to `dev-plan` output (plan quality verification) or only to code-producing skills? | Open |

---

*End of SRS*
