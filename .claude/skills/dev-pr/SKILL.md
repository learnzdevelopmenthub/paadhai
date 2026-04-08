---
name: dev-pr
description: Use when opening a pull request — push branch, create PR, poll CI, report results
---

# dev-pr: PR Creation + CI

Push the feature branch, create the pull request, poll CI, and report results.

**Does NOT change project board status** — board update happens in `/paadhai:dev-ship`.

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
dev-pr | Issue #<number> — <title>
8 steps | Branch: <branch>
────────────────────────────────────────
```

Display (no issue context — not on feature/fix branch):
```
────────────────────────────────────────
dev-pr
8 steps | Branch: <branch>
────────────────────────────────────────
```

If `gh api` fails, degrade gracefully — show banner without issue title.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

[READ] `docs/plans/issue-<n>/plan.md` — derive issue number from current branch first.

Store:
- `{config.repo.owner}` / `{config.repo.name}`
- `{config.repo.develop_branch}`

---

## STEP 2 — Push Branch

[SHELL] Push branch to origin:
```bash
git push origin {branch-name}
```

If push fails (e.g., no upstream set):
```bash
git push -u origin {branch-name}
```

---

## STEP 3 — Build PR Body

Use `templates/pr-body.md` as base. Fill from plan:

- **Summary**: 3–5 bullet points describing what changed
- **Changes**: list of files modified (from `git diff --name-only origin/{config.repo.develop_branch}`)
- **Test Plan**: build/lint/test commands + specific test scenarios for this issue
- **Acceptance Criteria**: from the issue body (copy AC checkboxes)
- **Notes**: any implementation decisions worth flagging

Always include at the end:
```
Closes #<issue-number>
```

---

## STEP 4 — Create PR

[SHELL] Fetch issue labels to apply to PR:
```bash
ISSUE_LABELS=$(gh api "repos/{config.repo.owner}/{config.repo.name}/issues/<issue-number>" \
  --jq '[.labels[].name] | join(",")')
```

[SHELL] Create pull request:
```bash
gh pr create \
  --base {config.repo.develop_branch} \
  --title "<conventional-commit-style title>" \
  --body "<pr-body-from-step-3>" \
  --label "$ISSUE_LABELS"
```

If `--label` fails (e.g., label does not exist on repo) → retry without `--label` and warn:
> Could not apply labels to PR. Labels from issue: <labels>. Apply manually if needed.

PR title format: `<type>(<scope>): <subject>` (same convention as commits).

---

## STEP 5 — Display PR URL

```
✓ PR created: <pr-url>

PR #<number>  : <title>
Base branch   : {config.repo.develop_branch}
Closes        : #<issue-number>
```

---

## STEP 6 — Poll CI

[SHELL] Watch CI checks (max 5 minutes):
```bash
gh pr checks <pr-number> --watch --interval 30
```

If CI completes within 5 minutes → show results in Step 7.
If CI exceeds 5 minutes → report current status and tell user:
> CI is still running. Re-run /dev-pr to check status, or monitor manually.

---

## STEP 7 — CI Results

**G-07**: Display CI results.

If all checks pass:
```
✓ All CI checks passed

Next step: run /dev-audit to review the PR.
```

If any check fails:
1. [READ] `ci-analyzer-prompt.md` — load CI analysis criteria.
2. [DELEGATE][SMART-MODEL] Analyze failure logs using the loaded analyzer prompt:
   ```bash
   gh run view <run-id> --log-failed
   ```
2. Display diagnosis:
   ```
   CI failure in: <job-name>
   Cause: <diagnosis>
   Suggested fix: <fix>
   ```
3. Ask user: "Fix the CI failure now? (yes/no)"
4. If yes → implement fix → commit with `fix(ci): resolve <job>` → re-push → go back to Step 6
5. If no → show PR URL and leave for user to handle

---

## STEP 8 — Handoff (on CI pass)

```
PR is ready for review.
Next step: run /dev-audit to review the PR.

PR      : <pr-url>
Issue   : #<issue-number> <title>
CI      : ✓ passing
```
