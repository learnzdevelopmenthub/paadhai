---
issue: 14
title: Add commit mode selection prompt to dev-implement
branch: feature/14-commit-mode-selection-prompt
status: pending
---

## Progress

| Step | Description | Status |
|------|-------------|--------|
| 1 | Replace binary auto-commit question with commit mode prompt | done |
| 2 | Update G-06 gate wording | done |
| 3 | Update skill description lines | done |
| 4 | Verify internal consistency | done |
| 5 | Commit changes | pending |

---

## Step 1 — Replace binary auto-commit question with commit mode prompt

**File:** `.claude/skills/dev-implement/SKILL.md`
**Location:** Lines 185–187 (inside STEP 2 — Load Implementation Doc)

**Current text (exact):**
```
Ask user:
- Model preference? (fast / smart / auto)
- Auto-commit after each step? (yes / no)
```

**Replace with:**
```
Ask user:
- Model preference? (fast / smart / auto)

Present commit mode selection using AskUserQuestion:

**Prompt text:** "Implementation has <total step count> steps. How would you like to handle commits?"

**Options:**
| Label | Description |
|-------|-------------|
| Per-step (Recommended) | Approve each commit individually (current behavior) |
| Auto-commit | Commit automatically after each passing step |
| Batch | Commit at natural checkpoints (after related groups) |

Store the selection as `commit_mode` (`per-step` | `auto-commit` | `batch`) for use by G-06 and downstream commit logic.

The total step count is derived from the implementation doc's progress table (count of rows excluding the header).
```

**Expected outcome:** After loading the implementation doc, `dev-implement` presents a 3-option commit mode selection with the step count, instead of a binary yes/no.

---

## Step 2 — Update G-06 gate wording

**File:** `.claude/skills/dev-implement/SKILL.md`
**Location:** Line 307 (inside Step 7f — Step Summary + Gate)

**Current text (exact):**
```
**G-06**: If auto-commit = yes → commit automatically. If no → wait for "yes".
```

**Replace with:**
```
**G-06**: If `commit_mode = per-step` → wait for user approval before committing. If `commit_mode = auto-commit` → commit automatically (logic in #15). If `commit_mode = batch` → defer to batch grouping logic (logic in #16).
```

**Expected outcome:** G-06 references the 3-state `commit_mode` variable, keeping the doc internally consistent with the new prompt.

---

## Step 3 — Update skill description lines

**File:** `.claude/skills/dev-implement/SKILL.md`

The following lines reference "auto-commit" in the skill description. These are informational and should be updated to reflect the new commit mode selection:

**Line 3 — current text (exact):**
```
description: Use when implementing confirmed plans — execute steps with code review, auto-commit, and subagent delegation for independent tasks
```

**Replace with:**
```
description: Use when implementing confirmed plans — execute steps with code review, commit mode selection, and subagent delegation for independent tasks
```

**Line 8 — current text (exact):**
```
Execute the implementation doc step-by-step with code review, auto-commit, and optional subagent delegation.
```

**Replace with:**
```
Execute the implementation doc step-by-step with code review, commit mode selection, and optional subagent delegation.
```

**Expected outcome:** Skill description reflects the new 3-option commit mode instead of "auto-commit".

---

## Step 4 — Verify internal consistency

**Commands:**
```bash
grep -n "auto-commit" .claude/skills/dev-implement/SKILL.md
grep -n "Auto-commit" .claude/skills/dev-implement/SKILL.md
```

**Expected outcome — allowed references (4 total):**

| Line (approx) | Context | Why it's OK |
|----------------|---------|-------------|
| ~40 (new prompt) | "Auto-commit" option label | New commit mode prompt option |
| ~40 (new prompt) | `commit_mode = auto-commit` | Variable value in prompt description |
| ~64 | Rationalization table: "I'll commit these steps together" | Deferred to #16 — do not modify |
| ~307 (new G-06) | `commit_mode = auto-commit` | G-06 gate condition |

**Forbidden references (must be zero):**
- `auto-commit = yes`
- `auto-commit = no`
- `Auto-commit after each step? (yes / no)`

If any forbidden reference is found, identify the exact line and text and replace it.

**Expected outcome:** Zero forbidden references. All remaining "auto-commit" occurrences are in the allowed list above.

---

## Step 5 — Commit changes

**Commands:**
```bash
git add .claude/skills/dev-implement/SKILL.md
git commit -m "feat(dev-implement): replace binary auto-commit with 3-option commit mode prompt

Add commit mode selection (per-step, auto-commit, batch) with step count
to STEP 2 of dev-implement. Update G-06 gate to reference commit_mode
variable. Update skill description lines.

Refs #14"
```

**Expected outcome:** Clean commit with only `.claude/skills/dev-implement/SKILL.md` changed.

---

## Deviations

- **Commit cadence**: Implementation committed per-step (auto-commit mode selected by user) instead of a single final commit at Step 5. The doc's Step 5 commit block therefore became a summary/no-op rather than a grouping commit.
- **Allowed reference count**: The doc predicted 4 allowed `auto-commit` references post-edit; actual grep found 3. The 4th row in the doc's table ("I'll commit these steps together") is wording in the rationalization table that does not contain the literal `auto-commit` substring, so it does not show up in a grep for that term. Left unmodified as the doc instructed.
