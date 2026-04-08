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

Derive SRS path from config:
- If `project_version` exists → `{srs_path}` = `docs/srs-v{project_version}.md`
- If `project_version` absent → `{srs_path}` = `docs/srs.md`

[READ] `{srs_path}` — hard stop if missing:

> No SRS found at {srs_path}. Run `/paadhai:project-plan` first.

Store:
- `{config.repo.owner}` / `{config.repo.name}`
- `{config.github.project_id}` / `{config.github.status_field_id}` / `{config.github.statuses.todo}`
- `{config.project_version}` (if present)

### Progress Tracking

[PROGRESS] Initialize TodoWrite checklist — 8 items, all `pending`:
```
Step 1/8: Load Config + SRS
Step 2/8: Analyze Requirements
Step 3/8: Create Issues
Step 4/8: Present Release Plan
Step 5/8: Revision Loop
Step 6/8: Create on GitHub (after G-03)
Step 7/8: Summary
Step 8/8: Handoff
```
(Graceful degradation: skip if TodoWrite unavailable)

[PROGRESS] Mark Step 1/8 `completed`:
```
Step 1/8: Load Config + SRS [completed]
Files read: .paadhai.json, docs/srs-v{project_version}.md
```

---

## STEP 2 — Analyze Requirements

[PROGRESS] Mark Step 2/8 `in_progress`: `Step 2/8: Analyze Requirements [in_progress]`

Read all functional requirements (FR-*) in the SRS. Group them into milestones by logical delivery increments.

Milestone naming uses the project version as a base:
- If `project_version` = `"2.0"` → milestones: `v2.1 — Name`, `v2.2 — Name`, `v2.3 — Name`
- If `project_version` absent → milestones: `v0.1 — Name`, `v0.2 — Name`, `v0.3 — Name` (current behavior)

Rules:
- Each milestone should be independently shippable
- Each milestone should take roughly equal effort
- Dependencies between milestones should be explicit

[PROGRESS] Mark Step 2/8 `completed`: `Step 2/8: Analyze Requirements [completed]`
`Requirements analyzed`

---

## STEP 3 — Create Issues

[PROGRESS] Mark Step 3/8 `in_progress`: `Step 3/8: Create Issues [in_progress]`

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

[PROGRESS] Mark Step 3/8 `completed`: `Step 3/8: Create Issues [completed]`
`Issue list created`

---

## STEP 4 — Present Release Plan

[PROGRESS] Mark Step 4/8 `in_progress`: `Step 4/8: Present Release Plan [in_progress]`

Show the complete release plan:

```
Release Plan
════════════════════════════════════
Milestone v{major}.1 — <name> (<n> issues)
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

[PROGRESS] Mark Step 4/8 `completed`: `Step 4/8: Present Release Plan [completed]`
`Plan presented`

---

## STEP 5 — Revision Loop

[PROGRESS] Mark Step 5/8 `in_progress`: `Step 5/8: Revision Loop [in_progress]`

- **Approved** → proceed to Step 6
- **Changes requested** → apply → re-present full plan → repeat G-03
- **Question** → answer → update if needed → re-present

[PROGRESS] Mark Step 5/8 `completed`: `Step 5/8: Revision Loop [completed]`
`Plan approved`

---

## STEP 6 — Create on GitHub (after G-03)

[PROGRESS] Mark Step 6/8 `in_progress`: `Step 6/8: Create on GitHub (after G-03) [in_progress]`

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

[PROGRESS] Mark Step 6/8 `completed`: `Step 6/8: Create on GitHub (after G-03) [completed]`
`Milestones and issues created on GitHub`

---

## STEP 7 — Summary

[PROGRESS] Mark Step 7/8 `in_progress`: `Step 7/8: Summary [in_progress]`

```
✓ Milestones created : <count>
✓ Issues created     : <count>
✓ Project board      : all issues added with status "Todo"

Milestones:
- <milestone> : <issue count> issues
- ...

Project board: <board-url>
```

[PROGRESS] Mark Step 7/8 `completed`: `Step 7/8: Summary [completed]`
`Output displayed`

---

## STEP 8 — Handoff

[PROGRESS] Mark Step 8/8 `in_progress`: `Step 8/8: Handoff [in_progress]`

```
Release plan is live on GitHub.
Next step: run /dev-start #<first-issue-number> to begin development.
```

[PROGRESS] Mark Step 8/8 `completed`: `Step 8/8: Handoff [completed]`
`Output displayed`
