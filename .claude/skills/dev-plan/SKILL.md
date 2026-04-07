---
name: dev-plan
description: Use when planning GitHub issues — brainstorm, design review, version validation, generate plan + implementation doc
---

# dev-plan: Issue Planning

Brainstorm, design review, version validation, generate plan + implementation doc for an issue.

**Output:** `docs/plans/issue-<n>/plan.md` + `docs/plans/issue-<n>/implementation.md`

---

## STEP 1 — Load Config

[READ] `.devflow.json` — hard stop if missing:

> No `.devflow.json` found. Run `/project-init` first.

Store config values:
- `{config.repo.owner}` / `{config.repo.name}`
- `{config.repo.develop_branch}`
- `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` / `{config.stack.test_cmd}`

---

## STEP 2 — Identify Issue

[SHELL] Get current branch:
```bash
git branch --show-current
```

Derive issue number from branch name (e.g., `feature/42-add-login` → `#42`).

[SHELL] Fetch issue details:
```bash
gh api repos/{config.repo.owner}/{config.repo.name}/issues/<number> \
  --jq '{number: .number, title: .title, milestone: .milestone.title, labels: [.labels[].name], body: .body}'
```

Display:
```
Issue     : #<number> <title>
Milestone : <milestone>
Labels    : <labels>
```

---

## STEP 3 — Read Relevant Code

[DELEGATE][FAST-MODEL] Read existing source files relevant to the issue (based on labels and title). Read at minimum 3–5 files. Do not skip — makes questions and plan accurate.

---

## STEP 4 — Scope Validation

Check:
- **Clarity**: Can you describe the issue in one sentence?
- **Feasibility**: Are acceptance criteria present? Any blockers?
- **Architecture fit**: New feature, bug fix, or refactor?

If unclear on any point → ask user before proceeding.

---

## STEP 5 — Brainstorming Questions

Ask 5–7 targeted questions one at a time. Tailor to issue labels:
- `api` → endpoint design, auth, versioning
- `db` → schema, migrations, indexes
- `test` → coverage strategy, fixtures
- `auth` → token handling, permissions
- `infra` → deployment, config management

Always ask:
- Which acceptance criteria from the SRS apply here?
- Anything specific about the existing codebase I should know?
- Does this align with existing patterns in the codebase?

---

## STEP 6 — Design Review

[READ] 2–3 similar implementations in the codebase. Check:
- Pattern alignment
- Tradeoffs
- Architectural implications
- Standards compliance

Note findings for the plan.

---

## STEP 7 — Version Validation

[DELEGATE][FAST-MODEL][SEARCH] Check current stable versions of core packages used in this issue. Verify:
- Breaking changes since current version
- Config compatibility
- Platform-specific issues

Skip for well-known stable APIs (e.g., standard library functions).

---

## STEP 8 — Generate Plan

Create a structured plan:

```
## Overview
<1-2 sentence description>

## Files to Create
- <path>: <purpose>

## Files to Modify
- <path>: <what changes>

## Implementation Steps
1. <step description>
   - Expected: <outcome>
2. <step description>
   ...

## Test Cases
- Happy path: <describe>
- Edge case: <describe>
- Error case: <describe>

## AC Mapping
| AC | How Addressed |
|----|--------------|
| AC-1 | <implementation detail> |

## Definition of Done
- [ ] `{config.stack.build_cmd}` — zero errors
- [ ] `{config.stack.lint_cmd}` — zero errors
- [ ] `{config.stack.test_cmd}` — all pass
- [ ] All ACs checked
```

**Critical rules:**
- ALL `gh api` calls use `{config.repo.owner}/{config.repo.name}` — zero hardcoded repo names
- ALL build/lint/test commands use `{config.stack.*}` — not `npm run X`
- ALL branch references use `{config.repo.develop_branch}` — not `develop`

---

## STEP 9 — Present Plan

Show the full plan.

**G-05: "Does this plan look correct? Approve it or tell me what to change."**

Wait for explicit approval.

---

## STEP 10 — Confirmation Loop

- **Approved** → proceed to Step 11
- **Changes requested** → update plan → re-present (repeat Step 9)
- **Question** → answer → update if needed → re-present

---

## STEP 11 — Save Plan

[WRITE] Save to `docs/plans/issue-<n>/plan.md`:

```yaml
---
issue: <number>
title: <title>
branch: <branch-name>
milestone: <milestone>
status: confirmed
confirmed_at: <timestamp>
---
```

Followed by full plan content.

---

## STEP 12 — Generate Implementation Doc

[WRITE] Create `docs/plans/issue-<n>/implementation.md`:

Every implementation step must have:
- Exact command or code snippet
- Expected output
- Status: `pending`

Include:
- Progress table at top (Step | Description | Status)
- Deviations section at bottom (empty initially)

Must reflect version validation findings from Step 7.

---

## STEP 13 — Review Implementation Doc

[DELEGATE][SMART-MODEL] Review the implementation doc. Reviewer checks:
- All steps complete with exact commands?
- File contents missing anywhere?
- Technical errors?
- Expected output defined for every step?
- Could a low-context model follow this without guessing?

**PASS/FAIL only.** Fix and retry until PASS.

---

## STEP 14 — User Confirms Implementation Doc

Present the implementation doc.

**G-05 (impl doc approval): "Does the implementation doc look correct? (yes/no)"**

Wait for explicit confirmation.

---

## STEP 15 — Commit

[SHELL] Commit plan + implementation doc:
```bash
git add docs/plans/issue-<n>/
git commit -m "docs(plan): add plan and implementation doc for issue #<n>

<one-line summary of what will be built>

Refs #<n>"
```

---

## STEP 16 — Handoff

```
Planning complete. Next step: run /dev-implement.

Issue       : #<number> <title>
Plan        : docs/plans/issue-<n>/plan.md
Impl doc    : docs/plans/issue-<n>/implementation.md
Steps       : <count>
Model tip   : Fast model recommended — doc is fully detailed.
```
