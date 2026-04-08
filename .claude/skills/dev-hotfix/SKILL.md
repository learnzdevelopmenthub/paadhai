---
name: dev-hotfix
description: Use when a critical production issue needs an emergency fix — fast-path branch from main, minimal fix, PR directly to main
---

# dev-hotfix: Emergency Fast-Path

Create a hotfix branch from main, implement a minimal targeted fix, and open a PR directly to main — bypassing the normal develop cycle.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Store:
- `{config.repo.owner}` / `{config.repo.name}`
- `{config.repo.main_branch}` / `{config.repo.develop_branch}`
- `{config.branches.fix}`
- `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` / `{config.stack.test_cmd}`

---

## STEP 2 — Identify Problem

Ask user:
> "Describe the production issue (or provide a GitHub issue number):"

If an issue number is provided → fetch it:
```bash
gh api repos/{config.repo.owner}/{config.repo.name}/issues/<number> \
  --jq '{number: .number, title: .title, labels: [.labels[].name], body: .body}'
```

Store: `<hotfix-id>` = issue number if provided, or a short kebab-case slug (e.g., `null-pointer-crash`).

Display:
```
Hotfix Target
═══════════════════════════
Issue      : #<number> <title> (or: <description>)
ID         : <hotfix-id>
Branch     : {config.branches.fix}<hotfix-id>-hotfix
Base       : {config.repo.main_branch}
```

---

## STEP 3 — Assess Severity

Evaluate based on description and labels:

| Level | Criteria |
|-------|---------|
| CRITICAL | Data loss, security breach, complete outage |
| HIGH | Core feature broken for all users |
| MEDIUM | Partial degradation, workaround exists |

Display severity and proceed. For MEDIUM severity → warn:
> This issue is MEDIUM severity. Consider using the normal /dev-start → /dev-plan flow instead.

---

## STEP 4 — Hotfix Branch Gate

**G-18: "Create hotfix branch `{config.branches.fix}<hotfix-id>-hotfix` from `{config.repo.main_branch}`? (yes/no)"**

Wait for explicit "yes". Do not proceed without it.

---

## STEP 5 — Create Hotfix Branch (after G-18)

[SHELL] Checkout main, pull latest, create hotfix branch:
```bash
git checkout {config.repo.main_branch}
git pull origin {config.repo.main_branch}
git checkout -b {config.branches.fix}<hotfix-id>-hotfix
git push -u origin {config.branches.fix}<hotfix-id>-hotfix
```

---

## STEP 6 — Read Relevant Code

[DELEGATE][FAST-MODEL] Identify and read the files most likely affected by this issue based on the problem description. Read at minimum 2–3 files. Focus on:
- Files mentioned in error messages or logs
- Entry points related to the failing feature
- Recent commits touching this area

---

## STEP 7 — Implement Fix

Apply the minimal change necessary to resolve the issue.

**Hotfix constraints — strict:**
- Fix ONLY the reported issue — no refactoring, no style changes, no feature additions
- Minimize the diff — fewer lines changed = lower risk of regression
- If the fix requires more than ~20 lines of change → warn user and ask to confirm before proceeding

Display the proposed change before writing:
```
Proposed Fix
═══════════════════════════
File(s)  : <files to change>
Change   : <description of what changes>
Lines    : ~<estimated diff size>
```

Ask user: "Apply this fix? (yes/no)"

---

## STEP 8 — Verify Fix

[SHELL] Run full check suite — all must pass:
```bash
{config.stack.build_cmd}
{config.stack.lint_cmd}
{config.stack.test_cmd}
```

If any check fails → stop and report:
```
Verification Failed
═══════════════════════════
Step    : <build / lint / test>
Output  : <error summary>
Action  : Fix the failure before committing.
```

Do not proceed until all checks pass.

---

## STEP 9 — Fix Summary + Commit Gate

Display fix summary:
```
Fix Ready
═══════════════════════════
Issue      : <description>
Files      : <list of changed files>
Diff size  : ~<lines> changed
Build      : ✓ passing
Lint       : ✓ passing
Tests      : ✓ passing
```

**G-19: "Commit this hotfix and open a PR to `{config.repo.main_branch}`? (yes/no)"**

Wait for explicit "yes". Do not proceed without it.

---

## STEP 10 — Commit + PR (after G-19)

[SHELL] Commit the fix:
```bash
git add <specific-changed-files>
git commit -m "fix(<scope>): <description of fix>

Fixes critical issue: <problem summary>

Refs #<issue-number>"
```

[SHELL] Push and create PR to main:
```bash
git push origin {config.branches.fix}<hotfix-id>-hotfix
gh pr create \
  --base {config.repo.main_branch} \
  --title "fix(<scope>): <description>" \
  --body "## Hotfix

**Issue:** <problem description>
**Severity:** <CRITICAL / HIGH / MEDIUM>
**Fix:** <one-line fix description>

## Changes
<list of files changed>

## Verification
- ✓ Build passing
- ✓ Lint passing
- ✓ Tests passing

Fixes #<issue-number>"
```

---

## STEP 11 — Poll CI

[SHELL] Watch CI checks (max 5 minutes):
```bash
gh pr checks <pr-number> --watch --interval 30
```

If CI completes within 5 minutes → show results.
If CI exceeds 5 minutes → report current status:
> CI is still running. Monitor manually or re-run /dev-hotfix to check status.

---

## STEP 12 — Handoff

```
Hotfix PR ready for review.
═══════════════════════════
Branch     : {config.branches.fix}<hotfix-id>-hotfix
PR         : <pr-url>
Base       : {config.repo.main_branch}
CI         : <passing / in-progress>

After PR is merged to {config.repo.main_branch}:
  1. Back-merge {config.repo.main_branch} → {config.repo.develop_branch}
  2. Tag a patch release with /dev-release

Next step: run /dev-audit to review the PR.
```
