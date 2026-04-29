---
name: dev-plan
description: Use when planning a GitHub issue — brainstorm, design review, security assessment, version validation, then emit three Kiro-style spec artifacts (requirements.md, design.md, tasks.md) that downstream skills consume
---

# dev-plan: Issue Planning (Spec-First)

Brainstorm, design review, security assessment, version validation, then generate three spec artifacts:
- `docs/plans/issue-<n>/requirements.md` — EARS-format acceptance criteria with stable REQ-IDs
- `docs/plans/issue-<n>/design.md` — architecture, data contracts, key decisions, security
- `docs/plans/issue-<n>/tasks.md` — atomic, ordered task groups with `parallel: true|false` flags

Templates: `templates/requirements.md`, `templates/design.md`, `templates/tasks.md`.

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

## RATIONALIZATION PREVENTION

Before executing any step, check your reasoning against this table. These are **structural rules** — they cannot be overridden.

| Thought | Why it's wrong | What to do |
|---------|---------------|------------|
| "I already understand the code, skip reading" | Assumptions from memory diverge from actual code state | Read the relevant files every time (Step 3) |
| "The issue is simple, skip brainstorming" | Simple-seeming issues hide edge cases discovered through questions | Ask all brainstorming questions (Step 5) |
| "Security doesn't apply to this issue" | Every change has a threat surface — even docs can leak info or enable injection | Complete the security assessment (Step 7) |
| "Version validation isn't needed here" | Stale dependency assumptions cause subtle runtime failures | Run version validation (Step 8) |
| "The user will approve, skip the confirmation gate" | User confirmation is a required checkpoint, not a rubber stamp | Wait for explicit approval at every gate |
| "EARS format is overhead, plain ACs are fine" | Plain ACs lose traceability — REQ-IDs are referenced by design.md, tasks.md, and tests | Use EARS templates with stable REQ-IDs (Step 9a) |
| "I can mark all groups parallel: true to go faster" | Wrongly-flagged groups create merge conflicts and broken state in dev-parallel | Only flag groups with zero shared files/state as parallel: true (Step 9c) |
| "tasks.md doesn't need atomicity review" | Non-atomic tasks make commit history unreadable and bisect impossible | Run the atomicity review (Step 13) |

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
Step 9/17: Generate Three Artifacts (Requirements + Design + Tasks)
Step 10/17: Present Plan
Step 11/17: Confirmation Loop
Step 12/17: Save Three Artifacts
Step 13/17: Validate tasks.md Atomicity
Step 14/17: Review tasks.md
Step 15/17: User Confirms tasks.md
Step 16/17: Commit
Step 17/17: Handoff
```
(Graceful degradation: skip if TodoWrite unavailable)

[PROGRESS] Mark Step 1/17 `completed`.

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

[PROGRESS] Mark Step 2/17 `completed`.

---

## STEP 3 — Read Relevant Code

[DELEGATE][FAST-MODEL] Read existing source files relevant to the issue (based on labels and title). Read at minimum 3–5 files. Do not skip — makes questions and plan accurate.

[PROGRESS] Mark Step 3/17 `completed`.

---

## STEP 4 — Scope Validation

Check:
- **Clarity**: Can you describe the issue in one sentence?
- **Feasibility**: Are acceptance criteria present? Any blockers?
- **Architecture fit**: New feature, bug fix, or refactor?

If unclear on any point → ask user before proceeding.

[PROGRESS] Mark Step 4/17 `completed`.

---

## STEP 5 — Brainstorming Questions

Ask 5–7 targeted questions one at a time. Tailor to issue labels:
- `api` → endpoint design, auth, versioning
- `db` → schema, migrations, indexes
- `test` → coverage strategy, fixtures
- `auth` → token handling, permissions
- `infra` → deployment, config management

Always ask:
- Which acceptance criteria from the SRS apply here? (you'll convert these to EARS REQ-IDs in Step 9a)
- Anything specific about the existing codebase I should know?
- Does this align with existing patterns in the codebase?

[PROGRESS] Mark Step 5/17 `completed`.

---

## STEP 6 — Design Review

[READ] 2–3 similar implementations in the codebase. Check:
- Pattern alignment
- Tradeoffs
- Architectural implications
- Standards compliance

Note findings — these feed Step 9b (Generate Design).

### Step 6b — ADR Check

If the design review identifies any of the following → flag for ADR:
- New technology choice or library adoption
- Architectural pattern decision (e.g., event-driven vs. request/response)
- Significant tradeoff with long-term consequences
- Breaking change to existing interfaces or contracts

Ask user: "This issue involves an architectural decision. Generate an ADR? (yes/no)"
- **yes** → after artifacts are saved (Step 12), invoke `/paadhai:dev-adr` with the decision context
- **no** → note "ADR: declined" in design.md

[PROGRESS] Mark Step 6/17 `completed`.

---

## STEP 7 — Security Threat Assessment

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

Findings feed `design.md § Security Considerations` (Step 9b).

If no security-relevant attack surfaces are identified → note: "No security-relevant attack surfaces identified for this issue."

[PROGRESS] Mark Step 7/17 `completed`.

---

## STEP 8 — Version Validation

[DELEGATE][FAST-MODEL][SEARCH] Check current stable versions of core packages used in this issue. Verify:
- Breaking changes since current version
- Config compatibility
- Platform-specific issues

Skip for well-known stable APIs (e.g., standard library functions). Findings feed `tasks.md` (Step 9c) — they may add or modify tasks.

[PROGRESS] Mark Step 8/17 `completed`.

---

## STEP 9 — Generate Three Artifacts

Produce the content for all three artifacts. They will be written to disk in Step 12.

### Step 9a — Generate `requirements.md`

[READ] `templates/requirements.md` for structure.

Convert acceptance criteria from the issue body and Step 5 brainstorming into **EARS format**:
- "The system shall <action>"
- "When <trigger>, the system shall <action>"
- "The system shall NOT <forbidden behavior>"

Assign **stable IDs**: `REQ-1`, `REQ-2`, … These IDs are referenced in design.md, tasks.md, and the test plan. Do not renumber after commit.

Required sections: Overview, Context, Acceptance Criteria, Definitions, Assumptions. Optional: Non-Functional Requirements.

### Step 9b — Generate `design.md`

[READ] `templates/design.md` for structure.

Combine findings from Step 6 (Design Review) and Step 7 (Security Threat Assessment).

Required sections: Overview, Architecture, Data Structures / API Contracts, Flow, Key Design Decisions, Security Considerations. Optional: Error Handling Strategy, Testing Strategy Outline.

For each design decision: capture **chosen approach**, **why** (link to REQ-IDs where applicable), **alternatives rejected**.

### Step 9c — Generate `tasks.md`

[READ] `templates/tasks.md` for structure.

Break implementation into **atomic, ordered tasks**. Group by logical concern (e.g., "Core infra", "Endpoints", "Integration").

For each group, set:
- **`parallel: true|false`** — `true` only if the group has zero shared files/state with siblings AND its tasks have no cross-group ordering constraint. When in doubt, set `false`.
- **`depends_on:`** — list of group names this group requires
- **Files** — expected files created/modified per task
- **Reference** — REQ-IDs from requirements.md and design decision IDs from design.md
- **Status** — `pending`

`dev-implement` reads this file and **auto-routes parallel-flagged groups** to `dev-parallel`. Mis-flagging a group will cause merge conflicts. Be conservative.

**Critical rules** for all 3 artifacts:
- ALL `gh api` calls use `{config.repo.owner}/{config.repo.name}` — zero hardcoded repo names
- ALL build/lint/test commands use `{config.stack.*}`
- ALL branch references use `{config.repo.develop_branch}`

[PROGRESS] Mark Step 9/17 `completed`.

---

## STEP 10 — Present Plan

Show summaries of all three artifacts:
- requirements.md: list of REQ-IDs and their one-line summaries
- design.md: architecture summary, key decisions, security checklist
- tasks.md: group structure with parallel flags and total task count

**G-05: "Do these three artifacts look correct? Approve them or tell me what to change."**

Wait for explicit approval.

[PROGRESS] Mark Step 10/17 `completed`.

---

## STEP 11 — Confirmation Loop

- **Approved** → proceed to Step 12
- **Changes requested** → update the relevant artifact(s) → re-present (repeat Step 10)
- **Question** → answer → update if needed → re-present

[PROGRESS] Mark Step 11/17 `completed`.

---

## STEP 12 — Save Three Artifacts

[WRITE] all three files atomically:

```
docs/plans/issue-<n>/requirements.md
docs/plans/issue-<n>/design.md
docs/plans/issue-<n>/tasks.md
```

Each file follows its template structure (no frontmatter on requirements.md and design.md; tasks.md has frontmatter `issue`, `title`, `total_groups`).

If Step 6b ADR was approved → invoke `/paadhai:dev-adr` now with the architectural decision context.

[PROGRESS] Mark Step 12/17 `completed`.

---

## STEP 13 — Validate tasks.md Atomicity

[DELEGATE][SMART-MODEL] Self-review tasks.md for the following:
- Every task has a verification step (command or check)
- Every task references at least one REQ-ID or design decision
- Groups marked `parallel: true` have zero file/state overlap with siblings
- Group dependencies form a DAG (no cycles)
- No group is empty or contains a single trivial task

If any check fails → fix tasks.md and re-validate.

[PROGRESS] Mark Step 13/17 `completed`.

---

## STEP 14 — Review tasks.md

[DELEGATE][SMART-MODEL] Review tasks.md from the perspective of a fresh implementer (low-context model):
- Could a stateless agent execute this without guessing?
- Are file paths exact?
- Are commands runnable as-is?
- Are expected outputs defined?

**PASS/FAIL only.** Fix and retry until PASS.

[PROGRESS] Mark Step 14/17 `completed`.

---

## STEP 15 — User Confirms tasks.md

Present tasks.md.

**G-05 (tasks approval): "Does tasks.md look correct? (yes/no)"**

Wait for explicit confirmation.

[PROGRESS] Mark Step 15/17 `completed`.

---

## STEP 16 — Commit

[SHELL] Commit all three artifacts:
```bash
git add docs/plans/issue-<n>/
git commit -m "docs(plan): add spec artifacts for issue #<n>

requirements.md, design.md, tasks.md generated by /paadhai:dev-plan.

Refs #<n>"
```

[PROGRESS] Mark Step 16/17 `completed`.

---

## STEP 17 — Handoff

```
Planning complete. Three spec artifacts saved.

Issue        : #<number> <title>
Requirements : docs/plans/issue-<n>/requirements.md (<REQ-count> REQ-IDs)
Design       : docs/plans/issue-<n>/design.md
Tasks        : docs/plans/issue-<n>/tasks.md (<group-count> groups, <parallel-count> parallel)

Next step: run /paadhai:dev-test to generate test plan and stubs from requirements.md.
```

[PROGRESS] Mark Step 17/17 `completed`.
