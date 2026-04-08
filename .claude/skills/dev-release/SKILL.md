---
name: dev-release
description: Use when releasing — cut release branch, tag, publish GitHub Release, back-merge to develop
---

# dev-release: Release Automation

Cut the release branch, run tests, create PR to main, tag, publish GitHub Release, back-merge to develop.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Store:
- `{config.repo.owner}` / `{config.repo.name}`
- `{config.repo.develop_branch}` / `{config.repo.main_branch}`
- `{config.branches.release}`
- `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` / `{config.stack.test_cmd}`

---

## STEP 2 — Verify Milestone Completion

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

---

## STEP 3 — Ask Version

Ask user:
> "What version number for this release? (e.g., v0.1.0)"

Validate format: must match `v\d+\.\d+\.\d+` or similar semantic version.

Ask user:
> "What is the milestone title for this release? (e.g., v0.1 — Core)"

---

## STEP 4 — Prepare Release Branch

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

---

## STEP 5 — Run Full Test Suite

[DELEGATE][FAST-MODEL] Run all checks:
```bash
{config.stack.build_cmd}
{config.stack.lint_cmd}
{config.stack.test_cmd}
```

If any fail → stop:
> Tests failed. Fix before releasing. Results: <summary>

If all pass → proceed.

---

## STEP 6 — Generate Changelog

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

Store the changelog body for use as GitHub Release notes in Step 12.

[SHELL] Commit changelog:
```bash
git add CHANGELOG.md
git commit -m "docs(changelog): add <version> changelog

Refs release <version>"
```

---

## STEP 7 — Push + Create Release PR

[SHELL] Create PR from release branch to main:
```bash
gh pr create \
  --base {config.repo.main_branch} \
  --title "release: <version>" \
  --body "Release <version> — <milestone-title>

## Changes
<changelog-body-from-step-6>

## Checklist
- [ ] All milestone issues closed
- [ ] Tests passing
- [ ] Version bumped (if applicable)"
```

---

## STEP 8 — Display Release PR URL

```
✓ Release PR created: <pr-url>

PR          : <number> release: <version>
Base branch : {config.repo.main_branch}
From        : {config.branches.release}<version>
```

---

## STEP 9 — Final Confirmation

**G-10: "Confirm: Merge release PR and publish release? (yes/no)"**

Wait for explicit "yes". Do not proceed without it.

---

## STEP 10 — Execute Release (after G-10)

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
  --notes "<changelog-body-from-step-6>"
```

---

## STEP 11 — Close Milestone

[SHELL] Close the milestone for this release:
```bash
MILESTONE_NUMBER=$(gh api "repos/{config.repo.owner}/{config.repo.name}/milestones?state=open" \
  --jq '.[] | select(.title == "<milestone-title>") | .number')
gh api "repos/{config.repo.owner}/{config.repo.name}/milestones/$MILESTONE_NUMBER" \
  --method PATCH --field state=closed
```

If milestone not found or already closed → warn and continue:
> Milestone "<milestone-title>" not found or already closed. Skipping.

---

## STEP 12 — Display Release URL

```
✓ Release published: <release-url>

Version  : <version>
Tag      : <version>
Branch   : {config.repo.main_branch}
Notes    : from CHANGELOG.md
Milestone: <milestone-title> closed
```

---

## STEP 13 — Post-Release Health Check

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
> WARNING: Post-release signals suggest a problem. Consider running /dev-rollback if issues are critical.

---

## STEP 14 — Next Milestone

[SHELL] Show open issues for next milestone:
```bash
gh api "repos/{config.repo.owner}/{config.repo.name}/issues?state=open&per_page=10" \
  --jq '.[] | "#\(.number) [\(.milestone.title)] \(.title)"'
```

```
Release <version> is live.

Next milestone: <next-milestone-title> (<n> open issues)
To start: run /dev-start #<next-issue-number>
```
