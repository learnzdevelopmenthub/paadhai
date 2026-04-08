---
name: project-plan
description: Use when defining requirements — transform a product idea into a confirmed SRS document
---

# project-plan: SRS Generation

Transform a product idea into a confirmed Software Requirements Specification document.

**Output:** `docs/srs.md`

---

## PREAMBLE — Announcement Banner

[SHELL] Detect context:
```bash
BRANCH=$(git branch --show-current)
```

Display:
```
────────────────────────────────────────
project-plan
10 steps | Branch: <branch>
────────────────────────────────────────
```

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Derive SRS output path from config:
- If `project_version` exists → `{srs_path}` = `docs/srs-v{project_version}.md`
- If `project_version` absent → `{srs_path}` = `docs/srs.md`

### Progress Tracking

[PROGRESS] Initialize TodoWrite checklist — 10 items, all `pending`:
```
Step 1/10: Load Config
Step 2/10: Read Existing Context
Step 3/10: Product Description
Step 4/10: Clarifying Questions
Step 5/10: Research
Step 6/10: Generate SRS
Step 7/10: Present SRS
Step 8/10: Revision Loop
Step 9/10: Save
Step 10/10: Handoff
```
(Graceful degradation: skip if TodoWrite unavailable)

[PROGRESS] Mark Step 1/10 `completed`:
```
Step 1/10: Load Config [completed]
Files read: .paadhai.json
```

---

## STEP 2 — Read Existing Context

[PROGRESS] Mark Step 2/10 `in_progress`: `Step 2/10: Read Existing Context [in_progress]`

[READ] any existing docs in `docs/` or source files if project has code already. Understand current state before asking questions.

If `project_version` is set in config:
- [READ] Look for prior SRS files: glob `docs/srs-v*.md` and `docs/srs.md`
- If a prior SRS exists, load it as context and display:
  > Loaded prior SRS (`{prior_srs_filename}`) as reference for delta planning.
- Use the prior SRS to understand existing features, so the user can focus on what's new or changed in this version.

[PROGRESS] Mark Step 2/10 `completed`: `Step 2/10: Read Existing Context [completed]`
`Files read: <existing docs found>`

---

## STEP 3 — Product Description

[PROGRESS] Mark Step 3/10 `in_progress`: `Step 3/10: Product Description [in_progress]`

Ask the user to describe the product or feature set in free-form. Single input round.

> "Describe what you want to build. Include the problem it solves, who uses it, and any key features you have in mind."

[PROGRESS] Mark Step 3/10 `completed`: `Step 3/10: Product Description [completed]`
`Description received`

---

## STEP 4 — Clarifying Questions

[PROGRESS] Mark Step 4/10 `in_progress`: `Step 4/10: Clarifying Questions [in_progress]`

Ask all questions at once — single input round:

1. Who are the primary users? What roles do they have?
2. What is the single most important problem this product solves?
3. What is explicitly OUT of scope (non-goals)?
4. Any technology preferences or constraints (language, hosting, database)?
5. What is the target timeline or milestone structure?
6. Any known technical risks or unknowns?
7. Any compliance, security, or performance requirements?
8. Are there existing systems this must integrate with?

[PROGRESS] Mark Step 4/10 `completed`: `Step 4/10: Clarifying Questions [completed]`
`Answers received`

---

## STEP 5 — Research

[PROGRESS] Mark Step 5/10 `in_progress`: `Step 5/10: Research [in_progress]`

[DELEGATE][FAST-MODEL][SEARCH] Validate tech stack choices from Step 4:
- Check current stable versions of proposed frameworks/libraries
- Verify compatibility between components
- Check for known issues with the proposed combination

[PROGRESS] Mark Step 5/10 `completed`: `Step 5/10: Research [completed]`
`Research complete`

---

## STEP 6 — Generate SRS

[PROGRESS] Mark Step 6/10 `in_progress`: `Step 6/10: Generate SRS [in_progress]`

Use `templates/srs.md` as the base template. Fill in all sections:

- **Section 1**: Introduction (purpose, scope, problem statement, definitions, audience)
- **Section 2**: Overall Description (perspective, user roles, assumptions)
- **Section 3**: Functional Requirements (FR-1, FR-2, ... with description, priority, ACs)
- **Section 4**: Technical Stack (language, framework, database, hosting — with rationale)
- **Section 5**: Architecture Overview
- **Section 6**: Non-Functional Requirements (performance, security, reliability)
- **Section 7**: Constraints
- **Section 8**: Open Questions

**Quality rules:**
- Each functional requirement must have at least 2 acceptance criteria
- Acceptance criteria must be specific and testable
- No vague requirements ("should be fast" → "response time < 200ms under 100 concurrent users")

[PROGRESS] Mark Step 6/10 `completed`: `Step 6/10: Generate SRS [completed]`
`SRS generated`

---

## STEP 7 — Present SRS

[PROGRESS] Mark Step 7/10 `in_progress`: `Step 7/10: Present SRS [in_progress]`

Show the full SRS document.

**G-02: "Approve this SRS? (yes / list changes)"**

Wait for explicit approval.

[PROGRESS] Mark Step 7/10 `completed`: `Step 7/10: Present SRS [completed]`
`SRS presented`

---

## STEP 8 — Revision Loop

[PROGRESS] Mark Step 8/10 `in_progress`: `Step 8/10: Revision Loop [in_progress]`

- **Approved** → proceed to Step 9
- **Changes requested** → apply changes → re-present full SRS → repeat G-02

[PROGRESS] Mark Step 8/10 `completed`: `Step 8/10: Revision Loop [completed]`
`SRS approved`

---

## STEP 9 — Save

[PROGRESS] Mark Step 9/10 `in_progress`: `Step 9/10: Save [in_progress]`

[WRITE] Save SRS to `{srs_path}`.

[SHELL] Commit:
```bash
git add {srs_path}
git commit -m "docs(srs): add confirmed SRS for v{project_version}

Refs: product description confirmed by user."
```

> If no `project_version`, commit message omits the version suffix: `"docs(srs): add confirmed SRS"`.

[PROGRESS] Mark Step 9/10 `completed`: `Step 9/10: Save [completed]`
`Files changed: {srs_path}`

---

## STEP 10 — Handoff

[PROGRESS] Mark Step 10/10 `in_progress`: `Step 10/10: Handoff [in_progress]`

```
SRS saved to {srs_path}.
Next step: run /release-plan to create your GitHub project milestones and issues.
```

[PROGRESS] Mark Step 10/10 `completed`: `Step 10/10: Handoff [completed]`
`Output displayed`
