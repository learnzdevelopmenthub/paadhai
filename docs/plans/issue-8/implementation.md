# Implementation: Issue #8 — Add [PROGRESS] marker and TodoWrite integration to multi-step skills

## Progress Table

| Step | Description | Status |
|------|-------------|--------|
| 1 | Add `[PROGRESS]` marker to `references/claude-tools.md` | done |
| 2 | Instrument `dev-implement/SKILL.md` | done |
| 3 | Instrument `dev-parallel/SKILL.md` | done |
| 4 | Instrument `dev-plan/SKILL.md` | done |
| 5 | Instrument `project-plan/SKILL.md` | pending |
| 6 | Instrument `release-plan/SKILL.md` | pending |
| 7 | Instrument `dev-release/SKILL.md` | pending |

---

## Conventions used throughout this doc

### [in_progress] marker format
Insert immediately **after** the `## STEP N — <title>` heading line (before the first line of that step's body):
```
[PROGRESS] Mark Step N/Total `in_progress`:
`Step N/Total: <step title> [in_progress]`
```

### [completed] marker format
Insert immediately **before** the `---` separator that closes the step:
```
[PROGRESS] Mark Step N/Total `completed`:
`Step N/Total: <step title> [completed]`
`<summary line — see per-step table in each step below>`
```

### Summary line rules
| Step type | Summary line |
|-----------|-------------|
| Config load (reads .paadhai.json) | `Files read: .paadhai.json` |
| Read files | `Files read: <list of files read>` |
| Write/edit files | `Files changed: <list of files changed>` |
| Analysis / decision / gate | `<one-word past-tense action, e.g. "Analysis complete", "Decision made", "Gate passed">` |
| Shell commands (build/lint/test) | `Build: ✓  Lint: ✓  Tests: <count> passing` |
| Display output to user | `Output displayed` |

---

## Step 1 — Add `[PROGRESS]` marker to `references/claude-tools.md`

**File:** `references/claude-tools.md`

### 1a — Extend the marker table

In `references/claude-tools.md`, find this exact line:
```
| `[SMART-MODEL]` | `model: "opus"` parameter on Agent tool | Use most capable model |
```

Insert the following new row immediately after it:
```
| `[PROGRESS]` | `TodoWrite` tool | Create and update a live step checklist. Graceful degradation: skip if TodoWrite unavailable |
```

### 1b — Append [PROGRESS] Convention section

Find this exact text at the end of the file:
```
No fallback needed — Claude Code supports all markers natively.
```

Insert the following block immediately after it (add a blank line before the new section):

```markdown
## [PROGRESS] Convention

`[PROGRESS]` maps to the `TodoWrite` tool. Use it to maintain a live checklist of steps during skill execution.

### Initialization (at skill start, after config is loaded)

Create one TodoWrite item per numbered STEP in the skill. All items start as `pending`.

Item format:
```
Step N/Total: <step title>
```

### Updating items during execution

At the **start** of each step — update that item to `in_progress`:
```
Step 3/10: Analyze Task Dependencies [in_progress]
```

At the **end** of each step — update that item to `completed`, embedding result:
```
Step 3/10: Analyze Task Dependencies [completed]
Analysis complete
```

For steps that read files:
```
Step 2/10: Load Implementation Doc [completed]
Files read: docs/plans/issue-8/implementation.md, docs/plans/issue-8/plan.md
```

For steps that change files or run build/lint:
```
Step 7/10: Implementation Loop [completed]
Files changed: src/auth.ts, src/types.ts
Build: ✓  Lint: ✓
```

### Graceful degradation

If the TodoWrite tool is unavailable, skip all `[PROGRESS]` calls silently and continue execution. Never block on progress tracking.
```

**Verification:**
```bash
grep -c "PROGRESS" references/claude-tools.md
```
Expected output: `3` (one in the table row, one in the section heading, one in the "Subagent Support" area — or at minimum `2` for table row + section heading).

**Commit:**
```bash
git add references/claude-tools.md
git commit -m "docs(markers): add [PROGRESS] marker mapping to TodoWrite tool

Defines item format, in_progress/completed update convention,
and graceful degradation behavior.

Refs #8"
```

**Status:** done

---

## Step 2 — Instrument `dev-implement/SKILL.md`

**File:** `.claude/skills/dev-implement/SKILL.md`

### 2a — Insert initialization block

Find this exact text in STEP 1:
```
- `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` / `{config.stack.test_cmd}`
```

Insert the following block immediately after that line, before the `---` separator that opens STEP 2:

```markdown
### Progress Tracking

[PROGRESS] Initialize TodoWrite checklist — 10 items, all `pending`:
```
Step 1/10: Load Config
Step 2/10: Load Implementation Doc
Step 3/10: Analyze Task Dependencies
Step 4/10: Choose Execution Path
Step 5/10: Pre-Implementation Check
Step 6/10: Route Execution
Step 7/10: Implementation Loop
Step 8/10: Full Test Run
Step 9/10: Summary
Step 10/10: Handoff
```
(Graceful degradation: skip if TodoWrite unavailable)

[PROGRESS] Mark Step 1/10 `completed`:
```
Step 1/10: Load Config [completed]
Files read: .paadhai.json
```
```

### 2b — Per-step [PROGRESS] markers

Apply `[in_progress]` at start and `[completed]` at end for STEP 2–10 using the exact text below.

**STEP 2:**
- Start: `[PROGRESS] Mark Step 2/10 \`in_progress\`: \`Step 2/10: Load Implementation Doc [in_progress]\``
- End: `[PROGRESS] Mark Step 2/10 \`completed\`: \`Step 2/10: Load Implementation Doc [completed]\` \`Files read: docs/plans/issue-<n>/implementation.md, docs/plans/issue-<n>/plan.md\``

**STEP 3:**
- Start: `[PROGRESS] Mark Step 3/10 \`in_progress\`: \`Step 3/10: Analyze Task Dependencies [in_progress]\``
- End: `[PROGRESS] Mark Step 3/10 \`completed\`: \`Step 3/10: Analyze Task Dependencies [completed]\` \`Analysis complete\``

**STEP 4:**
- Start: `[PROGRESS] Mark Step 4/10 \`in_progress\`: \`Step 4/10: Choose Execution Path [in_progress]\``
- End: `[PROGRESS] Mark Step 4/10 \`completed\`: \`Step 4/10: Choose Execution Path [completed]\` \`Decision made\``

**STEP 5:**
- Start: `[PROGRESS] Mark Step 5/10 \`in_progress\`: \`Step 5/10: Pre-Implementation Check [in_progress]\``
- End: `[PROGRESS] Mark Step 5/10 \`completed\`: \`Step 5/10: Pre-Implementation Check [completed]\` \`Branch verified, working tree clean\``

**STEP 6:**
- Start: `[PROGRESS] Mark Step 6/10 \`in_progress\`: \`Step 6/10: Route Execution [in_progress]\``
- End: `[PROGRESS] Mark Step 6/10 \`completed\`: \`Step 6/10: Route Execution [completed]\` \`Route determined\``

**STEP 7:**
- Start: `[PROGRESS] Mark Step 7/10 \`in_progress\`: \`Step 7/10: Implementation Loop [in_progress]\``
- End: `[PROGRESS] Mark Step 7/10 \`completed\`: \`Step 7/10: Implementation Loop [completed]\` \`Files changed: <list from step>  Build: ✓  Lint: ✓\``

**STEP 8:**
- Start: `[PROGRESS] Mark Step 8/10 \`in_progress\`: \`Step 8/10: Full Test Run [in_progress]\``
- End: `[PROGRESS] Mark Step 8/10 \`completed\`: \`Step 8/10: Full Test Run [completed]\` \`Build: ✓  Lint: ✓  Tests: <count> passing\``

**STEP 9:**
- Start: `[PROGRESS] Mark Step 9/10 \`in_progress\`: \`Step 9/10: Summary [in_progress]\``
- End: `[PROGRESS] Mark Step 9/10 \`completed\`: \`Step 9/10: Summary [completed]\` \`Output displayed\``

**STEP 10:**
- Start: `[PROGRESS] Mark Step 10/10 \`in_progress\`: \`Step 10/10: Handoff [in_progress]\``
- End: `[PROGRESS] Mark Step 10/10 \`completed\`: \`Step 10/10: Handoff [completed]\` \`Output displayed\``

**Verification:**
```bash
grep -c "PROGRESS" .claude/skills/dev-implement/SKILL.md
```
Expected: `20` (1 init + 1 step-1-complete + 9 steps × 2)

**Commit:**
```bash
git add .claude/skills/dev-implement/SKILL.md
git commit -m "feat(dev-implement): add TodoWrite [PROGRESS] step tracking

Creates 10-item checklist at start; marks each step in_progress
then completed with files/build/lint result.

Refs #8"
```

**Status:** done

---

## Step 3 — Instrument `dev-parallel/SKILL.md`

**File:** `.claude/skills/dev-parallel/SKILL.md`

### 3a — Insert initialization block

Find this exact text in STEP 1:
```
- `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` / `{config.stack.test_cmd}`
- `{config.repo.owner}` / `{config.repo.name}`
```

Insert the following block immediately after those lines, before the `---` separator that opens STEP 2:

```markdown
### Progress Tracking

[PROGRESS] Initialize TodoWrite checklist — 14 items, all `pending`:
```
Step 1/14: Load Config
Step 2/14: Load Implementation Doc
Step 3/14: Group Independent Tasks
Step 4/14: Generate Subagent Prompts
Step 5/14: Dispatch Gate
Step 6/14: Dispatch Subagents (after G-11)
Step 7/14: Collect Results
Step 8/14: Stage 1: Spec Compliance Review
Step 9/14: Stage 2: Code Quality Review
Step 10/14: Fix Loop
Step 11/14: Update Implementation Doc
Step 12/14: Full Test Run
Step 13/14: Summary
Step 14/14: Handoff
```
(Graceful degradation: skip if TodoWrite unavailable)

[PROGRESS] Mark Step 1/14 `completed`:
```
Step 1/14: Load Config [completed]
Files read: .paadhai.json
```
```

### 3b — Per-step [PROGRESS] markers

Apply `[in_progress]` at start and `[completed]` at end for STEP 2–14:

| STEP | in_progress text | completed summary |
|------|-----------------|-------------------|
| 2 | `Step 2/14: Load Implementation Doc [in_progress]` | `Files read: docs/plans/issue-<n>/implementation.md, docs/plans/issue-<n>/plan.md` |
| 3 | `Step 3/14: Group Independent Tasks [in_progress]` | `Task groups identified` |
| 4 | `Step 4/14: Generate Subagent Prompts [in_progress]` | `Prompts generated` |
| 5 | `Step 5/14: Dispatch Gate [in_progress]` | `Gate passed` |
| 6 | `Step 6/14: Dispatch Subagents (after G-11) [in_progress]` | `Subagents dispatched` |
| 7 | `Step 7/14: Collect Results [in_progress]` | `Results collected` |
| 8 | `Step 8/14: Stage 1: Spec Compliance Review [in_progress]` | `Spec review: PASS` |
| 9 | `Step 9/14: Stage 2: Code Quality Review [in_progress]` | `Code review: PASS` |
| 10 | `Step 10/14: Fix Loop [in_progress]` | `Fixes applied` |
| 11 | `Step 11/14: Update Implementation Doc [in_progress]` | `Files changed: docs/plans/issue-<n>/implementation.md` |
| 12 | `Step 12/14: Full Test Run [in_progress]` | `Build: ✓  Lint: ✓  Tests: <count> passing` |
| 13 | `Step 13/14: Summary [in_progress]` | `Output displayed` |
| 14 | `Step 14/14: Handoff [in_progress]` | `Output displayed` |

Each entry inserts:
- After heading: `[PROGRESS] Mark Step N/14 \`in_progress\`: \`<in_progress text>\``
- Before `---`: `[PROGRESS] Mark Step N/14 \`completed\`: \`<in_progress text with [in_progress] replaced by [completed]>\` \`<completed summary>\``

**Verification:**
```bash
grep -c "PROGRESS" .claude/skills/dev-parallel/SKILL.md
```
Expected: `28` (1 init + 1 step-1-complete + 13 steps × 2)

**Commit:**
```bash
git add .claude/skills/dev-parallel/SKILL.md
git commit -m "feat(dev-parallel): add TodoWrite [PROGRESS] step tracking

Creates 14-item checklist at start; marks each step in_progress
then completed.

Refs #8"
```

**Status:** done

---

## Step 4 — Instrument `dev-plan/SKILL.md`

**File:** `.claude/skills/dev-plan/SKILL.md`

### 4a — Insert initialization block

Find this exact text in STEP 1:
```
- `{config.repo.develop_branch}`
- `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` / `{config.stack.test_cmd}`
```

Insert the following block immediately after those lines, before the `---` separator that opens STEP 2:

```markdown
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
```

### 4b — Per-step [PROGRESS] markers

Apply `[in_progress]` at start and `[completed]` at end for STEP 2–17:

| STEP | in_progress text | completed summary |
|------|-----------------|-------------------|
| 2 | `Step 2/17: Identify Issue [in_progress]` | `Issue details fetched` |
| 3 | `Step 3/17: Read Relevant Code [in_progress]` | `Files read: <list of files read>` |
| 4 | `Step 4/17: Scope Validation [in_progress]` | `Scope validated` |
| 5 | `Step 5/17: Brainstorming Questions [in_progress]` | `Questions asked` |
| 6 | `Step 6/17: Design Review [in_progress]` | `Design review complete` |
| 7 | `Step 7/17: Security Threat Assessment [in_progress]` | `Security assessment complete` |
| 8 | `Step 8/17: Version Validation [in_progress]` | `Version validation complete` |
| 9 | `Step 9/17: Generate Plan [in_progress]` | `Plan generated` |
| 10 | `Step 10/17: Present Plan [in_progress]` | `Plan presented` |
| 11 | `Step 11/17: Confirmation Loop [in_progress]` | `Plan approved` |
| 12 | `Step 12/17: Save Plan [in_progress]` | `Files changed: docs/plans/issue-<n>/plan.md` |
| 13 | `Step 13/17: Generate Implementation Doc [in_progress]` | `Files changed: docs/plans/issue-<n>/implementation.md` |
| 14 | `Step 14/17: Review Implementation Doc [in_progress]` | `Review: PASS` |
| 15 | `Step 15/17: User Confirms Implementation Doc [in_progress]` | `Implementation doc approved` |
| 16 | `Step 16/17: Commit [in_progress]` | `Committed: docs/plans/issue-<n>/` |
| 17 | `Step 17/17: Handoff [in_progress]` | `Output displayed` |

Each entry inserts:
- After heading: `[PROGRESS] Mark Step N/17 \`in_progress\`: \`<in_progress text>\``
- Before `---`: `[PROGRESS] Mark Step N/17 \`completed\`: \`<in_progress text with [in_progress] replaced by [completed]>\` \`<completed summary>\``

**Verification:**
```bash
grep -c "PROGRESS" .claude/skills/dev-plan/SKILL.md
```
Expected: `34` (1 init + 1 step-1-complete + 16 steps × 2)

**Commit:**
```bash
git add .claude/skills/dev-plan/SKILL.md
git commit -m "feat(dev-plan): add TodoWrite [PROGRESS] step tracking

Creates 17-item checklist at start; marks each step in_progress
then completed.

Refs #8"
```

**Status:** done

---

## Step 5 — Instrument `project-plan/SKILL.md`

**File:** `.claude/skills/project-plan/SKILL.md`

### 5a — Insert initialization block

Find this exact text in STEP 1:
```
- If `project_version` absent → `{srs_path}` = `docs/srs.md`
```

Insert the following block immediately after that line, before the `---` separator that opens STEP 2:

```markdown
### Progress Tracking

[PROGRESS] Initialize TodoWrite checklist — 10 items, all `pending`:
```
Step 1/10: Load Config
Step 2/10: Read Existing Context
Step 3/10: Product Description
Step 4/10: Clarifying Questions
Step 5/10: Research
Step 6/10: Generate SRS
Step 7/10: Present SRS
Step 8/10: Revision Loop
Step 9/10: Save
Step 10/10: Handoff
```
(Graceful degradation: skip if TodoWrite unavailable)

[PROGRESS] Mark Step 1/10 `completed`:
```
Step 1/10: Load Config [completed]
Files read: .paadhai.json
```
```

### 5b — Per-step [PROGRESS] markers

Apply `[in_progress]` at start and `[completed]` at end for STEP 2–10:

| STEP | in_progress text | completed summary |
|------|-----------------|-------------------|
| 2 | `Step 2/10: Read Existing Context [in_progress]` | `Files read: <existing docs found>` |
| 3 | `Step 3/10: Product Description [in_progress]` | `Description received` |
| 4 | `Step 4/10: Clarifying Questions [in_progress]` | `Answers received` |
| 5 | `Step 5/10: Research [in_progress]` | `Research complete` |
| 6 | `Step 6/10: Generate SRS [in_progress]` | `SRS generated` |
| 7 | `Step 7/10: Present SRS [in_progress]` | `SRS presented` |
| 8 | `Step 8/10: Revision Loop [in_progress]` | `SRS approved` |
| 9 | `Step 9/10: Save [in_progress]` | `Files changed: {srs_path}` |
| 10 | `Step 10/10: Handoff [in_progress]` | `Output displayed` |

Each entry inserts:
- After heading: `[PROGRESS] Mark Step N/10 \`in_progress\`: \`<in_progress text>\``
- Before `---`: `[PROGRESS] Mark Step N/10 \`completed\`: \`<in_progress text with [in_progress] replaced by [completed]>\` \`<completed summary>\``

**Verification:**
```bash
grep -c "PROGRESS" .claude/skills/project-plan/SKILL.md
```
Expected: `20` (1 init + 1 step-1-complete + 9 steps × 2)

**Commit:**
```bash
git add .claude/skills/project-plan/SKILL.md
git commit -m "feat(project-plan): add TodoWrite [PROGRESS] step tracking

Creates 10-item checklist at start; marks each step in_progress
then completed.

Refs #8"
```

**Status:** pending

---

## Step 6 — Instrument `release-plan/SKILL.md`

**File:** `.claude/skills/release-plan/SKILL.md`

### 6a — Insert initialization block

Find this exact text in STEP 1:
```
- `{config.project_version}` (if present)
```

Insert the following block immediately after that line, before the `---` separator that opens STEP 2:

```markdown
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
```

### 6b — Per-step [PROGRESS] markers

Apply `[in_progress]` at start and `[completed]` at end for STEP 2–8:

| STEP | in_progress text | completed summary |
|------|-----------------|-------------------|
| 2 | `Step 2/8: Analyze Requirements [in_progress]` | `Requirements analyzed` |
| 3 | `Step 3/8: Create Issues [in_progress]` | `Issue list created` |
| 4 | `Step 4/8: Present Release Plan [in_progress]` | `Plan presented` |
| 5 | `Step 5/8: Revision Loop [in_progress]` | `Plan approved` |
| 6 | `Step 6/8: Create on GitHub (after G-03) [in_progress]` | `Milestones and issues created on GitHub` |
| 7 | `Step 7/8: Summary [in_progress]` | `Output displayed` |
| 8 | `Step 8/8: Handoff [in_progress]` | `Output displayed` |

Each entry inserts:
- After heading: `[PROGRESS] Mark Step N/8 \`in_progress\`: \`<in_progress text>\``
- Before `---`: `[PROGRESS] Mark Step N/8 \`completed\`: \`<in_progress text with [in_progress] replaced by [completed]>\` \`<completed summary>\``

**Verification:**
```bash
grep -c "PROGRESS" .claude/skills/release-plan/SKILL.md
```
Expected: `16` (1 init + 1 step-1-complete + 7 steps × 2)

**Commit:**
```bash
git add .claude/skills/release-plan/SKILL.md
git commit -m "feat(release-plan): add TodoWrite [PROGRESS] step tracking

Creates 8-item checklist at start; marks each step in_progress
then completed.

Refs #8"
```

**Status:** pending

---

## Step 7 — Instrument `dev-release/SKILL.md`

**File:** `.claude/skills/dev-release/SKILL.md`

### 7a — Insert initialization block

Find this exact text in STEP 1:
```
- `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` / `{config.stack.test_cmd}`
```

Insert the following block immediately after that line, before the `---` separator that opens STEP 2:

```markdown
### Progress Tracking

[PROGRESS] Initialize TodoWrite checklist — 14 items, all `pending`:
```
Step 1/14: Load Config
Step 2/14: Verify Milestone Completion
Step 3/14: Ask Version
Step 4/14: Prepare Release Branch
Step 5/14: Run Full Test Suite
Step 6/14: Generate Changelog
Step 7/14: Push + Create Release PR
Step 8/14: Display Release PR URL
Step 9/14: Final Confirmation
Step 10/14: Execute Release (after G-10)
Step 11/14: Close Milestone
Step 12/14: Display Release URL
Step 13/14: Post-Release Health Check
Step 14/14: Next Milestone
```
(Graceful degradation: skip if TodoWrite unavailable)

[PROGRESS] Mark Step 1/14 `completed`:
```
Step 1/14: Load Config [completed]
Files read: .paadhai.json
```
```

### 7b — Per-step [PROGRESS] markers

Apply `[in_progress]` at start and `[completed]` at end for STEP 2–14:

| STEP | in_progress text | completed summary |
|------|-----------------|-------------------|
| 2 | `Step 2/14: Verify Milestone Completion [in_progress]` | `Milestone verified: all issues closed` |
| 3 | `Step 3/14: Ask Version [in_progress]` | `Version confirmed` |
| 4 | `Step 4/14: Prepare Release Branch [in_progress]` | `Release branch created and pushed` |
| 5 | `Step 5/14: Run Full Test Suite [in_progress]` | `Build: ✓  Lint: ✓  Tests: <count> passing` |
| 6 | `Step 6/14: Generate Changelog [in_progress]` | `Files changed: CHANGELOG.md` |
| 7 | `Step 7/14: Push + Create Release PR [in_progress]` | `PR created` |
| 8 | `Step 8/14: Display Release PR URL [in_progress]` | `Output displayed` |
| 9 | `Step 9/14: Final Confirmation [in_progress]` | `Gate passed` |
| 10 | `Step 10/14: Execute Release (after G-10) [in_progress]` | `Release merged, tagged, back-merged` |
| 11 | `Step 11/14: Close Milestone [in_progress]` | `Milestone closed` |
| 12 | `Step 12/14: Display Release URL [in_progress]` | `Output displayed` |
| 13 | `Step 13/14: Post-Release Health Check [in_progress]` | `Health check complete` |
| 14 | `Step 14/14: Next Milestone [in_progress]` | `Output displayed` |

Each entry inserts:
- After heading: `[PROGRESS] Mark Step N/14 \`in_progress\`: \`<in_progress text>\``
- Before `---`: `[PROGRESS] Mark Step N/14 \`completed\`: \`<in_progress text with [in_progress] replaced by [completed]>\` \`<completed summary>\``

**Verification:**
```bash
grep -c "PROGRESS" .claude/skills/dev-release/SKILL.md
```
Expected: `28` (1 init + 1 step-1-complete + 13 steps × 2)

**Commit:**
```bash
git add .claude/skills/dev-release/SKILL.md
git commit -m "feat(dev-release): add TodoWrite [PROGRESS] step tracking

Creates 14-item checklist at start; marks each step in_progress
then completed.

Refs #8"
```

**Status:** pending

---

## Deviations

*(empty — record any deviations from the plan here during execution)*
