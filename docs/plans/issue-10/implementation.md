---
issue: 10
title: Add per-step progress dashboard to dev-implement
branch: feature/10-per-step-progress-dashboard
steps: 2
---

# Implementation Doc — Issue #10

## Progress

| Step | Description | Status |
|------|-------------|--------|
| 1 | Add progress dashboard sub-step 7h to implementation loop | done |
| 2 | Verify SKILL.md is well-formed and all references are consistent | done |

---

## Step 1 — Add progress dashboard sub-step 7h to implementation loop

**Action:** Edit `.claude/skills/dev-implement/SKILL.md` to insert a new sub-step `7h — Progress Dashboard` after the existing `7g — Commit` block, and before the `[PROGRESS] Mark Step 7/10 completed` line.

**File:** `.claude/skills/dev-implement/SKILL.md`

**Find this exact text (old_string):**

```
Subject: max 72 chars, imperative mood ("add X" not "added X").

[PROGRESS] Mark Step 7/10 `completed`: `Step 7/10: Implementation Loop [completed]`
`Files changed: <list from step>  Build: ✓  Lint: ✓`
```

**Replace with (new_string):**

```
Subject: max 72 chars, imperative mood ("add X" not "added X").

### 7h — Progress Dashboard
After each step's commit, display a compact aggregate progress dashboard. Data MUST come from actual command output — never estimate or fabricate values.

[SHELL] Gather cumulative stats:
```bash
# Count commits on this branch since diverging from develop
COMMIT_COUNT=$(git rev-list {config.repo.develop_branch}..HEAD --count)

# Count created (A) and modified (M) files since diverging from develop
CREATED=$(git diff --name-status {config.repo.develop_branch}...HEAD | grep -c '^A')
MODIFIED=$(git diff --name-status {config.repo.develop_branch}...HEAD | grep -c '^M')
TOTAL_FILES=$((CREATED + MODIFIED))
```

Compute progress bar:
- Let `DONE` = number of implementation steps completed so far (including this one)
- Let `TOTAL` = total number of implementation steps
- Let `PCT` = `DONE * 100 / TOTAL`
- Filled chars = `DONE * 12 / TOTAL` (integer division), using `█`
- Empty chars = `12 - filled`, using `░`

Determine test and build status:
- **Build**: Use the result from the most recent 7d execution. If 7d was skipped for this step (no source files changed), use the last known build result. If no build has run yet, show `not yet run`.
- **Tests**: Use the result from the most recent `{config.stack.test_cmd}` execution (typically Step 8). If no test command has run yet, show `not yet run`.

Display:
```
Progress: ████████░░░░ <DONE>/<TOTAL> steps (<PCT>%)
══════════════════════════════════════════
Files changed : <TOTAL_FILES> (<CREATED> created, <MODIFIED> modified)
Commits       : <COMMIT_COUNT>
Tests         : <passing> passing, <failing> failing | not yet run
Build         : passing | failing | not yet run
══════════════════════════════════════════
```

**Constraints:**
- Maximum 6 lines excluding the `══` border lines (AC-4)
- Progress bar is always 12 characters wide (AC-3)
- All values derived from actual `git diff`, `git rev-list`, and command output — never from agent estimation (AC-5)

**Edge cases:**
- First step completed with no prior changes: show `0` for files/commits, `not yet run` for tests/build
- Step where build/lint was skipped (no source files): show last known build status
- Build or test failure: show `failing`, not `passing`

[PROGRESS] Mark Step 7/10 `completed`: `Step 7/10: Implementation Loop [completed]`
`Files changed: <list from step>  Build: ✓  Lint: ✓`
```

**Expected output:** The edit succeeds and the SKILL.md file now contains sub-step `7h — Progress Dashboard` between `7g — Commit` and the `[PROGRESS]` completion marker.

---

## Step 2 — Verify SKILL.md is well-formed and all references are consistent

**Action:** Read the modified `.claude/skills/dev-implement/SKILL.md` file end-to-end and verify:

1. Sub-steps in Step 7 are sequential: 7a, 7b, 7c, 7d, 7e, 7f, 7g, 7h
2. The `[PROGRESS]` marker for Step 7/10 still appears exactly once, after 7h
3. No broken markdown formatting (unclosed code blocks, mismatched headers)
4. The dashboard format matches the SRS FR-03 example exactly (6 content lines, `══` borders, 12-char progress bar)
5. All config references use `{config.repo.develop_branch}` — no hardcoded branch names

**Expected output:** All 5 checks pass. No further edits needed.

---

## Deviations

(none)
