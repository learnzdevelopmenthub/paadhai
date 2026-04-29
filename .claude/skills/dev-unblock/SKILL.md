---
name: dev-unblock
description: Use when CI fails, merge conflicts block progress, or test/build/type/lint failures need diagnosis — auto-classify failure type and fix with optional 4-phase deep debugging when root cause is unclear
---

# dev-unblock: Failure Diagnosis + Fix

Detect failure type (conflict | test | lint | type | build), fix it, re-push, poll until green. Escalates to systematic 4-phase debugging (reproduce → isolate → hypothesize → verify) when root cause is unclear.

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
10 steps | Branch: <branch>
────────────────────────────────────────
```

Display (no issue context):
```
────────────────────────────────────────
dev-unblock
10 steps | Branch: <branch>
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

Initialize: `failure_counter = 0`, `deep_debug_used = false`.

---

## STEP 2 — Auto-Classify Failure Type

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

[SHELL] If no automated signal, check for prior debug session:
```bash
test -f docs/plans/issue-<n>/debug.md && echo "exists" || echo "none"
```

If exists → [READ] `docs/plans/issue-<n>/debug.md` and display:
```
Prior debug session found — <count> previous attempt(s).
Last hypothesis: <summary>
```

If still no failures detected, ask user:
> "What is failing? (test name, error message, or behavior description)"

Default classification on manual input: `test`.

Display:
```
Failure Detection
═══════════════════════════
Type       : <failure-type>
Jobs       : <affected job names>
Files      : <affected files if conflict>
Source     : <auto-detected | user-reported>
```

If no failures and no user report:
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

**Diagnosis check:** If root cause is NOT obvious from the output (no clear file:line, no clear trigger) OR a prior fix attempt has already failed, escalate to **STEP 5 (Deep Debug)**.

Otherwise, fix the source code or test directly.

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

**G-13: "Apply fix and re-push? (yes / no / escalate to deep debug)"**

Display:
```
Proposed Fix
═══════════════════════════
Type    : <failure-type>
Files   : <changed files>
Summary : <what was fixed>
```

- **yes** → proceed to STEP 6 (Commit + Push)
- **no** → stop, user retains control
- **escalate to deep debug** → proceed to STEP 5 (Deep Debug)

---

## STEP 5 — Deep Debug (conditional: 4-phase systematic)

**Triggered only when:** test diagnosis is unclear (STEP 3b) OR user escalates from G-13 OR a prior fix has failed.

Set `deep_debug_used = true`.

### 5a — Phase 1: Reproduce

**HARD RULE: No fix proposals in this phase. Only confirm reproduction.**

[SHELL] Run the failing command (from CI output, user input, or `{config.stack.test_cmd}`):
```bash
<failing-command>
```

Capture: exact error output, exit code, stack trace.

[READ] relevant source files from stack trace.

Display:
```
Phase 1: Reproduce
═══════════════════════════
Reproduced : YES / NO
Command    : <command run>
Exit code  : <code>
Error      : <first 10 lines>
Stack trace: <file:line references>
```

If not reproducible → ask user for more specific reproduction steps. Do not proceed.

### 5b — Phase 2: Isolate

**HARD RULE: No fix proposals. Only identify location and trigger.**

[DELEGATE][SMART-MODEL] Narrow root cause:

1. **Which file and line?** — trace from stack trace
2. **What input triggers it?** — specific data, state, or sequence
3. **Is it a regression?**
   ```bash
   git log --oneline -10 -- <file>
   ```
4. **Minimal reproduction path** — smallest set of conditions

[READ] the isolated file(s) to confirm.

Display:
```
Phase 2: Isolate
═══════════════════════════
File       : <file-path>
Line       : <line-number>
Trigger    : <what causes it>
Regression : YES (commit <sha>) / NO (pre-existing)
Minimal    : <shortest reproduction path>
```

### 5c — Phase 3: Hypothesize

[DELEGATE][SMART-MODEL] Generate 1–3 competing hypotheses, ranked by likelihood:

For each hypothesis:
- **Root cause theory**: what is wrong and why
- **Predicted fix**: what change would resolve it
- **Risk**: regressions or side effects
- **Confidence**: high / medium / low

Display:
```
Phase 3: Hypothesize
═══════════════════════════
#1 (high)   : <root cause> → <predicted fix>
              Risk: <side effects>
#2 (medium) : <root cause> → <predicted fix>
              Risk: <side effects>
#3 (low)    : <root cause> → <predicted fix>
              Risk: <side effects>
```

Ask user:
> "Proceed with hypothesis #<n>? (yes / pick #N / describe alternative)"

### 5d — Phase 4: Verify

Implement the chosen fix.

[SHELL] Run the original failing command — it must pass:
```bash
<original-failing-command>
```

[SHELL] Run full test suite — no regressions:
```bash
{config.stack.test_cmd}
```

**If fix works** (both commands pass) → proceed to STEP 6.

**If fix fails** (either still fails):
1. Revert: `git checkout -- <modified-files>`
2. Increment `failure_counter`
3. If `failure_counter >= 3` → proceed to **STEP 5e (Architectural Escalation)**
4. If `failure_counter < 3` → display "Fix did not work. Returning to hypothesize." → return to **STEP 5c** with new context

### 5e — Architectural Escalation (3+ failed fixes)

[DELEGATE][SMART-MODEL] Architectural review:

- Is the component design fundamentally flawed?
- Is there a structural issue (wrong abstraction, missing layer, circular dependency)?
- Should this be a refactor instead of a patch?
- Are there upstream/downstream assumptions that are broken?

Display:
```
Architectural Escalation
═══════════════════════════
3+ fix attempts have failed. This may indicate a design issue.

Analysis:
<architectural findings>

Recommendation: <continue debugging / refactor component / create new issue>
```

Ask user:
> "Continue debugging with new approach, or create a refactor issue? (debug / refactor)"

- **debug** → reset `failure_counter = 0`, return to STEP 5b with architectural context
- **refactor** → display recommendation for new issue, STOP

---

## STEP 6 — Commit + Push

[SHELL] Commit and push:
```bash
git add <specific-files-changed>
git commit -m "fix(ci): resolve <failure-type> failure

<one-line description of fix>

Refs #<issue-number>"
git push origin <current-branch>
```

If `deep_debug_used == true`, also stage `docs/plans/issue-<n>/debug.md` (written in STEP 8).

---

## STEP 7 — Poll CI

[SHELL] Watch CI checks (max 5 minutes):
```bash
gh pr checks <pr-number> --watch --interval 30
```

- All checks pass → STEP 8
- CI exceeds 5 minutes → report current status:
  > CI is still running. Re-run `/paadhai:dev-unblock` to check again.
- New failure detected → return to STEP 2 (different failure type may appear)
- Maximum 3 retry loops total. After 3 → STOP:
  > 3 fix attempts exhausted. Manual intervention needed.

---

## STEP 8 — Record Findings (conditional: only if deep_debug_used == true)

[WRITE] Append to `docs/plans/issue-<n>/debug.md` (create if not exists):

```markdown
## Debug Session — <timestamp>

Problem    : <user's description>
Reproduced : <command + abbreviated output>
Isolated   : <file:line>
Trigger    : <what causes it>
Regression : <yes/no + commit if applicable>
Hypothesis : #<n> — <root cause theory>
Fix        : <what was changed>
Verified   : <test command + PASS>
Attempts   : <failure_counter + 1>
```

Then amend the previous commit to include this file:
```bash
git add docs/plans/issue-<n>/debug.md
git commit --amend --no-edit
git push --force-with-lease origin <current-branch>
```

---

## STEP 9 — Summary

Display:
```
Unblocked
═══════════════════════════
Original failure : <type> — <description>
Fix applied      : <summary>
CI status        : all passing
Commits added    : <count>
Retry loops      : <count>
Deep debug used  : <yes/no>
```

If deep debug used:
```
Debug log        : docs/plans/issue-<n>/debug.md
Root cause       : <one sentence>
Attempts         : <failure_counter + 1>
```

---

## STEP 10 — Handoff

[SHELL] Check PR review status:
```bash
gh pr view --json reviewDecision --jq '.reviewDecision'
```

- PR exists, CI green, no review yet:
  > CI is green. Run `/paadhai:dev-audit` to review the PR.
- PR exists, CI green, review approved:
  > CI is green. Run `/paadhai:dev-ship` to merge the PR.
- No PR yet (deep debug on local branch):
  > Fix verified locally. Run `/paadhai:dev-pr` to open a PR.
- Otherwise:
  ```
  CI is green. Resume your workflow.

  Branch : <branch-name>
  PR     : #<pr-number>
  ```
