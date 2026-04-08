---
name: dev-implement
description: Use when implementing confirmed plans — execute steps with code review, auto-commit, and subagent delegation for independent tasks
---

# dev-implement: Execute Implementation

Execute the implementation doc step-by-step with code review, auto-commit, and optional subagent delegation.

---

## Resumption

If the user says "continue" or "resume":
1. [READ] implementation doc → find first step with status `pending`
2. [SHELL] `git status` → check for uncommitted work
3. Resume from that step — never re-do `done` steps

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Store:
- `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` / `{config.stack.test_cmd}`

---

## STEP 2 — Load Implementation Doc

[SHELL] Get current branch:
```bash
git branch --show-current
```

Derive issue number from branch. [READ] `docs/plans/issue-<n>/implementation.md` + `docs/plans/issue-<n>/plan.md`.

Display:
```
Issue     : #<number> <title>
Branch    : <branch-name>
Steps     : <total count>
Doc path  : docs/plans/issue-<n>/implementation.md
```

Ask user:
- Model preference? (fast / smart / auto)
- Auto-commit after each step? (yes / no)

---

## STEP 3 — Analyze Task Dependencies

Scan implementation steps for:
- **Sequential patterns**: step B requires step A's output
- **Independent patterns**: steps with no shared state

If 3+ independent tasks with <20% dependencies → offer subagent-driven mode.

---

## STEP 4 — Choose Execution Path

- **Independent-heavy** → offer: subagent-driven OR sequential
- **Sequential-heavy** → sequential only
- **Mixed** → offer choice

Display the dependency analysis and let user choose.

---

## STEP 5 — Pre-Implementation Check

[SHELL] Verify branch and working state:
```bash
git branch --show-current
git status
```

- Must be on feature branch (not `{config.repo.develop_branch}` or `main`)
- Working tree must be clean (or stash uncommitted work first)

---

## STEP 6 — Route Execution

- **Subagent-driven** → hand off to `/paadhai:dev-parallel`. Pass the issue number as context.
- **Sequential** → continue to Step 7

---

## STEP 7 — Implementation Loop

For each `pending` step in the implementation doc:

### 7a — Read Before Modifying
[READ] all files that will be modified in this step.

### 7b — Implement
[DELEGATE] Execute the step (model per user choice in Step 2). Follow the exact command/code in the implementation doc.

### 7c — Code Review
[READ] `code-reviewer-prompt.md` — load review criteria.
[DELEGATE][SMART-MODEL] Review changes using the loaded reviewer prompt. Check:
- Correctness
- Pattern alignment with existing code
- No introduced bugs or security issues

**PASS/FAIL.** Skip for: config changes, docs, dependency bumps. Fix until PASS.

### 7d — Build + Lint
[SHELL] (skip if no source files changed):
```bash
{config.stack.build_cmd}
{config.stack.lint_cmd}
```

Fix failures before proceeding.

### 7e — Update Implementation Doc
[WRITE] Mark step as `done` in implementation doc. Add deviation note if step differed from plan.

### 7f — Step Summary + Gate
Display:
```
Step <n> complete
Files changed : <list>
Build         : ✓ / ✗
Lint          : ✓ / ✗
Code review   : PASS / SKIP
```

**G-06**: If auto-commit = yes → commit automatically. If no → wait for "yes".

### 7g — Commit
[SHELL] Commit specific files (not `git add -A`):
```bash
git add <specific-files-changed>
git commit -m "<type>(<scope>): <subject>

<optional body>

Refs #<number>"
```

Commit type guide:
| Type | When |
|------|------|
| `feat` | New functionality |
| `fix` | Bug fix |
| `test` | Test only |
| `chore` | Deps, config |
| `refactor` | Restructure, no behavior change |
| `docs` | Documentation |
| `perf` | Performance improvement |

Subject: max 72 chars, imperative mood ("add X" not "added X").

---

## STEP 8 — Full Test Run

[SHELL] After all steps complete:
```bash
{config.stack.build_cmd}
{config.stack.lint_cmd}
{config.stack.test_cmd}
```

Fix any failures before proceeding. Do not skip.

---

## STEP 9 — Summary

Display:
```
Implementation complete

Issue   : #<number> <title>
Commits : <count>
Build   : ✓
Lint    : ✓
Tests   : <pass count> passing
```

---

## STEP 10 — Handoff

```
Run /dev-pr to push the branch and open a pull request.

Branch  : <branch-name>
Issue   : #<number>
```
