---
issue: 16
title: Implement batch commit grouping by related steps in dev-implement
branch: feature/16-batch-commit-grouping
status: pending
---

# Implementation Doc — Issue #16

## Progress

| Step | Description                                                          | Status  |
|------|----------------------------------------------------------------------|---------|
| 1    | Amend rationalization row at line 64 with batch carve-out            | done    |
| 2    | Expand G-06 batch bullet at line 326 with full semantics             | done    |
| 3    | Insert BATCH BROKEN banner after MODE SWITCH banner in Step 7f       | done    |
| 4    | Verify internal consistency (6 grep assertions)                      | done    |
| 5    | Commit changes                                                       | done    |

---

## Step 1 — Amend rationalization row at line 64 with batch carve-out

**File:** `.claude/skills/dev-implement/SKILL.md`
**Location:** Line 64 (inside the `## RATIONALIZATION PREVENTION` table)
**Tool:** `Edit`

**Current text (exact `old_string`):**
```
| "I'll commit these steps together" | Atomic commits aid debugging and revert; batching hides which step broke | One commit per step |
```

**Replace with (exact `new_string`):**
```
| "I'll commit these steps together" | Atomic commits aid debugging and revert; batching hides which step broke | One commit per step — unless `commit_mode = batch`, in which case G-06's batch grouping logic is authoritative |
```

**Expected outcome:** Rationalization row preserves structural rule for per-step and auto-commit modes; explicit batch mode (selected via AskUserQuestion in Step 2) is exempt. The carve-out is narrow — requires the literal string `batch` from a 3-value constrained prompt, not an ad-hoc agent decision. SRS §6.2 "not overridable by the agent" still holds.

---

## Step 2 — Expand G-06 batch bullet at line 326 with full semantics

**File:** `.claude/skills/dev-implement/SKILL.md`
**Location:** Line 326 (inside `### 7f — Step Summary + Gate`, the G-06 block)
**Tool:** `Edit`

**Current text (exact `old_string`):**
```
- **`batch`** → defer to batch grouping logic (logic in #16); unchanged.
```

**Replace with (exact `new_string`):**
```
- **`batch`** → group steps by logical concern and commit at group boundaries rather than per step. Semantics:
  - **Group-key computation**: for each step, `group_key = step.group_metadata` if a `**Group:** <slug>` header is present on the step, else the first 2 path segments of the step's primary file (the first-listed file in its "Files" / modified-files section).
  - **Group boundaries**: a group closes when the next step's `group_key` differs, or the implementation reaches its final step.
  - **Group pass path**: on group close, if every member step's 7c (code review), 7d (build + lint), and 7d.1 (verification gate) all PASS, commit the whole group using 7g with the batch commit message format below. No approval prompt.
  - **Group fail path**: if any member step FAILs (build, lint, code review, verification gate, or pre-commit hook), the group is **not committed**. Display the BATCH BROKEN banner below, flip `commit_mode` from `batch` to `per-step` for the remainder of the session, then fall through to per-step G-06 for the failing step once the developer has fixed the issue and re-run the relevant gates. Uncommitted changes from earlier group-members remain on disk and are handled via per-step G-06 from that point forward — the developer decides per commit what to include. Once flipped, `commit_mode` stays `per-step` for every subsequent step in this session — it does not flip back.
  - **Edge case — size-1 groups**: when a step's `group_key` differs from both neighbors, its group has size 1; it still commits silently in batch mode (no approval prompt). Mode remains `batch`.
  - **`--no-verify` forbidden**: batch commits use the same `git commit` invocation as per-step (see 7g safeguard). Pre-commit hook failure → BATCH BROKEN banner with reason `hook`.
  - **Batch commit message format** (deferred in actual invocation to 7g):
    ```
    <type>(<scope>): <group-name> — <N> steps

    - Step <N1>: <description>
    - Step <N2>: <description>
    …

    Refs #<issue-number>
    ```
    Subject: max 72 chars, imperative mood. `<type>` selected per 7g's commit-type table based on the group's dominant change kind.
```

**Expected outcome:** G-06 batch bullet describes full semantics — group-key computation, boundary, pass/fail paths, size-1 edge case, hook prohibition, and commit message format. Placeholder `(logic in #16)` is removed.

---

## Step 3 — Insert BATCH BROKEN banner after MODE SWITCH banner in Step 7f

**File:** `.claude/skills/dev-implement/SKILL.md`
**Location:** Between the closing fence of the MODE SWITCH banner block and `### 7g — Commit`
**Tool:** `Edit`

**Current text (exact `old_string`):**
```
All remaining steps will use per-step approval.
────────────────────────────────────────
```

### 7g — Commit
```

**Replace with (exact `new_string`):**
```
All remaining steps will use per-step approval.
────────────────────────────────────────
```

BATCH BROKEN banner (displayed on `batch` fail path, immediately before per-step G-06 re-engages):

```
────────────────────────────────────────
BATCH BROKEN: batch → per-step
Reason: <build | lint | review | gate | hook> failed on step <N> (group <G>)
Group <G> not committed. All remaining steps will use per-step approval.
────────────────────────────────────────
```

### 7g — Commit
```

**Expected outcome:** New banner block placed immediately after the existing MODE SWITCH banner code fence and before the `### 7g — Commit` heading. Post-edit `grep -c "BATCH BROKEN"` returns exactly `2` (one line `BATCH BROKEN banner (displayed…)` and one line `BATCH BROKEN: batch → per-step`).

---

## Step 4 — Verify internal consistency (6 grep assertions)

**Tool:** `Grep` + `Bash`

Run each check and confirm the expected count. Capture the output for the verification gate.

1. **No orphan placeholder `(logic in #16)`:**
   ```bash
   grep -n "logic in #16" .claude/skills/dev-implement/SKILL.md
   ```
   **Expected output:** empty (zero matches).

2. **BATCH BROKEN appears exactly twice:**
   ```bash
   grep -c "BATCH BROKEN" .claude/skills/dev-implement/SKILL.md
   ```
   **Expected output:** `2`.

3. **MODE SWITCH counts from #15 are preserved (sanity check — unchanged by this issue):**
   ```bash
   grep -c "MODE SWITCH" .claude/skills/dev-implement/SKILL.md
   ```
   **Expected output:** the same number as before Step 2's edit (recorded at the start of the session — should be `4` per the #15 deviation note: 3 prose references in 7f + 1 in 7g). If this count changes, an edit landed in the wrong place.

4. **`no-verify` count from #15 is preserved (sanity check):**
   ```bash
   grep -c "no-verify" .claude/skills/dev-implement/SKILL.md
   ```
   **Expected output:** `1` (the existing 7g safeguard paragraph).

5. **`commit_mode = batch` referenced in both carve-out and G-06:**
   ```bash
   grep -n "commit_mode = batch" .claude/skills/dev-implement/SKILL.md
   ```
   **Expected output:** at least 2 lines — one in the rationalization row (line ~64) and one in the G-06 group-fail-path prose (line ~326+). Note: the `commit_mode` variable token itself is referenced elsewhere too, but the exact `commit_mode = batch` string should hit at least 2.

6. **Rationalization row contains the carve-out phrase:**
   ```bash
   grep -n "I'll commit these steps together" .claude/skills/dev-implement/SKILL.md
   ```
   **Expected output:** exactly 1 match on a line that also contains the substring `unless` and `batch grouping logic is authoritative`. Visually inspect the full line to confirm the carve-out is present.

**Expected outcome:** All six grep assertions match the stated counts/patterns. Any mismatch → restart Step 1, 2, or 3 edits depending on which assertion failed.

---

## Step 5 — Commit changes

**Commands:**
```bash
git add .claude/skills/dev-implement/SKILL.md
git commit -m "feat(dev-implement): implement batch commit grouping by related steps

Expand G-06 batch bullet at Step 7f with full batch semantics: group-key
computation (explicit **Group:** metadata or file-prefix), group
boundaries, group pass/fail paths, size-1 edge case, and batch commit
message format. Add BATCH BROKEN banner alongside the MODE SWITCH banner.
Amend rationalization row with narrow commit_mode = batch carve-out.

Refs #16"
```

**Expected outcome:** Single clean commit containing only `.claude/skills/dev-implement/SKILL.md`. The plan and implementation doc under `docs/plans/issue-16/` are committed separately by `/paadhai:dev-plan` (its Step 16), not by this step.

> Note: if `dev-implement` runs this doc in per-step mode, Steps 1–4 may commit individually; in that case this Step 5 becomes a summary/no-op. Document any deviation under the "Deviations" section below.

---

## Deviations

- **Step 4 grep #2 (BATCH BROKEN count)**: Plan predicted exactly 2 matches (banner intro + banner literal). Actual = 4. Two extra matches come from the G-06 batch bullet prose added in Step 2 — line 330 (Group fail path bullet names "BATCH BROKEN banner") and line 332 (`--no-verify` forbidden bullet names "BATCH BROKEN banner with reason `hook`"). The semantically meaningful uniqueness check — `grep -c "BATCH BROKEN: batch → per-step"` — returns exactly 1 as intended. Same class of deviation as #15's MODE SWITCH count note. Gate PASSES on intent.
- **Step 4 grep #4 (`no-verify` count preserved)**: Plan predicted 1 match (the existing 7g safeguard from #15). Actual = 2. The new match at line 332 is inside the G-06 batch bullet's `--no-verify forbidden` sub-point, which is required by the issue scope — batch-mode must state its own `--no-verify` contract alongside the 7g safeguard. Spirit of check (prohibition is explicit and not duplicated/contradicted) holds. Gate PASSES on intent.
- **Step 4 grep #5 (`commit_mode = batch` ≥2)**: Plan predicted ≥2 matches (rationalization row + G-06 prose). Actual = 1 (rationalization row only). The G-06 batch bullet keys the branch via the bullet header `- **\`batch\`** →` rather than restating `commit_mode = batch` as an equality check; state transitions are phrased as `commit_mode from batch to per-step` (fail path). The critical SRS §6.2 structural-rule reference to the literal `commit_mode = batch` value lives in the rationalization-row carve-out where it is load-bearing. Spirit of check (narrow carve-out wired to the AskUserQuestion-constrained value) holds. Gate PASSES on intent.
- **Step 5 (commit cadence)**: Implementation ran in `auto-commit` mode, so Steps 1–3 each produced their own commit as they passed the verification gate. Step 4 committed separately with this deviations note. Step 5's "single bundling commit" therefore becomes a summary/no-op. Consistent with the note under Step 5 in this implementation doc.
