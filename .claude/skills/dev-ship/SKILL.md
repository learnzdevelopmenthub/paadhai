---
name: dev-ship
description: Use when shipping — merge PR to develop, update project board, clean up feature branch
---

# dev-ship: Merge PR + Board Update

Merge the approved PR, move issue to Done on the project board, clean up the feature branch.

**Prerequisites:** PR must exist and CI must be passing. Run `/paadhai:dev-audit` first if not done.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Store:
- `{config.repo.owner}` / `{config.repo.name}`
- `{config.repo.develop_branch}`
- `{config.github.project_id}` / `{config.github.status_field_id}`
- `{config.github.statuses.done}`
- `{config.branches.feature}`

---

## STEP 2 — Display Context

[SHELL] Get current PR:
```bash
gh pr view --json number,title,baseRefName,state,statusCheckRollup \
  --jq '{number: .number, title: .title, base: .baseRefName, state: .state, ci: (.statusCheckRollup | map(.conclusion) | unique)}'
```

Display:
```
PR #<number>  : <title>
Target branch : {config.repo.develop_branch}
CI status     : <status>
```

If CI is not passing → stop:
> CI checks are not passing. Fix CI before merging. Run /dev-pr to re-poll.

---

## STEP 3 — Final Confirmation

**G-09: "Merge PR #<n> to {config.repo.develop_branch}? (yes/no)"**

Wait for explicit "yes". Do not proceed without it.

---

## STEP 4 — Execute (after G-09)

All at once — no intermediate confirmations.

[DELEGATE][FAST-MODEL] **4a. Squash merge PR:**
```bash
gh pr merge <pr-number> --squash --delete-branch
```

[DELEGATE][FAST-MODEL] **4b. Move issue to Done on project board:**
```bash
ITEM_ID=$(gh api graphql \
  -f query='{ repository(owner: "{config.repo.owner}", name: "{config.repo.name}") { projectsV2(first: 1) { nodes { items(first: 100) { nodes { id content { ... on Issue { number } } } } } } } }' \
  --jq '.data.repository.projectsV2.nodes[0].items.nodes[] | select(.content.number == <issue-number>) | .id')

gh api graphql -f query="mutation { updateProjectV2ItemFieldValue(input: { projectId: \"{config.github.project_id}\", itemId: \"$ITEM_ID\", fieldId: \"{config.github.status_field_id}\", value: { singleSelectOptionId: \"{config.github.statuses.done}\" } }) { projectV2Item { id } } }"
```

If GraphQL fails → warn but do not block. Merge is the critical path.

---

## STEP 5 — Local Cleanup

[SHELL] Switch to develop and pull:
```bash
git checkout {config.repo.develop_branch}
git pull origin {config.repo.develop_branch}
```

[SHELL] Delete local feature branch:
```bash
git branch -d <branch-name>
```

---

## STEP 6 — Display Results

```
✓ PR #<number> merged (squash) → {config.repo.develop_branch}
✓ Feature branch deleted (local + remote)
✓ Issue #<issue-number> → Done
```

---

## STEP 7 — Milestone Check

[SHELL] Check remaining open issues in this milestone:
```bash
gh api "repos/{config.repo.owner}/{config.repo.name}/milestones" \
  --jq '.[] | select(.title == "<milestone>") | {open: .open_issues, closed: .closed_issues}'
```

If open issues remain:
```
Milestone <milestone>: <open> open issues remain.
Suggested next: /dev-start #<next-issue-number>
```

If all closed:
```
All issues in <milestone> are closed.
Ready to release: run /dev-release when ready.
```
