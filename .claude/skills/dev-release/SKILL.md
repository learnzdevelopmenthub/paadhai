---
name: dev-release
description: Use when releasing the project, tagging a version, shipping a critical production hotfix, or rolling back a bad release — three modes (release | hotfix | rollback) covering the full release lifecycle
---

# dev-release: Release, Hotfix, Rollback

One skill, three modes:
- **release** (default): cut release branch from develop, run tests, tag, publish GitHub Release, back-merge to develop, close milestone.
- **hotfix**: emergency fast-path from main, minimal fix, PR directly to main. Bypasses develop cycle.
- **rollback**: recover from a bad release — delete tag, revert merge commit, create recovery branch.

Invoke as `/paadhai:dev-release`, `/paadhai:dev-release --mode=hotfix`, or `/paadhai:dev-release --mode=rollback`.

---

## PREAMBLE — Announcement Banner

[SHELL] Detect context:
```bash
BRANCH=$(git branch --show-current)
```

If branch matches `feature/*` or `fix/*`:
- Extract issue number from branch name
- [SHELL] Fetch issue title:
```bash
gh api repos/{config.repo.owner}/{config.repo.name}/issues/<number> --jq '.title'
```

Display (steps count is mode-specific — set after STEP 2):
```
────────────────────────────────────────
dev-release | Mode: <release|hotfix|rollback>
<N> steps | Branch: <branch>
────────────────────────────────────────
```

If `gh api` fails, degrade gracefully — show banner without issue title.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Store:
- `{config.repo.owner}` / `{config.repo.name}`
- `{config.repo.develop_branch}` / `{config.repo.main_branch}`
- `{config.branches.release}` / `{config.branches.fix}`
- `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` / `{config.stack.test_cmd}`

---

## STEP 2 — Mode Selection

Resolve mode from invocation flag, then context detection, then user prompt.

```
IF user invoked with --mode=<flag>:
  mode := flag (release | hotfix | rollback)
ELSE IF current branch matches {config.branches.release}*:
  mode := release
ELSE IF current branch matches {config.branches.fix}*-hotfix:
  mode := hotfix
ELSE IF current branch matches {config.branches.fix}*-rollback:
  mode := rollback (resume in-progress rollback)
ELSE:
  PROMPT user:
    "Select mode:
     1. release  — cut new release from develop
     2. hotfix   — emergency fix to main
     3. rollback — recover from bad release
     Choice (1/2/3): "
  mode := user input
```

Display:
```
Mode confirmed: <mode>
```

Set step count for banner:
- `release` → 13 remaining steps (R1–R13)
- `hotfix` → 11 remaining steps (H1–H11)
- `rollback` → 7 remaining steps (B1–B7)

[PROGRESS] Initialize TodoWrite checklist for the selected mode (skip if TodoWrite unavailable).

Branch to the matching mode block below.

---

# ───────────────────────────────────────────
# MODE: release
# ───────────────────────────────────────────

## R1 — Verify Milestone Completion

[SHELL] Check open issues in the current milestone:
```bash
gh api "repos/{config.repo.owner}/{config.repo.name}/milestones" \
  --jq '.[] | select(.open_issues > 0) | {title: .title, open: .open_issues}'
```

If any open issues remain → stop:
```
Milestone has <n> open issues. Close or move them before releasing.
Open issues:
<list of open issues>
```

If all closed → proceed.

## R2 — Ask Version

Ask user:
> "What version number for this release? (e.g., v0.1.0)"

Validate format: must match `v\d+\.\d+\.\d+` or similar semantic version.

Ask user:
> "What is the milestone title for this release? (e.g., v0.1 — Core)"

## R3 — Prepare Release Branch

[SHELL] Switch to develop and pull:
```bash
git checkout {config.repo.develop_branch}
git pull origin {config.repo.develop_branch}
```

[SHELL] Create release branch:
```bash
git checkout -b {config.branches.release}<version>
git push -u origin {config.branches.release}<version>
```

## R4 — Run Full Test Suite

[DELEGATE][FAST-MODEL] Run all checks:
```bash
{config.stack.build_cmd}
{config.stack.lint_cmd}
{config.stack.test_cmd}
```

If any fail → stop:
> Tests failed. Fix before releasing. Results: <summary>

## R5 — Generate Changelog

[SHELL] Get commits since last tag:
```bash
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -n "$LAST_TAG" ]; then
  git log ${LAST_TAG}..HEAD --pretty=format:"%s|%h" --no-merges
else
  git log --pretty=format:"%s|%h" --no-merges
fi
```

Categorize each commit by conventional commit prefix:

| Prefix | Section |
|--------|---------|
| `feat` | Features |
| `fix` | Bug Fixes |
| `perf` | Performance |
| `docs` | Documentation |
| `refactor` | Refactoring |
| `test` | Tests |
| `chore` | Chores |

Extract issue references (`Refs #N`) from commit messages — link to GitHub issues.

[WRITE] Prepend to `CHANGELOG.md` (create if not exists):

```markdown
## <version> — <date>

### Features
- <subject> (<hash>) (#<issue>)

### Bug Fixes
- <subject> (<hash>) (#<issue>)

<...only include non-empty sections...>
```

Store the changelog body for use as GitHub Release notes in R10.

[SHELL] Commit changelog:
```bash
git add CHANGELOG.md
git commit -m "docs(changelog): add <version> changelog

Refs release <version>"
```

## R6 — Push + Create Release PR

[SHELL] Create PR from release branch to main:
```bash
gh pr create \
  --base {config.repo.main_branch} \
  --title "release: <version>" \
  --body "Release <version> — <milestone-title>

## Changes
<changelog-body-from-R5>

## Checklist
- [ ] All milestone issues closed
- [ ] Tests passing
- [ ] Version bumped (if applicable)"
```

## R7 — Display Release PR URL

```
✓ Release PR created: <pr-url>

PR          : <number> release: <version>
Base branch : {config.repo.main_branch}
From        : {config.branches.release}<version>
```

## R8 — Final Confirmation (Gate)

**G-10: "Confirm: Merge release PR and publish release? (yes/no)"**

Wait for explicit "yes". Do not proceed without it.

## R9 — Execute Release (after G-10)

All at once — no intermediate confirmations.

[SHELL] Merge release PR:
```bash
gh pr merge --merge --delete-branch
```

[SHELL] Create annotated tag:
```bash
git checkout {config.repo.main_branch}
git pull origin {config.repo.main_branch}
git tag -a <version> -m "<version> — <milestone-title>"
git push origin <version>
```

[SHELL] Back-merge to develop:
```bash
git checkout {config.repo.develop_branch}
git merge {config.repo.main_branch}
git push origin {config.repo.develop_branch}
```

[SHELL] Create GitHub Release:
```bash
gh release create <version> \
  --target {config.repo.main_branch} \
  --title "<version> — <milestone-title>" \
  --notes "<changelog-body-from-R5>"
```

## R10 — Close Milestone

[SHELL] Close the milestone:
```bash
MILESTONE_NUMBER=$(gh api "repos/{config.repo.owner}/{config.repo.name}/milestones?state=open" \
  --jq '.[] | select(.title == "<milestone-title>") | .number')
gh api "repos/{config.repo.owner}/{config.repo.name}/milestones/$MILESTONE_NUMBER" \
  --method PATCH --field state=closed
```

If milestone not found → warn and continue:
> Milestone "<milestone-title>" not found or already closed. Skipping.

## R11 — Display Release URL

```
✓ Release published: <release-url>

Version  : <version>
Tag      : <version>
Branch   : {config.repo.main_branch}
Notes    : from CHANGELOG.md
Milestone: <milestone-title> closed
```

## R12 — Post-Release Health Check

[SHELL] Check CI status on main:
```bash
gh run list --branch {config.repo.main_branch} --limit 1 --json status,conclusion,name \
  --jq '.[] | "\(.name): \(.status) / \(.conclusion)"'
```

[SHELL] Check for new issues filed in the last hour:
```bash
gh api "repos/{config.repo.owner}/{config.repo.name}/issues?state=open&sort=created&direction=desc&per_page=10" \
  --jq '[.[] | select(.created_at > (now - 3600 | todate))] | length'
```

Display health report:
```
Post-Release Health Check
═══════════════════════════
CI on main   : <passing / failing / in-progress>
New issues   : <count> filed in the last hour
Signal       : <NONE / WARNING>
```

If CI is failing or 3+ new issues filed in the last hour:
> WARNING: Post-release signals suggest a problem. Consider running `/paadhai:dev-release --mode=rollback` if issues are critical.

## R13 — Next Milestone

[SHELL] Show open issues for next milestone:
```bash
gh api "repos/{config.repo.owner}/{config.repo.name}/issues?state=open&per_page=10" \
  --jq '.[] | "#\(.number) [\(.milestone.title)] \(.title)"'
```

```
Release <version> is live.

Next milestone: <next-milestone-title> (<n> open issues)
To start: run /paadhai:dev-start #<next-issue-number>
```

GO TO HANDOFF.

---

# ───────────────────────────────────────────
# MODE: hotfix
# ───────────────────────────────────────────

## H1 — Identify Problem

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

## H2 — Assess Severity

Evaluate based on description and labels:

| Level | Criteria |
|-------|---------|
| CRITICAL | Data loss, security breach, complete outage |
| HIGH | Core feature broken for all users |
| MEDIUM | Partial degradation, workaround exists |

Display severity. For MEDIUM severity → warn:
> This issue is MEDIUM severity. Consider using the normal /paadhai:dev-start → /paadhai:dev-plan flow instead.

## H3 — Hotfix Branch Gate

**G-18: "Create hotfix branch `{config.branches.fix}<hotfix-id>-hotfix` from `{config.repo.main_branch}`? (yes/no)"**

Wait for explicit "yes".

## H4 — Create Hotfix Branch (after G-18)

[SHELL] Checkout main, pull latest, create hotfix branch:
```bash
git checkout {config.repo.main_branch}
git pull origin {config.repo.main_branch}
git checkout -b {config.branches.fix}<hotfix-id>-hotfix
git push -u origin {config.branches.fix}<hotfix-id>-hotfix
```

## H5 — Read Relevant Code

[DELEGATE][FAST-MODEL] Identify and read 2–3 files most likely affected:
- Files mentioned in error messages or logs
- Entry points related to the failing feature
- Recent commits touching this area

## H6 — Implement Fix

Apply the minimal change necessary.

**Hotfix constraints — strict:**
- Fix ONLY the reported issue — no refactoring, no style changes, no feature additions
- Minimize the diff — fewer lines = lower risk
- If fix requires more than ~20 lines → warn user and ask to confirm

Display the proposed change before writing:
```
Proposed Fix
═══════════════════════════
File(s)  : <files to change>
Change   : <description>
Lines    : ~<estimated diff size>
```

Ask user: "Apply this fix? (yes/no)"

## H7 — Verify Fix

[SHELL] Run full check suite — all must pass:
```bash
{config.stack.build_cmd}
{config.stack.lint_cmd}
{config.stack.test_cmd}
```

If any check fails → stop:
```
Verification Failed
═══════════════════════════
Step    : <build / lint / test>
Output  : <error summary>
Action  : Fix the failure before committing.
```

## H8 — Fix Summary + Commit Gate

Display fix summary:
```
Fix Ready
═══════════════════════════
Issue      : <description>
Files      : <list>
Diff size  : ~<lines> changed
Build      : ✓  Lint: ✓  Tests: ✓
```

**G-19: "Commit this hotfix and open a PR to `{config.repo.main_branch}`? (yes/no)"**

Wait for explicit "yes".

## H9 — Commit + PR (after G-19)

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

## H10 — Poll CI

[SHELL] Watch CI checks (max 5 minutes):
```bash
gh pr checks <pr-number> --watch --interval 30
```

If CI exceeds 5 minutes → report:
> CI is still running. Monitor manually or re-run `/paadhai:dev-release --mode=hotfix` to check status.

## H11 — Hotfix Handoff

```
Hotfix PR ready for review.
═══════════════════════════
Branch     : {config.branches.fix}<hotfix-id>-hotfix
PR         : <pr-url>
Base       : {config.repo.main_branch}
CI         : <passing / in-progress>

After PR is merged to {config.repo.main_branch}:
  1. Back-merge {config.repo.main_branch} → {config.repo.develop_branch}
  2. Tag a patch release with /paadhai:dev-release (default mode)

Next step: run /paadhai:dev-audit to review the PR.
```

GO TO HANDOFF.

---

# ───────────────────────────────────────────
# MODE: rollback
# ───────────────────────────────────────────

## B1 — Identify Release

Ask user:
> "Which version to roll back? (e.g., v0.2.0)"

[SHELL] Verify tag exists:
```bash
git tag --list "<version>"
```

If tag not found → STOP:
> Tag `<version>` not found. Check `git tag --list` for available tags.

[SHELL] Find the merge commit on main for this release:
```bash
git log {config.repo.main_branch} --merges --oneline -5
```

Display:
```
Release Identified
═══════════════════════════
Tag          : <version>
Merge commit : <sha> <message>
Date         : <date>
```

## B2 — Impact Assessment

[SHELL] Check commits after this tag on main:
```bash
git log <version>..{config.repo.main_branch} --oneline
```

[SHELL] Check if develop has diverged:
```bash
git log <version>..{config.repo.develop_branch} --oneline
```

Display:
```
Impact Assessment
═══════════════════════════
Commits after tag on main  : <count>
Develop divergence         : <count> commits
Risk                       : <LOW / HIGH>
```

If commits exist after the tag on main:
> WARNING: There are <count> commits on main after this tag. Rolling back will also revert these commits. Consider `/paadhai:dev-release --mode=hotfix` instead.

## B3 — Rollback Plan

Display the exact actions that will be taken:

```
Rollback Plan for <version>
═══════════════════════════
1. Delete GitHub Release for <version>
2. Delete tag <version> (local + remote)
3. Revert merge commit <sha> on {config.repo.main_branch}
4. Push revert to {config.repo.main_branch}
5. Create recovery branch: {config.branches.fix}<version>-rollback
6. Push recovery branch
```

## B4 — Rollback Gate

**G-14: "Execute rollback? This deletes the tag and reverts the merge. (yes/no)"**

Wait for explicit "yes". Destructive — do not proceed without it.

## B5 — Execute Rollback (after G-14)

All steps execute in sequence — STOP on first failure.

[SHELL] Delete GitHub Release:
```bash
gh release delete <version> --yes
```

[SHELL] Delete tag locally and remotely:
```bash
git tag -d <version>
git push origin :refs/tags/<version>
```

[SHELL] Revert merge commit on main:
```bash
git checkout {config.repo.main_branch}
git pull origin {config.repo.main_branch}
git revert -m 1 <merge-commit-sha> --no-edit
git push origin {config.repo.main_branch}
```

[SHELL] Create recovery branch:
```bash
git checkout -b {config.branches.fix}<version>-rollback
git push -u origin {config.branches.fix}<version>-rollback
```

## B6 — Rollback Summary

```
Rollback Complete
═══════════════════════════
Tag deleted      : <version> (local + remote)
Release deleted  : <version> on GitHub
Merge reverted   : <sha> on {config.repo.main_branch}
Recovery branch  : {config.branches.fix}<version>-rollback
```

## B7 — Rollback Handoff

```
Rollback complete. Recovery branch is ready.

Branch  : {config.branches.fix}<version>-rollback
Action  : Fix the issue on this branch, then run /paadhai:dev-pr to open a PR.
```

GO TO HANDOFF.

---

## HANDOFF (shared, mode-aware)

[PROGRESS] Mark all checklist items completed (skip if TodoWrite unavailable).

Mode-specific summary already shown in R13 / H11 / B7. End execution.
