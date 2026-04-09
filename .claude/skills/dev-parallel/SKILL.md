---
name: dev-parallel
description: Use when executing independent implementation tasks in parallel — dispatch fresh subagents per task group with 2-stage review
---

# dev-parallel: Parallel Implementation

Dispatch independent implementation tasks to fresh subagents, review each for spec compliance and code quality, merge results.

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
dev-parallel | Issue #<number> — <title>
14 steps | Branch: <branch>
────────────────────────────────────────
```

Display (no issue context — not on feature/fix branch):
```
────────────────────────────────────────
dev-parallel
14 steps | Branch: <branch>
────────────────────────────────────────
```

If `gh api` fails, degrade gracefully — show banner without issue title.

---

## RATIONALIZATION PREVENTION

Before executing any step, check your reasoning against this table. These are **structural rules** — they cannot be overridden.

| Thought | Why it's wrong | What to do |
|---------|---------------|------------|
| "These tasks are obviously independent" | Hidden dependencies between tasks cause merge conflicts and broken state | Verify independence explicitly before dispatching (Step 3) |
| "Subagent output looks fine, skip Stage 1 review" | Spec compliance issues compound — catching them late costs more | Run full Stage 1 spec compliance review for every subagent |
| "Code quality review is redundant after Stage 1" | Stage 1 checks spec, Stage 2 checks code — different failure modes | Run full Stage 2 code quality review for every subagent |
| "Merging without conflict check is fine" | Parallel branches can create semantic conflicts even without git conflicts | Check for conflicts before merging each result |
| "One subagent failed but the rest are fine, ship it" | Partial results leave the codebase in an inconsistent state | All subagents must pass before merging any |
| "I can skip the final integration check" | Individual correctness doesn't guarantee combined correctness | Run build and tests after merging all results |
| "The task grouping is obvious, no need to analyze" | Poor grouping creates coupling between subagents and merge nightmares | Analyze dependencies and group carefully (Step 2) |

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Store:
- `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` / `{config.stack.test_cmd}`
- `{config.repo.owner}` / `{config.repo.name}`

### Progress Tracking

[PROGRESS] Initialize TodoWrite checklist — 14 items, all `pending`:
```
Step 1/14: Load Config
Step 2/14: Load Implementation Doc
Step 3/14: Group Independent Tasks
Step 4/14: Generate Subagent Prompts
Step 5/14: Dispatch Gate
Step 6/14: Dispatch Subagents (after G-11)
Step 7/14: Collect Results
Step 8/14: Stage 1: Spec Compliance Review
Step 9/14: Stage 2: Code Quality Review
Step 10/14: Fix Loop
Step 11/14: Update Implementation Doc
Step 12/14: Full Test Run
Step 13/14: Summary
Step 14/14: Handoff
```
(Graceful degradation: skip if TodoWrite unavailable)

[PROGRESS] Mark Step 1/14 `completed`:
```
Step 1/14: Load Config [completed]
Files read: .paadhai.json
```

---

## STEP 2 — Load Implementation Doc

[PROGRESS] Mark Step 2/14 `in_progress`: `Step 2/14: Load Implementation Doc [in_progress]`

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

[PROGRESS] Mark Step 2/14 `completed`: `Step 2/14: Load Implementation Doc [completed]`
`Files read: docs/plans/issue-<n>/implementation.md, docs/plans/issue-<n>/plan.md`

---

## STEP 3 — Group Independent Tasks

[PROGRESS] Mark Step 3/14 `in_progress`: `Step 3/14: Group Independent Tasks [in_progress]`

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
> All tasks are sequential. Use `/paadhai:dev-implement` in sequential mode instead.

[PROGRESS] Mark Step 3/14 `completed`: `Step 3/14: Group Independent Tasks [completed]`
`Task groups identified`

---

## STEP 4 — Generate Subagent Prompts

[PROGRESS] Mark Step 4/14 `in_progress`: `Step 4/14: Generate Subagent Prompts [in_progress]`

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

[PROGRESS] Mark Step 4/14 `completed`: `Step 4/14: Generate Subagent Prompts [completed]`
`Prompts generated`

---

## STEP 5 — Dispatch Gate

[PROGRESS] Mark Step 5/14 `in_progress`: `Step 5/14: Dispatch Gate [in_progress]`

**G-11: "Dispatch <N> subagents for parallel implementation? (yes/no)"**

Wait for explicit "yes". Do not proceed without it.

[PROGRESS] Mark Step 5/14 `completed`: `Step 5/14: Dispatch Gate [completed]`
`Gate passed`

---

## STEP 6 — Dispatch Subagents (after G-11)

[PROGRESS] Mark Step 6/14 `in_progress`: `Step 6/14: Dispatch Subagents (after G-11) [in_progress]`

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

[PROGRESS] Mark Step 6/14 `completed`: `Step 6/14: Dispatch Subagents (after G-11) [completed]`
`Subagents dispatched`

---

## STEP 7 — Collect Results

[PROGRESS] Mark Step 7/14 `in_progress`: `Step 7/14: Collect Results [in_progress]`

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

[PROGRESS] Mark Step 7/14 `completed`: `Step 7/14: Collect Results [completed]`
`Results collected`

---

## STEP 8 — Stage 1: Spec Compliance Review

[PROGRESS] Mark Step 8/14 `in_progress`: `Step 8/14: Stage 1: Spec Compliance Review [in_progress]`

[DELEGATE][SMART-MODEL] Review ALL changes against implementation.md:

Check:
- Every assigned step marked `done`?
- Expected outputs match what was described?
- No missing steps or skipped work?
- Acceptance criteria from plan.md addressed?
- File paths match what was specified in implementation.md?

Report: **PASS** / **FAIL** with specific gaps listed.

[PROGRESS] Mark Step 8/14 `completed`: `Step 8/14: Stage 1: Spec Compliance Review [completed]`
`Spec review: PASS`

---

## STEP 9 — Stage 2: Code Quality Review

[PROGRESS] Mark Step 9/14 `in_progress`: `Step 9/14: Stage 2: Code Quality Review [in_progress]`

[DELEGATE][SMART-MODEL] Review ALL changes for:

Check:
- Correctness (logic errors, off-by-one, null handling)
- Pattern alignment (new code follows existing codebase patterns)
- No introduced bugs or security issues
- No duplicate code across subagent outputs
- No merge conflicts between groups (overlapping file edits)
- Import/export consistency across files touched by different groups

Report: **PASS** / **FAIL** with specific issues listed.

[PROGRESS] Mark Step 9/14 `completed`: `Step 9/14: Stage 2: Code Quality Review [completed]`
`Code review: PASS`

---

## STEP 10 — Fix Loop

[PROGRESS] Mark Step 10/14 `in_progress`: `Step 10/14: Fix Loop [in_progress]`

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

[PROGRESS] Mark Step 10/14 `completed`: `Step 10/14: Fix Loop [completed]`
`Fixes applied`

---

## STEP 11 — Update Implementation Doc

[PROGRESS] Mark Step 11/14 `in_progress`: `Step 11/14: Update Implementation Doc [in_progress]`

[READ] `docs/plans/issue-<n>/implementation.md`

[WRITE] Mark all completed steps as `done`. Add deviation notes if any step differed from the original plan.

[PROGRESS] Mark Step 11/14 `completed`: `Step 11/14: Update Implementation Doc [completed]`
`Files changed: docs/plans/issue-<n>/implementation.md`

---

## STEP 12 — Full Test Run

[PROGRESS] Mark Step 12/14 `in_progress`: `Step 12/14: Full Test Run [in_progress]`

[SHELL] Run all checks:
```bash
{config.stack.build_cmd}
{config.stack.lint_cmd}
{config.stack.test_cmd}
```

If any fail → fix failures before proceeding. Do not skip.

[PROGRESS] Mark Step 12/14 `completed`: `Step 12/14: Full Test Run [completed]`
`Build: ✓  Lint: ✓  Tests: <count> passing`

---

## STEP 13 — Summary

[PROGRESS] Mark Step 13/14 `in_progress`: `Step 13/14: Summary [in_progress]`

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

[PROGRESS] Mark Step 13/14 `completed`: `Step 13/14: Summary [completed]`
`Output displayed`

---

## STEP 14 — Handoff

[PROGRESS] Mark Step 14/14 `in_progress`: `Step 14/14: Handoff [in_progress]`

```
Run /dev-pr to push the branch and open a pull request.

Branch  : <branch-name>
Issue   : #<number>
```

[PROGRESS] Mark Step 14/14 `completed`: `Step 14/14: Handoff [completed]`
`Output displayed`
