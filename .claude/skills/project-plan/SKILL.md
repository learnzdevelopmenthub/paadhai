---
name: project-plan
description: Use when defining requirements — transform a product idea into a confirmed SRS document
---

# project-plan: SRS Generation

Transform a product idea into a confirmed Software Requirements Specification document.

**Output:** `docs/srs.md`

---

## STEP 1 — Load Config

[READ] `.devflow.json` — hard stop if missing:

> No `.devflow.json` found. Run `/project-init` first.

---

## STEP 2 — Read Existing Context

[READ] any existing docs in `docs/` or source files if project has code already. Understand current state before asking questions.

---

## STEP 3 — Product Description

Ask the user to describe the product or feature set in free-form. Single input round.

> "Describe what you want to build. Include the problem it solves, who uses it, and any key features you have in mind."

---

## STEP 4 — Clarifying Questions

Ask all questions at once — single input round:

1. Who are the primary users? What roles do they have?
2. What is the single most important problem this product solves?
3. What is explicitly OUT of scope (non-goals)?
4. Any technology preferences or constraints (language, hosting, database)?
5. What is the target timeline or milestone structure?
6. Any known technical risks or unknowns?
7. Any compliance, security, or performance requirements?
8. Are there existing systems this must integrate with?

---

## STEP 5 — Research

[DELEGATE][FAST-MODEL][SEARCH] Validate tech stack choices from Step 4:
- Check current stable versions of proposed frameworks/libraries
- Verify compatibility between components
- Check for known issues with the proposed combination

---

## STEP 6 — Generate SRS

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

---

## STEP 7 — Present SRS

Show the full SRS document.

**G-02: "Approve this SRS? (yes / list changes)"**

Wait for explicit approval.

---

## STEP 8 — Revision Loop

- **Approved** → proceed to Step 9
- **Changes requested** → apply changes → re-present full SRS → repeat G-02

---

## STEP 9 — Save

[WRITE] Save SRS to `docs/srs.md`.

[SHELL] Commit:
```bash
git add docs/srs.md
git commit -m "docs(srs): add confirmed SRS

Refs: product description confirmed by user."
```

---

## STEP 10 — Handoff

```
SRS saved to docs/srs.md.
Next step: run /release-plan to create your GitHub project milestones and issues.
```
