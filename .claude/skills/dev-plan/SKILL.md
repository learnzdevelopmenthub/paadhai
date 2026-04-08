---
name: dev-plan
description: Use when planning GitHub issues — brainstorm, design review, security assessment, version validation, generate plan + implementation doc
---

# dev-plan: Issue Planning

Brainstorm, design review, security assessment, version validation, generate plan + implementation doc for an issue.

**Output:** `docs/plans/issue-<n>/plan.md` + `docs/plans/issue-<n>/implementation.md`

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
dev-plan | Issue #<number> — <title>
17 steps | Branch: <branch>
────────────────────────────────────────
```

Display (no issue context — not on feature/fix branch):
```
────────────────────────────────────────
dev-plan
17 steps | Branch: <branch>
────────────────────────────────────────
```

If `gh api` fails, degrade gracefully — show banner without issue title.

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Store config values:
- `{config.repo.owner}` / `{config.repo.name}`
- `{config.repo.develop_branch}`
- `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` / `{config.stack.test_cmd}`

### Progress Tracking

[PROGRESS] Initialize TodoWrite checklist — 17 items, all `pending`:
```
Step 1/17: Load Config
Step 2/17: Identify Issue
Step 3/17: Read Relevant Code
Step 4/17: Scope Validation
Step 5/17: Brainstorming Questions
Step 6/17: Design Review
Step 7/17: Security Threat Assessment
Step 8/17: Version Validation
Step 9/17: Generate Plan
Step 10/17: Present Plan
Step 11/17: Confirmation Loop
Step 12/17: Save Plan
Step 13/17: Generate Implementation Doc
Step 14/17: Review Implementation Doc
Step 15/17: User Confirms Implementation Doc
Step 16/17: Commit
Step 17/17: Handoff
```
(Graceful degradation: skip if TodoWrite unavailable)

[PROGRESS] Mark Step 1/17 `completed`:
```
Step 1/17: Load Config [completed]
Files read: .paadhai.json
```

---

## STEP 2 — Identify Issue

[PROGRESS] Mark Step 2/17 `in_progress`: `Step 2/17: Identify Issue [in_progress]`

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

[PROGRESS] Mark Step 2/17 `completed`: `Step 2/17: Identify Issue [completed]`
`Issue details fetched`

---

## STEP 3 — Read Relevant Code

[PROGRESS] Mark Step 3/17 `in_progress`: `Step 3/17: Read Relevant Code [in_progress]`

[DELEGATE][FAST-MODEL] Read existing source files relevant to the issue (based on labels and title). Read at minimum 3–5 files. Do not skip — makes questions and plan accurate.

[PROGRESS] Mark Step 3/17 `completed`: `Step 3/17: Read Relevant Code [completed]`
`Files read: <list of files read>`

---

## STEP 4 — Scope Validation

[PROGRESS] Mark Step 4/17 `in_progress`: `Step 4/17: Scope Validation [in_progress]`

Check:
- **Clarity**: Can you describe the issue in one sentence?
- **Feasibility**: Are acceptance criteria present? Any blockers?
- **Architecture fit**: New feature, bug fix, or refactor?

If unclear on any point → ask user before proceeding.

[PROGRESS] Mark Step 4/17 `completed`: `Step 4/17: Scope Validation [completed]`
`Scope validated`

---

## STEP 5 — Brainstorming Questions

[PROGRESS] Mark Step 5/17 `in_progress`: `Step 5/17: Brainstorming Questions [in_progress]`

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

[PROGRESS] Mark Step 5/17 `completed`: `Step 5/17: Brainstorming Questions [completed]`
`Questions asked`

---

## STEP 6 — Design Review

[PROGRESS] Mark Step 6/17 `in_progress`: `Step 6/17: Design Review [in_progress]`

[READ] 2–3 similar implementations in the codebase. Check:
- Pattern alignment
- Tradeoffs
- Architectural implications
- Standards compliance

Note findings for the plan.

### Step 6b — ADR Check

If the design review identifies any of the following → flag for ADR:
- New technology choice or library adoption
- Architectural pattern decision (e.g., event-driven vs. request/response)
- Significant tradeoff with long-term consequences
- Breaking change to existing interfaces or contracts

Ask user: "This issue involves an architectural decision. Generate an ADR? (yes/no)"
- **yes** → after plan is saved (Step 12), invoke `/paadhai:dev-adr` with the decision context
- **no** → note "ADR: declined" in the plan

[PROGRESS] Mark Step 6/17 `completed`: `Step 6/17: Design Review [completed]`
`Design review complete`

---

## STEP 7 — Security Threat Assessment

[PROGRESS] Mark Step 7/17 `in_progress`: `Step 7/17: Security Threat Assessment [in_progress]`

[DELEGATE][SMART-MODEL] Perform a threat model based on issue labels and design findings:

**Label-based checks:**
- `api` → injection vulnerabilities (SQLi, XSS, command injection), authentication bypass, rate limiting, versioning exposure
- `db` → SQL injection, privilege escalation, data exposure in error messages
- `auth` → token handling, session fixation, privilege escalation, insecure storage
- `infra` → secrets/credentials exposure, insecure configuration, network exposure

**General checks (always run):**
- Input validation boundaries
- Error message information leakage
- Dependency trust (new packages being added)
- Authorization checks on new endpoints/actions

**Output format:**
```
## Security Considerations

### Attack Surfaces
- <surface>: <risk level> — <description>

### Mitigations
- <mitigation description>

### Security Checklist
- [ ] Input validated at all entry points
- [ ] No sensitive data in error messages
- [ ] Authorization checked before data access
- [ ] <issue-specific items>
```

If no security-relevant attack surfaces are identified → output:
> No security-relevant attack surfaces identified for this issue.

[PROGRESS] Mark Step 7/17 `completed`: `Step 7/17: Security Threat Assessment [completed]`
`Security assessment complete`

---

## STEP 8 — Version Validation

[PROGRESS] Mark Step 8/17 `in_progress`: `Step 8/17: Version Validation [in_progress]`

[DELEGATE][FAST-MODEL][SEARCH] Check current stable versions of core packages used in this issue. Verify:
- Breaking changes since current version
- Config compatibility
- Platform-specific issues

Skip for well-known stable APIs (e.g., standard library functions).

[PROGRESS] Mark Step 8/17 `completed`: `Step 8/17: Version Validation [completed]`
`Version validation complete`

---

## STEP 9 — Generate Plan

[PROGRESS] Mark Step 9/17 `in_progress`: `Step 9/17: Generate Plan [in_progress]`

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

## Security Considerations
<security checklist from Step 7, or "No security-relevant attack surfaces identified">

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

[PROGRESS] Mark Step 9/17 `completed`: `Step 9/17: Generate Plan [completed]`
`Plan generated`

---

## STEP 10 — Present Plan

[PROGRESS] Mark Step 10/17 `in_progress`: `Step 10/17: Present Plan [in_progress]`

Show the full plan.

**G-05: "Does this plan look correct? Approve it or tell me what to change."**

Wait for explicit approval.

[PROGRESS] Mark Step 10/17 `completed`: `Step 10/17: Present Plan [completed]`
`Plan presented`

---

## STEP 11 — Confirmation Loop

[PROGRESS] Mark Step 11/17 `in_progress`: `Step 11/17: Confirmation Loop [in_progress]`

- **Approved** → proceed to Step 12
- **Changes requested** → update plan → re-present (repeat Step 10)
- **Question** → answer → update if needed → re-present

[PROGRESS] Mark Step 11/17 `completed`: `Step 11/17: Confirmation Loop [completed]`
`Plan approved`

---

## STEP 12 — Save Plan

[PROGRESS] Mark Step 12/17 `in_progress`: `Step 12/17: Save Plan [in_progress]`

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

If Step 6b ADR was approved → invoke `/paadhai:dev-adr` now with the architectural decision context.

[PROGRESS] Mark Step 12/17 `completed`: `Step 12/17: Save Plan [completed]`
`Files changed: docs/plans/issue-<n>/plan.md`

---

## STEP 13 — Generate Implementation Doc

[PROGRESS] Mark Step 13/17 `in_progress`: `Step 13/17: Generate Implementation Doc [in_progress]`

[WRITE] Create `docs/plans/issue-<n>/implementation.md`:

Every implementation step must have:
- Exact command or code snippet
- Expected output
- Status: `pending`

Include:
- Progress table at top (Step | Description | Status)
- Deviations section at bottom (empty initially)

Must reflect version validation findings from Step 8.

[PROGRESS] Mark Step 13/17 `completed`: `Step 13/17: Generate Implementation Doc [completed]`
`Files changed: docs/plans/issue-<n>/implementation.md`

---

## STEP 14 — Review Implementation Doc

[PROGRESS] Mark Step 14/17 `in_progress`: `Step 14/17: Review Implementation Doc [in_progress]`

[READ] `implementation-reviewer-prompt.md` — load review criteria.

[DELEGATE][SMART-MODEL] Review the implementation doc using the loaded reviewer prompt. Reviewer checks:
- All steps complete with exact commands?
- File contents missing anywhere?
- Technical errors?
- Expected output defined for every step?
- Could a low-context model follow this without guessing?

**PASS/FAIL only.** Fix and retry until PASS.

[PROGRESS] Mark Step 14/17 `completed`: `Step 14/17: Review Implementation Doc [completed]`
`Review: PASS`

---

## STEP 15 — User Confirms Implementation Doc

[PROGRESS] Mark Step 15/17 `in_progress`: `Step 15/17: User Confirms Implementation Doc [in_progress]`

Present the implementation doc.

**G-05 (impl doc approval): "Does the implementation doc look correct? (yes/no)"**

Wait for explicit confirmation.

[PROGRESS] Mark Step 15/17 `completed`: `Step 15/17: User Confirms Implementation Doc [completed]`
`Implementation doc approved`

---

## STEP 16 — Commit

[PROGRESS] Mark Step 16/17 `in_progress`: `Step 16/17: Commit [in_progress]`

[SHELL] Commit plan + implementation doc:
```bash
git add docs/plans/issue-<n>/
git commit -m "docs(plan): add plan and implementation doc for issue #<n>

<one-line summary of what will be built>

Refs #<n>"
```

[PROGRESS] Mark Step 16/17 `completed`: `Step 16/17: Commit [completed]`
`Committed: docs/plans/issue-<n>/`

---

## STEP 17 — Handoff

[PROGRESS] Mark Step 17/17 `in_progress`: `Step 17/17: Handoff [in_progress]`

```
Planning complete. Next step: run /dev-test to create the test plan and stubs.

Issue       : #<number> <title>
Plan        : docs/plans/issue-<n>/plan.md
Impl doc    : docs/plans/issue-<n>/implementation.md
Steps       : <count>
Model tip   : Fast model recommended — doc is fully detailed.
```

[PROGRESS] Mark Step 17/17 `completed`: `Step 17/17: Handoff [completed]`
`Output displayed`
