---
name: dev-parallel
description: Use when executing independent implementation tasks in parallel — dispatch fresh subagents per task group with 2-stage review
---

# dev-parallel: Parallel Implementation

Dispatch independent implementation tasks to fresh subagents, review each for spec compliance and code quality, merge results.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/project-init` first.

Store:
- `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` / `{config.stack.test_cmd}`
- `{config.repo.owner}` / `{config.repo.name}`

---

## STEP 2 — Load Implementation Doc

[SHELL] Get current branch:
```bash
git branch --show-current
```

Derive issue number from branch name (e.g., `feature/42-add-login` → `#42`).

[READ] `docs/plans/issue-<n>/implementation.md` + `docs/plans/issue-<n>/plan.md`.

Display:
```
Issue     : #<number> <title>
Branch    : <branch-name>
Steps     : <total count>
Doc path  : docs/plans/issue-<n>/implementation.md
```

---

## STEP 3 — Group Independent Tasks

Scan implementation steps and build a dependency graph:
- **Sequential**: step B requires step A's output (shared file, import, or state)
- **Independent**: steps with no shared files or state

Group into task groups. Sequential steps within a group keep their order.

Display:
```
Task Groups
═══════════════════════════════════════
Group | Steps       | Files Touched          | Dependencies
──────┼─────────────┼────────────────────────┼─────────────
  1   | 1, 2        | src/auth.ts            | none
  2   | 3, 4, 5     | src/api.ts, src/db.ts  | none
  3   | 6           | src/auth.ts, src/api.ts | groups 1, 2
```

If no independent groups found (all sequential) → stop:
> All tasks are sequential. Use `/dev-implement` in sequential mode instead.

---

## STEP 4 — Generate Subagent Prompts

For each independent task group, build a prompt containing:

1. **Context**: Issue number, branch name, project config
2. **Implementation slice**: Only the steps assigned to this group (copied from implementation.md)
3. **Files to read**: List of files to `[READ]` before modifying
4. **Commit template**:
   ```
   <type>(<scope>): <subject>

   Refs #<issue-number>
   ```
5. **Rules**:
   - `[READ]` every file before modifying it
   - `git add <specific-files>` — never `git add -A`
   - Run `{config.stack.build_cmd}` and `{config.stack.lint_cmd}` after changes
   - Mark each step as `done` in implementation.md after completion
6. **Report format**: files changed, build status, lint status, commit SHA

Display all generated prompts to user for review.

---

## STEP 5 — Dispatch Gate

**G-11: "Dispatch <N> subagents for parallel implementation? (yes/no)"**

Wait for explicit "yes". Do not proceed without it.

---

## STEP 6 — Dispatch Subagents (after G-11)

[PARALLEL] Dispatch one `[DELEGATE][FAST-MODEL]` per independent task group.

Each subagent:
1. `[READ]` all files listed in the prompt before modifying
2. Implements the assigned steps exactly as described in implementation.md
3. Runs `{config.stack.build_cmd}` and `{config.stack.lint_cmd}`
4. Commits with proper message format:
   ```bash
   git add <specific-files-changed>
   git commit -m "<type>(<scope>): <subject>

   Refs #<issue-number>"
   ```
5. Reports: files changed, build status, lint status, commit SHA

Sequential groups (those depending on earlier groups) are dispatched only after their dependencies complete.

---

## STEP 7 — Collect Results

Wait for all subagents to complete.

Display per-group results:
```
Parallel Results
═══════════════════════════════════════
Group | Status  | Commit   | Files Changed
──────┼─────────┼──────────┼──────────────
  1   | success | a1b2c3d  | src/auth.ts
  2   | success | e4f5g6h  | src/api.ts, src/db.ts
  3   | FAILED  | —        | src/auth.ts (build error)
```

If any group failed:
- Display error details
- Ask user: "Fix manually and retry group <N>? (yes / skip / abort)"
- If retry → re-dispatch only that group
- If skip → mark those steps as `pending` in implementation.md
- If abort → stop

---

## STEP 8 — Stage 1: Spec Compliance Review

[DELEGATE][SMART-MODEL] Review ALL changes against implementation.md:

Check:
- Every assigned step marked `done`?
- Expected outputs match what was described?
- No missing steps or skipped work?
- Acceptance criteria from plan.md addressed?
- File paths match what was specified in implementation.md?

Report: **PASS** / **FAIL** with specific gaps listed.

---

## STEP 9 — Stage 2: Code Quality Review

[DELEGATE][SMART-MODEL] Review ALL changes for:

Check:
- Correctness (logic errors, off-by-one, null handling)
- Pattern alignment (new code follows existing codebase patterns)
- No introduced bugs or security issues
- No duplicate code across subagent outputs
- No merge conflicts between groups (overlapping file edits)
- Import/export consistency across files touched by different groups

Report: **PASS** / **FAIL** with specific issues listed.

---

## STEP 10 — Fix Loop

If either review reports **FAIL**:
1. Display all findings
2. Implement fixes for each finding
3. `[SHELL]` Commit fixes:
   ```bash
   git add <fixed-files>
   git commit -m "fix(<scope>): address review findings

   Refs #<issue-number>"
   ```
4. Re-run only the failed review stage (Stage 1 or Stage 2)
5. Repeat until both stages report **PASS**

---

## STEP 11 — Update Implementation Doc

[READ] `docs/plans/issue-<n>/implementation.md`

[WRITE] Mark all completed steps as `done`. Add deviation notes if any step differed from the original plan.

---

## STEP 12 — Full Test Run

[SHELL] Run all checks:
```bash
{config.stack.build_cmd}
{config.stack.lint_cmd}
{config.stack.test_cmd}
```

If any fail → fix failures before proceeding. Do not skip.

---

## STEP 13 — Summary

Display:
```
Parallel Implementation Complete
═══════════════════════════════════════
Issue        : #<number> <title>
Groups       : <N> dispatched
Commits      : <count>
Build        : PASS
Lint         : PASS
Tests        : <pass count> passing
Spec Review  : PASS
Code Review  : PASS
```

---

## STEP 14 — Handoff

```
Run /dev-pr to push the branch and open a pull request.

Branch  : <branch-name>
Issue   : #<number>
```
