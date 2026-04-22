---
issue: 15
title: Implement auto-commit logic with failure revert in dev-implement
branch: feature/15-auto-commit-failure-revert
status: pending
---

# Implementation Doc — Issue #15

## Progress

| Step | Description                                                  | Status  |
|------|--------------------------------------------------------------|---------|
| 1    | Expand G-06 prose at Step 7f with full auto-commit semantics | done    |
| 2    | Add `--no-verify` safeguard paragraph at end of Step 7g      | done    |
| 3    | Verify internal consistency (grep assertions)                | pending |
| 4    | Commit changes                                               | pending |

---

## Step 1 — Expand G-06 prose at Step 7f with full auto-commit semantics

**File:** `.claude/skills/dev-implement/SKILL.md`
**Location:** Line 321 (inside `### 7f — Step Summary + Gate`)
**Tool:** `Edit`

**Current text (exact `old_string`):**
```
**G-06**: If `commit_mode = per-step` → wait for user approval before committing. If `commit_mode = auto-commit` → commit automatically (logic in #15). If `commit_mode = batch` → defer to batch grouping logic (logic in #16).
```

**Replace with (exact `new_string`):**
```
**G-06** branches on `commit_mode`:

- **`per-step`** → wait for explicit user approval before committing (unchanged).
- **`auto-commit` — pass path** → if build (7d), lint (7d), code review (7c), and verification gate (7d.1) all PASS, commit automatically using 7g with no approval prompt. Unconfigured check commands (empty `{config.stack.build_cmd}` or `{config.stack.lint_cmd}`) are treated as non-blocking: the matching check is skipped, not failed.
- **`auto-commit` — fail path** → on any FAIL (build, lint, code review, or verification gate), do **not** commit. Flip `commit_mode` from `auto-commit` to `per-step` for the remainder of the session, display the MODE SWITCH banner below, then fall through to per-step G-06 for this failing step once the developer has fixed the issue and re-run the relevant gates. Once flipped, `commit_mode` stays `per-step` for every subsequent step in this session — it does not flip back.
- **`batch`** → defer to batch grouping logic (logic in #16); unchanged.

MODE SWITCH banner (displayed on `auto-commit` fail path, immediately before per-step G-06 re-engages):

```
────────────────────────────────────────
MODE SWITCH: auto-commit → per-step
Reason: <build | lint | review | gate> failed on step <N>
All remaining steps will use per-step approval.
────────────────────────────────────────
```
```

**Expected outcome:** G-06 section describes all 3 modes in bullet form; `(logic in #15)` placeholder removed; MODE SWITCH banner present verbatim.

---

## Step 2 — Add `--no-verify` safeguard paragraph at end of Step 7g

**File:** `.claude/skills/dev-implement/SKILL.md`
**Location:** Between line 345 (`Subject: max 72 chars, imperative mood ("add X" not "added X").`) and line 347 (`### 7h — Progress Dashboard`)
**Tool:** `Edit`

**Current text (exact `old_string`):**
```
Subject: max 72 chars, imperative mood ("add X" not "added X").

### 7h — Progress Dashboard
```

**Replace with (exact `new_string`):**
```
Subject: max 72 chars, imperative mood ("add X" not "added X").

Auto-commit uses the same `git commit` invocation as per-step — `--no-verify` is never used. If a pre-commit hook fails, treat it as a step failure: the commit aborts, the MODE SWITCH banner displays with reason `hook`, `commit_mode` flips to `per-step`, and G-06 re-engages for the failing step.

### 7h — Progress Dashboard
```

**Expected outcome:** New safeguard paragraph inserted as the final paragraph of 7g, immediately before the `### 7h` heading.

---

## Step 3 — Verify internal consistency

**Tool:** `Grep` + `Bash`

Run each grep and confirm the expected count. Capture the output for the verification gate.

1. **No orphan placeholder:**
   ```bash
   grep -n "logic in #15" .claude/skills/dev-implement/SKILL.md
   ```
   **Expected output:** empty (zero matches).

2. **MODE SWITCH banner present exactly once:**
   ```bash
   grep -cn "MODE SWITCH" .claude/skills/dev-implement/SKILL.md
   ```
   **Expected output:** `1` (single line).

3. **`--no-verify` safeguard present exactly once:**
   ```bash
   grep -cn "no-verify" .claude/skills/dev-implement/SKILL.md
   ```
   **Expected output:** `1` (single line).

4. **`commit_mode` still referenced in STEP 2 and 7f:**
   ```bash
   grep -n "commit_mode" .claude/skills/dev-implement/SKILL.md
   ```
   **Expected output:** at least four lines — one in STEP 2 (`Store the selection as ... commit_mode ...`), and three in the expanded G-06 block (per-step, auto-commit fail path mention, and the "it does not flip back" clause). No references outside STEP 2 or Step 7f.

5. **Placeholder "(logic in #16)" intentionally preserved:**
   ```bash
   grep -n "logic in #16" .claude/skills/dev-implement/SKILL.md
   ```
   **Expected output:** exactly `1` match (the batch mode line inside the expanded G-06). Issue #16 will remove it.

**Expected outcome:** All five greps match the stated counts. Any mismatch → restart Step 1 or Step 2 edits.

---

## Step 4 — Commit changes

**Commands:**
```bash
git add .claude/skills/dev-implement/SKILL.md
git commit -m "feat(dev-implement): implement auto-commit logic with failure revert

Expand G-06 at Step 7f with full auto-commit semantics: silent commit on
passing steps; revert to per-step mode with MODE SWITCH banner on any
build/lint/review/gate failure. Add --no-verify safeguard paragraph at
Step 7g.

Refs #15"
```

**Expected outcome:** Single clean commit containing only `.claude/skills/dev-implement/SKILL.md`. The plan and implementation doc under `docs/plans/issue-15/` are committed separately by `/paadhai:dev-plan` (its Step 16), not by this step.

> Note: if `dev-implement` runs this doc in per-step mode, Steps 1–3 may commit individually; in that case this Step 4 becomes a summary/no-op. Document any deviation under the "Deviations" section below.

---

## Deviations

(None yet — populated during execution.)
