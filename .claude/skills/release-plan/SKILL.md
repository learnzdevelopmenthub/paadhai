---
name: release-plan
description: Use when creating milestones and issues — break confirmed SRS into GitHub milestones and issues
---

# release-plan: Milestone + Issue Creation

Break the confirmed SRS into GitHub milestones and atomic issues, then create them on GitHub.

**Output:** GitHub milestones + issues on the project board

---

## STEP 1 — Load Config + SRS

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

[READ] `docs/srs.md` — hard stop if missing:

> No SRS found at docs/srs.md. Run `/paadhai:project-plan` first.

Store:
- `{config.repo.owner}` / `{config.repo.name}`
- `{config.github.project_id}` / `{config.github.status_field_id}` / `{config.github.statuses.todo}`

---

## STEP 2 — Analyze Requirements

Read all functional requirements (FR-*) in the SRS. Group them into milestones by logical delivery increments (e.g., v0.1 — Core, v0.2 — API, v0.3 — Release).

Rules:
- Each milestone should be independently shippable
- Each milestone should take roughly equal effort
- Dependencies between milestones should be explicit

---

## STEP 3 — Create Issues

For each milestone, break it into atomic, independently-deliverable issues.

Each issue must have:
- **Title**: clear, actionable (e.g., "Add user authentication endpoint")
- **Body**: full content using this template:

```markdown
## Summary
<what this issue builds — 1-2 sentences>

## Acceptance Criteria
- [ ] AC-1: <specific, testable criterion>
- [ ] AC-2: <specific, testable criterion>

## Test Checklist
- [ ] Happy path: <describe>
- [ ] Edge case: <describe>
- [ ] Error case: <describe>

## Expected Outcome
<what the system does when this issue is complete>

## Notes
<dependencies, constraints, decisions>
```

Issue rules:
- Each issue independently deliverable
- At least 2 acceptance criteria (specific and testable)
- Test checklist required (at least 3 items)
- Must be assigned to a milestone
- Use appropriate labels: `feature`, `bug`, `api`, `db`, `test`, `auth`, `infra`, `docs`

---

## STEP 4 — Present Release Plan

Show the complete release plan:

```
Release Plan
════════════════════════════════════
Milestone v0.1 — <name> (<n> issues)
  #1: <title>
      ACs: <count> | Labels: <labels>
  #2: <title>
      ...

Milestone v0.2 — <name> (<n> issues)
  ...

Total: <milestone count> milestones, <issue count> issues
════════════════════════════════════
```

**G-03: "Approve this release plan? (yes / list changes)"**

Wait for explicit approval.

---

## STEP 5 — Revision Loop

- **Approved** → proceed to Step 6
- **Changes requested** → apply → re-present full plan → repeat G-03
- **Question** → answer → update if needed → re-present

---

## STEP 6 — Create on GitHub (after G-03)

**6a. Create milestones** (in order):
[PARALLEL][FAST-MODEL] Create all milestones simultaneously:
```bash
gh api repos/{config.repo.owner}/{config.repo.name}/milestones \
  --method POST \
  --field title="<milestone-title>" \
  --field description="<milestone-description>"
```

**6b. Create issues**:
[PARALLEL][FAST-MODEL] Create all issues simultaneously:
```bash
gh issue create \
  --repo {config.repo.owner}/{config.repo.name} \
  --title "<title>" \
  --body "<body>" \
  --milestone "<milestone-title>" \
  --label "<labels>"
```

**6c. Add to project board**:
[DELEGATE][FAST-MODEL] Add all issues to project board with status "Todo":
```bash
gh api graphql -f query="mutation { addProjectV2ItemById(input: { projectId: \"{config.github.project_id}\", contentId: \"<issue-node-id>\" }) { item { id } } }"
gh api graphql -f query="mutation { updateProjectV2ItemFieldValue(input: { projectId: \"{config.github.project_id}\", itemId: \"<item-id>\", fieldId: \"{config.github.status_field_id}\", value: { singleSelectOptionId: \"{config.github.statuses.todo}\" } }) { projectV2Item { id } } }"
```

---

## STEP 7 — Summary

```
✓ Milestones created : <count>
✓ Issues created     : <count>
✓ Project board      : all issues added with status "Todo"

Milestones:
- <milestone> : <issue count> issues
- ...

Project board: <board-url>
```

---

## STEP 8 — Handoff

```
Release plan is live on GitHub.
Next step: run /dev-start #<first-issue-number> to begin development.
```
