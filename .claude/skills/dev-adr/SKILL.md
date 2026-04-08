---
name: dev-adr
description: Use when recording an architectural decision — capture context, alternatives, rationale, and consequences in a structured ADR
---

# dev-adr: Architecture Decision Records

Record architectural decisions with context, alternatives considered, rationale, and consequences.

**Output:** `docs/adr/ADR-<n>-<kebab-title>.md`

---

## PREAMBLE — Announcement Banner

[SHELL] Detect context:
```bash
BRANCH=$(git branch --show-current)
```

If branch matches `feature/*` or `fix/*`:
- Extract issue number from branch name (e.g., `feature/42-add-login` → `42`)
- [SHELL] Fetch issue title:
```bash
gh api repos/{config.repo.owner}/{config.repo.name}/issues/<number> --jq '.title'
```

Display (with issue context):
```
────────────────────────────────────────
dev-adr | Issue #<number> — <title>
10 steps | Branch: <branch>
────────────────────────────────────────
```

Display (no issue context — not on feature/fix branch):
```
────────────────────────────────────────
dev-adr
10 steps | Branch: <branch>
────────────────────────────────────────
```

If `gh api` fails, degrade gracefully — show banner without issue title.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Store:
- `{config.repo.owner}` / `{config.repo.name}`

---

## STEP 2 — Determine ADR Number

[SHELL] Scan existing ADRs to find the next number:
```bash
ls docs/adr/ADR-*.md 2>/dev/null | sort | tail -1
```

Next ADR number = highest existing number + 1. If no ADRs exist → start at ADR-001.

[SHELL] Ensure docs/adr directory exists:
```bash
mkdir -p docs/adr
```

Display:
```
ADR Number : ADR-<n>
Directory  : docs/adr/
```

---

## STEP 3 — Gather Context

**If invoked from `/paadhai:dev-plan`** (decision context was passed):
- Use the architectural decision context provided by dev-plan
- Skip asking — proceed directly to Step 4

**If invoked standalone:**

Ask user:
1. "What is the architectural decision being made? (one sentence)"
2. "What problem or need is driving this decision?"
3. "What alternatives were considered? (comma-separated)"
4. "What was the final decision and why?"
5. "What GitHub issue does this relate to? (or 'none')"

---

## STEP 4 — Read Relevant Code

[DELEGATE][FAST-MODEL] Read files relevant to the decision context:
- Files implementing the chosen approach (if already decided)
- Files that will be affected by this decision
- Any existing ADRs for context and consistency

---

## STEP 5 — Generate ADR

Build ADR content:

```markdown
# ADR-<n>: <Title>

**Status:** Accepted
**Date:** <YYYY-MM-DD>
**Issue:** #<issue-number> (or N/A)

## Context

<What is the situation that forces this decision? What problem are we solving?
Include relevant constraints, requirements, and background.>

## Decision

<What was decided? State it clearly and directly.>

## Alternatives Considered

### Option 1: <name>
**Description:** <brief description>
**Pros:**
- <pro>
**Cons:**
- <con>

### Option 2: <name>
**Description:** <brief description>
**Pros:**
- <pro>
**Cons:**
- <con>

### Option 3 (chosen): <name>
**Description:** <brief description>
**Pros:**
- <pro>
**Cons:**
- <con>

## Rationale

<Why was this option chosen over the alternatives? What were the decisive factors?>

## Consequences

**Positive:**
- <benefit>

**Negative / Trade-offs:**
- <cost or limitation>

**Risks:**
- <risk and mitigation>
```

---

## STEP 6 — Present ADR

Show the full generated ADR.

**G-21: "Save this ADR? (yes / edit)"**

- **yes** → proceed to Step 7
- **edit** → take feedback, regenerate, re-present (repeat Step 6)

---

## STEP 7 — Revision Loop

Apply requested changes and re-present until user approves.

---

## STEP 8 — Save ADR

Derive kebab-case filename from the decision title (e.g., "Use PostgreSQL for persistence" → `use-postgresql-for-persistence`).

[WRITE] `docs/adr/ADR-<n>-<kebab-title>.md` with the approved content.

---

## STEP 9 — Commit

[SHELL] Commit the ADR:
```bash
git add docs/adr/ADR-<n>-<kebab-title>.md
git commit -m "docs(adr): ADR-<n> <title>

<one-line rationale summary>

Refs #<issue-number>"
```

---

## STEP 10 — Handoff

**If invoked from `/paadhai:dev-plan`:**
```
ADR recorded. Returning to planning flow.

ADR     : docs/adr/ADR-<n>-<kebab-title>.md
Status  : Accepted
Next    : Run /dev-test to create the test plan and stubs.
```

**If invoked standalone:**
```
ADR recorded.

ADR     : docs/adr/ADR-<n>-<kebab-title>.md
Status  : Accepted

This is a standalone utility — no pipeline next step.
```
