---
name: dev-implement
description: Use when implementing confirmed plans — execute steps with code review, auto-commit, and subagent delegation for independent tasks
---

# dev-implement: Execute Implementation

Execute the implementation doc step-by-step with code review, auto-commit, and optional subagent delegation.

---

## Resumption

If the user says "continue" or "resume":
1. [READ] implementation doc → find first step with status `pending`
2. [SHELL] `git status` → check for uncommitted work
3. Resume from that step — never re-do `done` steps

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
dev-implement | Issue #<number> — <title>
10 steps | Branch: <branch>
────────────────────────────────────────
```

Display (no issue context — not on feature/fix branch):
```
────────────────────────────────────────
dev-implement
10 steps | Branch: <branch>
────────────────────────────────────────
```

If `gh api` fails, degrade gracefully — show banner without issue title.

---

## RATIONALIZATION PREVENTION

Before executing any step, check your reasoning against this table. These are **structural rules** — they cannot be overridden.

| Thought | Why it's wrong | What to do |
|---------|---------------|------------|
| "This step is trivial, skip review" | Trivial changes cause subtle bugs — off-by-one, wrong variable, missed import | Run full code review for every step |
| "Tests aren't needed for this change" | Every code change needs verification; untested code is unverified code | Write or run tests as specified |
| "The build will obviously pass" | Build failures catch real issues — type errors, missing deps, broken imports | Run `{config.stack.build_cmd}` every time |
| "I'll commit these steps together" | Atomic commits aid debugging and revert; batching hides which step broke | One commit per step |
| "I already know this works" | Memory is unreliable — verify, don't assume | Run the verification command and read actual output |
| "This is just a config change, no review needed" | Config errors cause silent production failures | Review config changes like code changes |
| "I can skip lint, the code is clean" | Lint catches issues humans miss — formatting, unused vars, import order | Run `{config.stack.lint_cmd}` every time |

---

## VERIFICATION GATE

Before declaring any step `done`, you MUST run this 5-step gate. This is a **structural rule** — it cannot be overridden, skipped, or abbreviated. The gate runs per-step inside Step 7 (see sub-step 7d.1).

**Commands must be re-run every time — results cannot be recalled from memory.** Memory is unreliable; the only acceptable evidence is fresh command output captured during this gate run.

### The 5 steps

1. **IDENTIFY** — What specific claims am I about to make about this step? List each one (e.g., "tests pass", "build succeeds", "file X contains Y").
2. **RUN** — Execute the verification command(s) for each claim: `{config.stack.build_cmd}`, `{config.stack.lint_cmd}`, `{config.stack.test_cmd}`, or a `Read`/`Grep` for content claims. Do not reuse output from an earlier run.
3. **READ** — Read the ACTUAL output of each command. Do not summarize from memory. Do not paraphrase.
4. **VERIFY** — For each claim from IDENTIFY, check the output line-by-line. Does the output literally confirm the claim?
5. **CLAIM** — Only now may you state the step is complete. Every claim must be followed by a quoted block of the exact output that proves it.

### Red flags — restart the gate from RUN

If your CLAIM message contains any of the following, you MUST restart from step 2 (RUN):

- Hedging words: `should`, `probably`, `seems to`, `I believe`, `appears to`, `looks like`
- No quoted command output block for a claim
- Claims without a specific file path + line reference (for content claims)
- Output quoted from an earlier step or earlier gate run (must be fresh)

### Edge case — docs-only step (7d skipped)

If Step 7d was skipped because no source files changed, the gate still runs: execute `{config.stack.lint_cmd}` (if available) or the relevant `Read`/`Grep` command to verify the docs claim, and quote that output in CLAIM.

### PASS format

```
GATE: PASS

Claims verified:
1. <claim>
   Evidence:
   ```
   <quoted command output>
   ```
2. <claim>
   Evidence:
   ```
   <quoted command output>
   ```
```

### FAIL format

If any claim cannot be verified, the gate FAILS and the step stays `pending`. Do not proceed to 7e. Do not commit.

```
GATE: FAIL

Unmet items:
1. Claim "<claim>" — <reason, e.g., "no output quoted", "output shows 2 failures", "hedging language used">
2. Claim "<claim>" — <reason>

Next action: fix the missing evidence above and re-run the gate from step 2 (RUN).
```

---

## STEP 1 — Load Config

[READ] `.paadhai.json` — hard stop if missing:

> No `.paadhai.json` found. Run `/paadhai:project-init` first.

Store:
- `{config.stack.build_cmd}` / `{config.stack.lint_cmd}` / `{config.stack.test_cmd}`

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

---

## STEP 2 — Load Implementation Doc

[PROGRESS] Mark Step 2/10 `in_progress`: `Step 2/10: Load Implementation Doc [in_progress]`

[SHELL] Get current branch:
```bash
git branch --show-current
```

Derive issue number from branch. [READ] `docs/plans/issue-<n>/implementation.md` + `docs/plans/issue-<n>/plan.md`.

Display:
```
Issue     : #<number> <title>
Branch    : <branch-name>
Steps     : <total count>
Doc path  : docs/plans/issue-<n>/implementation.md
```

Ask user:
- Model preference? (fast / smart / auto)

Present commit mode selection using AskUserQuestion:

**Prompt text:** "Implementation has <total step count> steps. How would you like to handle commits?"

**Options:**
| Label | Description |
|-------|-------------|
| Per-step (Recommended) | Approve each commit individually (current behavior) |
| Auto-commit | Commit automatically after each passing step |
| Batch | Commit at natural checkpoints (after related groups) |

Store the selection as `commit_mode` (`per-step` | `auto-commit` | `batch`) for use by G-06 and downstream commit logic.

The total step count is derived from the implementation doc's progress table (count of rows excluding the header).

[PROGRESS] Mark Step 2/10 `completed`: `Step 2/10: Load Implementation Doc [completed]`
`Files read: docs/plans/issue-<n>/implementation.md, docs/plans/issue-<n>/plan.md`

---

## STEP 3 — Analyze Task Dependencies

[PROGRESS] Mark Step 3/10 `in_progress`: `Step 3/10: Analyze Task Dependencies [in_progress]`

Scan implementation steps for:
- **Sequential patterns**: step B requires step A's output
- **Independent patterns**: steps with no shared state

If 3+ independent tasks with <20% dependencies → offer subagent-driven mode.

[PROGRESS] Mark Step 3/10 `completed`: `Step 3/10: Analyze Task Dependencies [completed]`
`Analysis complete`

---

## STEP 4 — Choose Execution Path

[PROGRESS] Mark Step 4/10 `in_progress`: `Step 4/10: Choose Execution Path [in_progress]`

- **Independent-heavy** → offer: subagent-driven OR sequential
- **Sequential-heavy** → sequential only
- **Mixed** → offer choice

Display the dependency analysis and let user choose.

[PROGRESS] Mark Step 4/10 `completed`: `Step 4/10: Choose Execution Path [completed]`
`Decision made`

---

## STEP 5 — Pre-Implementation Check

[PROGRESS] Mark Step 5/10 `in_progress`: `Step 5/10: Pre-Implementation Check [in_progress]`

[SHELL] Verify branch and working state:
```bash
git branch --show-current
git status
```

- Must be on feature branch (not `{config.repo.develop_branch}` or `main`)
- Working tree must be clean (or stash uncommitted work first)

[PROGRESS] Mark Step 5/10 `completed`: `Step 5/10: Pre-Implementation Check [completed]`
`Branch verified, working tree clean`

---

## STEP 6 — Route Execution

[PROGRESS] Mark Step 6/10 `in_progress`: `Step 6/10: Route Execution [in_progress]`

- **Subagent-driven** → hand off to `/paadhai:dev-parallel`. Pass the issue number as context.
- **Sequential** → continue to Step 7

[PROGRESS] Mark Step 6/10 `completed`: `Step 6/10: Route Execution [completed]`
`Route determined`

---

## STEP 7 — Implementation Loop

[PROGRESS] Mark Step 7/10 `in_progress`: `Step 7/10: Implementation Loop [in_progress]`

For each `pending` step in the implementation doc:

### 7a — Read Before Modifying
[READ] all files that will be modified in this step.

### 7b — Implement
[DELEGATE] Execute the step (model per user choice in Step 2). Follow the exact command/code in the implementation doc.

### 7c — Code Review
[READ] `code-reviewer-prompt.md` — load review criteria.
[DELEGATE][SMART-MODEL] Review changes using the loaded reviewer prompt. Check:
- Correctness
- Pattern alignment with existing code
- No introduced bugs or security issues

**PASS/FAIL.** Skip for: config changes, docs, dependency bumps. Fix until PASS.

### 7d — Build + Lint
[SHELL] (skip if no source files changed):
```bash
{config.stack.build_cmd}
{config.stack.lint_cmd}
```

Fix failures before proceeding.

### 7d.1 — Verification Gate

Run the 5-step VERIFICATION GATE (defined in the `## VERIFICATION GATE` section at the top of this file) before marking this step `done`.

- **Inputs to the gate**: the exact output from 7d's `{config.stack.build_cmd}` and `{config.stack.lint_cmd}`, plus any test command output for this step. Output must be fresh — re-run if you do not have it captured.
- **Docs-only step**: if 7d was skipped (no source files changed), run `{config.stack.lint_cmd}` (if available) or the relevant content-verification command (`Read`/`Grep`) and quote its output.
- **On PASS**: proceed to 7e.
- **On FAIL**: do not proceed to 7e. Do not commit. Fix the unmet items listed by the gate and re-run the gate from step 2 (RUN).
- **Hedging auto-retrigger**: if your CLAIM contains `should`, `probably`, `seems to`, `I believe`, or lacks a quoted output block, restart the gate from RUN before proceeding.

### 7e — Update Implementation Doc
[WRITE] Mark step as `done` in implementation doc. Add deviation note if step differed from plan.

### 7f — Step Summary + Gate
Display:
```
Step <n> complete
Files changed : <list>
Build         : ✓ / ✗
Lint          : ✓ / ✗
Code review   : PASS / SKIP
```

**G-06**: If auto-commit = yes → commit automatically. If no → wait for "yes".

### 7g — Commit
[SHELL] Commit specific files (not `git add -A`):
```bash
git add <specific-files-changed>
git commit -m "<type>(<scope>): <subject>

<optional body>

Refs #<number>"
```

Commit type guide:
| Type | When |
|------|------|
| `feat` | New functionality |
| `fix` | Bug fix |
| `test` | Test only |
| `chore` | Deps, config |
| `refactor` | Restructure, no behavior change |
| `docs` | Documentation |
| `perf` | Performance improvement |

Subject: max 72 chars, imperative mood ("add X" not "added X").

### 7h — Progress Dashboard
After each step's commit, display a compact aggregate progress dashboard. Data MUST come from actual command output — never estimate or fabricate values.

[SHELL] Gather cumulative stats:
```bash
# Count commits on this branch since diverging from develop
COMMIT_COUNT=$(git rev-list {config.repo.develop_branch}..HEAD --count)

# Count created (A) and modified (M) files since diverging from develop
CREATED=$(git diff --name-status {config.repo.develop_branch}...HEAD | grep -c '^A')
MODIFIED=$(git diff --name-status {config.repo.develop_branch}...HEAD | grep -c '^M')
TOTAL_FILES=$((CREATED + MODIFIED))
```

Compute progress bar:
- Let `DONE` = number of implementation steps completed so far (including this one)
- Let `TOTAL` = total number of implementation steps
- Let `PCT` = `DONE * 100 / TOTAL`
- Filled chars = `DONE * 12 / TOTAL` (integer division), using `█`
- Empty chars = `12 - filled`, using `░`

Determine test and build status:
- **Build**: Use the result from the most recent 7d execution. If 7d was skipped for this step (no source files changed), use the last known build result. If no build has run yet, show `not yet run`.
- **Tests**: Use the result from the most recent `{config.stack.test_cmd}` execution (typically Step 8). If no test command has run yet, show `not yet run`.

Display:
```
Progress: ████████░░░░ <DONE>/<TOTAL> steps (<PCT>%)
══════════════════════════════════════════
Files changed : <TOTAL_FILES> (<CREATED> created, <MODIFIED> modified)
Commits       : <COMMIT_COUNT>
Tests         : <passing> passing, <failing> failing | not yet run
Build         : passing | failing | not yet run
══════════════════════════════════════════
```

**Constraints:**
- Maximum 6 lines excluding the `══` border lines (AC-4)
- Progress bar is always 12 characters wide (AC-3)
- All values derived from actual `git diff`, `git rev-list`, and command output — never from agent estimation (AC-5)

**Edge cases:**
- First step completed with no prior changes: show `0` for files/commits, `not yet run` for tests/build
- Step where build/lint was skipped (no source files): show last known build status
- Build or test failure: show `failing`, not `passing`

[PROGRESS] Mark Step 7/10 `completed`: `Step 7/10: Implementation Loop [completed]`
`Files changed: <list from step>  Build: ✓  Lint: ✓`

---

## STEP 8 — Full Test Run

[PROGRESS] Mark Step 8/10 `in_progress`: `Step 8/10: Full Test Run [in_progress]`

[SHELL] After all steps complete:
```bash
{config.stack.build_cmd}
{config.stack.lint_cmd}
{config.stack.test_cmd}
```

Fix any failures before proceeding. Do not skip.

[PROGRESS] Mark Step 8/10 `completed`: `Step 8/10: Full Test Run [completed]`
`Build: ✓  Lint: ✓  Tests: <count> passing`

---

## STEP 9 — Summary

[PROGRESS] Mark Step 9/10 `in_progress`: `Step 9/10: Summary [in_progress]`

Display:
```
Implementation complete

Issue   : #<number> <title>
Commits : <count>
Build   : ✓
Lint    : ✓
Tests   : <pass count> passing
```

[PROGRESS] Mark Step 9/10 `completed`: `Step 9/10: Summary [completed]`
`Output displayed`

---

## STEP 10 — Handoff

[PROGRESS] Mark Step 10/10 `in_progress`: `Step 10/10: Handoff [in_progress]`

```
Run /dev-pr to push the branch and open a pull request.

Branch  : <branch-name>
Issue   : #<number>
```

[PROGRESS] Mark Step 10/10 `completed`: `Step 10/10: Handoff [completed]`
`Output displayed`
