---
name: dev-start
description: Use when starting development — issue intake, pre-flight checks, branch creation, and project board sync
---

# dev-start: Issue Intake + Branch Creation

Pick an issue, run pre-flight checks, create the feature branch, move the issue to "In Progress".

**Status tracking:** This skill moves the issue to "In Progress" on the project board (after G-04 approval).

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Store config values for use throughout:
- `{config.repo.owner}` / `{config.repo.name}`
- `{config.repo.develop_branch}`
- `{config.github.project_id}` / `{config.github.status_field_id}`
- `{config.github.statuses.in_progress}`
- `{config.branches.feature}`

---

## STEP 2 — Fetch Issue

If user provided an issue number:

[SHELL] Fetch issue details:
```bash
gh api repos/{config.repo.owner}/{config.repo.name}/issues/<number> \
  --jq '{number: .number, title: .title, milestone: .milestone.title, labels: [.labels[].name], body: .body}'
```

If NO issue number provided:

[SHELL] List open issues — ask user to pick:
```bash
gh api "repos/{config.repo.owner}/{config.repo.name}/issues?state=open&per_page=20" \
  --jq '.[] | "#\(.number) [\(.milestone.title)] \(.title)"'
```

Display:
```
Issue #<number>: <title>
Milestone : <milestone>
Labels    : <labels>
```

---

## STEP 3 — Pre-flight Checks

[SHELL] Check working tree and branch:
```bash
git status
git branch --show-current
```

- If not on `{config.repo.develop_branch}` → switch to it
- If dirty state → offer to stash: `git stash push -m "paadhai: pre dev-start"` or stop

[SHELL] Ensure develop is up to date:
```bash
git fetch origin && git pull origin {config.repo.develop_branch}
```

[SHELL] Check if branch already exists:
```bash
git branch --list "{config.branches.feature}<number>-*"
```
→ If yes: ask user to switch or delete it.

---

## STEP 4 — Derive Branch Name

Format: `{config.branches.feature}{issue-number}-{short-kebab-case-title}`
- Max 50 chars total
- Lowercase, hyphens only, no special characters
- Strip articles: a, an, the, and, or, for, with, to

---

## STEP 5 — Action Summary + Human Gate

Display:
```
Issue   : #<number> <title>
Branch  : {branch-name}
Board   : Will move to "In Progress"
```

**G-04: "Create branch and start issue? (yes/no)"**

Wait for explicit user confirmation. Do not proceed without "yes".

---

## STEP 6 — Execute (after G-04 approval)

All actions execute automatically after approval — no intermediate confirmations.

[DELEGATE][FAST-MODEL] Execute all at once:

**6a. Create branch and push:**
```bash
git checkout -b {branch-name}
git push -u origin {branch-name}
```

**6b. Move issue to "In Progress" on project board:**
```bash
ITEM_ID=$(gh api graphql \
  -f query='{ repository(owner: "{config.repo.owner}", name: "{config.repo.name}") { projectsV2(first: 1) { nodes { items(first: 100) { nodes { id content { ... on Issue { number } } } } } } } }' \
  --jq '.data.repository.projectsV2.nodes[0].items.nodes[] | select(.content.number == <number>) | .id')

gh api graphql -f query="mutation { updateProjectV2ItemFieldValue(input: { projectId: \"{config.github.project_id}\", itemId: \"$ITEM_ID\", fieldId: \"{config.github.status_field_id}\", value: { singleSelectOptionId: \"{config.github.statuses.in_progress}\" } }) { projectV2Item { id } } }"
```

If GraphQL fails, warn but do not block — branch creation is the critical path.

---

## STEP 7 — Display Results

```
✓ Branch created : {branch-name}
✓ Tracking       : origin/{branch-name}
✓ Project board  : #<number> → In Progress
```

---

## STEP 8 — Handoff

```
Branch is ready. Next step: run /dev-plan to create the implementation plan.

Issue   : #<number> <title>
Branch  : {branch-name}
Project : In Progress ✓
```

Do not start planning or implementation here. This skill's job is done.
