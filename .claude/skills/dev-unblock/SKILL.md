---
name: dev-unblock
description: Use when CI is failing or merge conflicts block progress — diagnose, fix, and re-push until green
---

# dev-unblock: CI + Conflict Resolution

Detect CI failure type or merge conflict, diagnose, fix, re-push, poll until green.

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
dev-unblock | Issue #<number> — <title>
8 steps | Branch: <branch>
────────────────────────────────────────
```

Display (no issue context — not on feature/fix branch):
```
────────────────────────────────────────
dev-unblock
8 steps | Branch: <branch>
────────────────────────────────────────
```

If `gh api` fails, degrade gracefully — show banner without issue title.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Store:
- `{config.repo.owner}` / `{config.repo.name}` / `{config.repo.develop_branch}`
- `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` / `{config.stack.test_cmd}`

---

## STEP 2 — Detect Failure Type

[SHELL] Check for merge conflicts:
```bash
git status --porcelain | grep "^UU\|^AA\|^DD"
```

[SHELL] Check CI status on current PR:
```bash
gh pr checks --json name,state,conclusion
```

Classify failure type:
- `conflict` — merge conflicts detected in git status
- `test` — CI test job failed
- `lint` — CI lint job failed
- `type` — CI type-check job failed
- `build` — CI build job failed
- `multiple` — more than one type

Display:
```
Failure Detection
═══════════════════════════
Type       : <failure-type>
Jobs       : <affected job names>
Files      : <affected files if conflict>
```

If no failures detected:
> No CI failures or merge conflicts found. Nothing to unblock.

---

## STEP 3 — Route by Type

### 3a — Merge Conflict

[READ] each conflicted file to understand both sides.

[DELEGATE][SMART-MODEL] Resolve conflicts:
- Prefer feature branch intent (the work being done)
- Preserve develop branch structure (formatting, imports, config)
- Never discard either side without understanding the intent

[SHELL] Stage resolved files:
```bash
git add <resolved-files>
git commit -m "chore: resolve merge conflicts with {config.repo.develop_branch}

Refs #<issue-number>"
```

### 3b — Test Failure

[SHELL] Fetch failed test output:
```bash
gh run view <run-id> --log-failed
```

[DELEGATE][SMART-MODEL] Analyze:
- Is it a real bug in the feature code?
- Is it a flaky test (timing, order-dependent, external service)?
- Is it a test that needs updating for the new behavior?

Fix the source code or test as appropriate.

### 3c — Lint Failure

[SHELL] Reproduce locally:
```bash
{config.stack.lint_cmd}
```

[SHELL] Auto-fix if the linter supports it (e.g., `--fix` flag):
```bash
{config.stack.lint_cmd} --fix
```

Manually fix any remaining lint errors that auto-fix cannot resolve.

### 3d — Type / Build Failure

[SHELL] Reproduce locally:
```bash
{config.stack.build_cmd}
```

[READ] files referenced in error output.

[DELEGATE][SMART-MODEL] Fix type errors or build errors:
- Missing imports, incorrect types, incompatible signatures
- Build config issues, missing dependencies

---

## STEP 4 — Fix Gate

**G-13: "Apply fix and re-push? (yes/no)"**

Display:
```
Proposed Fix
═══════════════════════════
Type    : <failure-type>
Files   : <changed files>
Summary : <what was fixed>
```

Wait for explicit "yes".

---

## STEP 5 — Commit + Push (after G-13)

[SHELL] Commit and push:
```bash
git add <specific-files-changed>
git commit -m "fix(ci): resolve <failure-type> failure

<one-line description of fix>

Refs #<issue-number>"
git push origin <current-branch>
```

---

## STEP 6 — Poll CI

[SHELL] Watch CI checks (max 5 minutes):
```bash
gh pr checks <pr-number> --watch --interval 30
```

- If all checks pass → proceed to Step 7
- If CI exceeds 5 minutes → report current status:
  > CI is still running. Re-run `/paadhai:dev-unblock` to check again.
- If new failure detected → return to Step 2 (different failure type may appear)
- Maximum 3 retry loops total. After 3 → stop:
  > 3 fix attempts exhausted. Manual intervention needed.

---

## STEP 7 — Summary

Display:
```
Unblocked
═══════════════════════════
Original failure : <type> — <description>
Fix applied      : <summary>
CI status        : all passing
Commits added    : <count>
Retry loops      : <count>
```

---

## STEP 8 — Handoff

Context-aware handoff based on pipeline state:

[SHELL] Check PR review status:
```bash
gh pr view --json reviewDecision --jq '.reviewDecision'
```

- If PR exists and CI is green, no review yet:
  ```
  CI is green. Run /dev-audit to review the PR.
  ```
- If PR exists, CI green, and review approved:
  ```
  CI is green. Run /dev-ship to merge the PR.
  ```
- Otherwise:
  ```
  CI is green. Resume your workflow.

  Branch : <branch-name>
  PR     : #<pr-number>
  ```
